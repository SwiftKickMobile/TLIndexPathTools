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
#import "TLIndexPathDataModelUpdates.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface TLInMemoryFetchedResultsController()
@property (strong, nonatomic) NSFetchedResultsController *backingFetchedResultsController;
@property (nonatomic) BOOL performingBatchUpdates;
@property (strong, nonatomic) NSMutableArray *updatedItems;
@end

@implementation TLInMemoryFetchedResultsController

@synthesize sectionNameKeyPath = _sectionNameKeyPathLocal;
@synthesize delegate = _delegateLocal;

#pragma mark - Public APIs

- (TLIndexPathDataModel *)dataModel
{
    if (!self.isFetched) return nil;
    if (!_dataModel) {
        NSArray *filteredItems = self.inMemoryPredicate ? [self.coreDataFetchedObjects filteredArrayUsingPredicate:self.inMemoryPredicate] : self.coreDataFetchedObjects;
        NSArray *sortedFilteredItems = self.inMemorySortDescriptors ? [filteredItems sortedArrayUsingDescriptors:self.inMemorySortDescriptors] : filteredItems;
        TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:sortedFilteredItems andSectionNameKeyPath:self.sectionNameKeyPath andIdentifierKeyPath:self.identifierKeyPath];
        self.dataModel = dataModel;        
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
    if (_inMemoryPredicate != inMemoryPredicate) {
        _inMemoryPredicate = inMemoryPredicate;
        [self reloadDataModelWithOldDataModel:self.dataModel];
    }
}

- (void)setInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors
{
    if (![_inMemorySortDescriptors isEqualToArray:inMemorySortDescriptors]) {
        _inMemorySortDescriptors = inMemorySortDescriptors;
        [self reloadDataModelWithOldDataModel:self.dataModel];
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
    }
    return self;
}

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL result = [self.backingFetchedResultsController performFetch:error];
    self.isFetched = result;
    [self reloadDataModelWithOldDataModel:self.dataModel];
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

- (void)performBatchChanges:(void (^)(void))changes completion:(void (^)(BOOL))completion
{
    self.performingBatchUpdates = YES;
    if (changes) changes();
    self.performingBatchUpdates = NO;
    [self reloadDataModelWithOldDataModel:self.dataModel];
    if (completion) completion(YES);
}

#pragma mark - Reload

- (void) reloadDataModelWithOldDataModel:(TLIndexPathDataModel *)oldDataModel
{
    @synchronized(self) {
        
        if (self.performingBatchUpdates) return;
        
        self.dataModel = nil;
        TLIndexPathDataModel *updatedDataModel = self.dataModel;
        TLIndexPathDataModelUpdates *updates = [[TLIndexPathDataModelUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:updatedDataModel];
        
        if ([(id)self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
            [self.delegate controllerWillChangeContent:self];
        }

        if ([(id)self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
            
            for (NSString *sectionName in updates.deletedSectionNames) {
                NSInteger section = [oldDataModel sectionForSectionName:sectionName];
                id<NSFetchedResultsSectionInfo> sectionInfo = [oldDataModel sections][section];
                [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeDelete];
            }
            
            for (NSString *sectionName in updates.insertedSectionNames) {
                NSInteger section = [updatedDataModel sectionForSectionName:sectionName];
                id<NSFetchedResultsSectionInfo> sectionInfo = [updatedDataModel sections][section];
                [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeInsert];
            }
            
            for (NSString *sectionName in updates.movedSectionNames) {
                NSInteger section = [updatedDataModel sectionForSectionName:sectionName];
                id<NSFetchedResultsSectionInfo> sectionInfo = [updatedDataModel sections][section];
                [self.delegate controller:self didChangeSection:sectionInfo atIndex:section forChangeType:NSFetchedResultsChangeMove];
            }
        }

        if ([(id)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            
            for (id item in updates.deletedItems) {
                NSIndexPath *indexPath = [oldDataModel indexPathForItem:item];
                [self.delegate controller:self didChangeObject:item atIndexPath:indexPath forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
            }
            
            for (id item in updates.insertedItems) {
                NSIndexPath *indexPath = [updatedDataModel indexPathForItem:item];
                [self.delegate controller:self didChangeObject:item atIndexPath:indexPath forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPath];
            }
            
            for (id item in updates.movedItems) {
                NSIndexPath *oldIndexPath = [oldDataModel indexPathForItem:item];
                NSIndexPath *updatedIndexPath = [updatedDataModel indexPathForItem:item];
                [self.delegate controller:self didChangeObject:item atIndexPath:oldIndexPath forChangeType:NSFetchedResultsChangeMove newIndexPath:updatedIndexPath];
            }
            
            for (id item in self.updatedItems) {
                NSIndexPath *indexPath = [oldDataModel indexPathForItem:item];
                NSIndexPath *newIndexPath = [updatedDataModel indexPathForItem:item];
                // Don't report updates for items in inserted or deleted sections
                NSString *sectionName = [oldDataModel sectionNameForSection:indexPath.section];
                NSString *newSectionName = [updatedDataModel sectionNameForSection:newIndexPath.section];
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

        self.updatedItems = nil;

        if ([(id)self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [self.delegate controllerDidChangeContent:self];
        }
    }
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
    [self reloadDataModelWithOldDataModel:self.dataModel];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
