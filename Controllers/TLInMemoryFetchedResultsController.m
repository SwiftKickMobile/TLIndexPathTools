//
//  TLInMemoryFetchedResultsController.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLInMemoryFetchedResultsController.h"
#import "TLIndexPathDataModel.h"
#import "TLIndexPathUpdates.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

NSString * const TLDataModelControllerChangedNotification = @"TLDataModelControllerChangedNotification";

@interface TLInMemoryFetchedResultsController() {
    dispatch_queue_t _batchQueue;
    
    NSLock *_batchBarrier;
}

@property (strong, nonatomic) NSFetchedResultsController *backingFetchedResultsController;

@property (strong, nonatomic) NSMutableArray *updatedItems;

@end

@implementation TLInMemoryFetchedResultsController

@synthesize sectionNameKeyPath = _sectionNameKeyPathLocal;
@synthesize delegate = _delegateLocal;

- (void)dealloc {
    //the delegate property is an 'assign' property
    //not technically needed because the FRC will dealloc when we do, but it's a good idea.
    self.backingFetchedResultsController.delegate = nil;
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name
{
    return [self initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath identifierKeyPath:nil cacheName:name];
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name
{
    if (self = [super init]) {
        _sectionNameKeyPathLocal = sectionNameKeyPath;
        _identifierKeyPath = identifierKeyPath;
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:name];
        fetchedResultsController.delegate = self;
        self.backingFetchedResultsController = fetchedResultsController;

        _batchQueue = dispatch_queue_create("tl-fetched-results-controller-queue", DISPATCH_QUEUE_SERIAL);
        _batchBarrier = [[NSLock alloc] init];
    }
    return self;
}

#pragma mark - Public APIs

- (TLIndexPathDataModel *)dataModel
{
    if (!self.isFetched) return nil;
    if (!_dataModel) {
        self.dataModel = [self convertFetchedObjectsToDataModel];
    }
    return _dataModel;
}

- (NSString *)sectionNameKeyPath
{
    return _sectionNameKeyPathLocal;
}

- (void)setDelegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    if (_delegateLocal != delegate) {
        _delegateLocal = delegate;
    }
}

- (id<NSFetchedResultsControllerDelegate>)delegate
{
    return _delegateLocal;
}

- (NSArray *)sections
{
    NSArray *sections = [self.dataModel sections];
    return sections;
}

- (void)setInMemoryPredicate:(NSPredicate *)inMemoryPredicate
{
    [self setInMemoryPredicate:inMemoryPredicate andInMemorySortDescriptors:self.inMemorySortDescriptors];
}

- (void)setInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors
{
    [self setInMemoryPredicate:self.inMemoryPredicate andInMemorySortDescriptors:inMemorySortDescriptors];
}

- (void)setInMemoryPredicate:(NSPredicate *)inMemoryPredicate andInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors
{
    BOOL changed = NO;

    if (_inMemoryPredicate != inMemoryPredicate) {
        _inMemoryPredicate = inMemoryPredicate;
        changed = YES;
    }

    if (![_inMemorySortDescriptors isEqualToArray:inMemorySortDescriptors]) {
        _inMemorySortDescriptors = inMemorySortDescriptors;
        changed = YES;
    }

    if (changed) {
        [self processBatchUpdateWithUpdatedObjects:nil];
    }
}

- (NSFetchRequest *)fetchRequest
{
    return self.backingFetchedResultsController.fetchRequest;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.backingFetchedResultsController.managedObjectContext;
}

- (NSArray *)fetchedObjects
{
    return [self.dataModel items];
}

- (NSArray *)coreDataFetchedObjects
{
    return self.backingFetchedResultsController.fetchedObjects;
}

- (NSArray *)sectionIndexTitles
{
    return nil;// TODO
}

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL result = [self.backingFetchedResultsController performFetch:error];
    self.isFetched = result;
    [self processBatchUpdateWithUpdatedObjects:nil];
    return result;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataModel itemAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
    return [self.dataModel indexPathForItem:object];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex
{
    return sectionIndex;
}

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

#pragma mark - Reload

- (TLIndexPathDataModel *)convertFetchedObjectsToDataModel {
    NSArray *filteredItems = self.inMemoryPredicate ? [self.coreDataFetchedObjects filteredArrayUsingPredicate:self.inMemoryPredicate] : self.coreDataFetchedObjects;
    NSArray *sortedFilteredItems = self.inMemorySortDescriptors ? [filteredItems sortedArrayUsingDescriptors:self.inMemorySortDescriptors] : filteredItems;
    return [[TLIndexPathDataModel alloc] initWithItems:sortedFilteredItems andSectionNameKeyPath:self.sectionNameKeyPath andIdentifierKeyPath:self.identifierKeyPath];
}


- (void)processBatchUpdateWithUpdatedObjects:(NSArray *)updatedObjects {
    
    [_batchBarrier lock];
    //send this to our updater serial queue
    dispatch_async(_batchQueue, ^{
       
        dispatch_semaphore_t completeLock = dispatch_semaphore_create(0);

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([(id)self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
                [self.delegate controllerWillChangeContent:self];
            }
            
            //need to do the next bit in the context of the managedobjectcontext
            //since convertFetchedObjectsToDataModel accesses the objects in it
            [self.backingFetchedResultsController.managedObjectContext performBlock:^{
                
                TLIndexPathDataModel *oldModel = self.dataModel;
                TLIndexPathDataModel *newModel = [self convertFetchedObjectsToDataModel];
                
                //compute the deltas between the old and the new
                TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldModel updatedDataModel:newModel];
                
                //we can switch our data model now that we're about to call out to the fine-grained change functions.
                self.dataModel = newModel;
                
                //switch to the main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([(id)self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
                        
                        for (NSString *sectionName in updates.deletedSectionNames) {
                            NSInteger section = [oldModel sectionForSectionName:sectionName];
                            id<NSFetchedResultsSectionInfo> sectionInfo = [oldModel sections][section];
                            [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeDelete];
                        }
                        
                        for (NSString *sectionName in updates.insertedSectionNames) {
                            NSInteger section = [newModel sectionForSectionName:sectionName];
                            id<NSFetchedResultsSectionInfo> sectionInfo = [newModel sections][section];
                            [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeInsert];
                        }
                        
                        for (NSString *sectionName in updates.movedSectionNames) {
                            NSInteger section = [newModel sectionForSectionName:sectionName];
                            id<NSFetchedResultsSectionInfo> sectionInfo = [newModel sections][section];
                            [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeMove];
                        }
                    }
                    
                    if ([(id)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
                        
                        for (id item in updates.deletedItems) {
                            NSIndexPath *indexPath = [oldModel indexPathForItem:item];
                            [self.delegate controller:self didChangeObject:item atIndexPath:indexPath forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
                        }
                        
                        for (id item in updates.insertedItems) {
                            NSIndexPath *indexPath = [newModel indexPathForItem:item];
                            [self.delegate controller:self didChangeObject:item atIndexPath:indexPath forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPath];
                        }
                        
                        for (id item in updates.movedItems) {
                            NSIndexPath *oldIndexPath = [oldModel indexPathForItem:item];
                            NSIndexPath *updatedIndexPath = [newModel indexPathForItem:item];
                            [self.delegate controller:self didChangeObject:item atIndexPath:oldIndexPath forChangeType:NSFetchedResultsChangeMove newIndexPath:updatedIndexPath];
                        }
                        
                        for (id item in updatedObjects) {
                            NSIndexPath *indexPath = [oldModel indexPathForItem:item];
                            NSIndexPath *newIndexPath = [newModel indexPathForItem:item];
                            // Don't report updates for items in inserted or deleted sections
                            NSString *sectionName = [oldModel sectionNameForSection:indexPath.section];
                            NSString *newSectionName = [newModel sectionNameForSection:newIndexPath.section];
                            if (indexPath && [updates.deletedSectionNames containsObject:sectionName]) {
                                continue;
                            }
                            if (newIndexPath && [updates.insertedSectionNames containsObject:newSectionName]) {
                                continue;
                            }
                            if (indexPath) {
                                [self.delegate controller:self didChangeObject:item atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:newIndexPath];
                            }
                        }
                    }
                    
                    //finish up
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([(id)self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
                            [self.delegate controllerDidChangeContent:self];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:TLDataModelControllerChangedNotification object:self];
                        dispatch_semaphore_signal(completeLock);
                    });
                });
                
            }];
            
        });

        //wait on the semaphore
        dispatch_semaphore_wait(completeLock, DISPATCH_TIME_FOREVER);
        //dispatch_release(completeLock);
    });
    
    [_batchBarrier unlock];
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.updatedItems = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath

{
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [self.updatedItems addObject:anObject];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self processBatchUpdateWithUpdatedObjects:self.updatedItems];
    self.updatedItems = nil;
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
