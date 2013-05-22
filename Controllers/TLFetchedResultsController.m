//
//  TLFetchedResultsController.m
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

#import "TLFetchedResultsController.h"

@interface TLFetchedResultsController ()
@property (strong, nonatomic) dispatch_queue_t batchQueue;
@property (strong, nonatomic) NSLock *batchBarrier;
@property (strong, nonatomic) NSFetchedResultsController *backingController;
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@end

@implementation TLFetchedResultsController

- (void)dealloc {
    //the delegate property is an 'assign' property
    //not technically needed because the FRC will dealloc when we do, but it's a good idea.
    self.backingController.delegate = nil;
}

#pragma mark - Initialization

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name
{    
    if (self = [super init]) {
        _backingController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:name];
        _backingController.delegate = self;
        _batchQueue = dispatch_queue_create("tl-fetched-results-controller-queue", DISPATCH_QUEUE_SERIAL);
        _batchBarrier = [[NSLock alloc] init];        
    }
    return self;
}

#pragma mark - Fetching data

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL result = [self.backingController performFetch:error];
    if (result) {
        self.dataModel = [self convertFetchedObjectsToDataModel];
        self.isFetched = YES;
    }
    return result;
}

#pragma mark - Configuration information

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest
{
    if (![self.fetchRequest isEqual:fetchRequest]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:self.backingController.managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:self.backingController.cacheName];
        self.backingController.delegate = self;
    }
}

- (NSFetchRequest *)fetchRequest
{
    return self.backingController.fetchRequest;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (![self.managedObjectContext isEqual:managedObjectContext]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:self.backingController.fetchRequest
                                  managedObjectContext:managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:self.backingController.cacheName];
        self.backingController.delegate = self;
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.backingController.managedObjectContext;
}

- (void)setCacheName:(NSString *)cacheName
{
    if (![self.cacheName isEqual:cacheName]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:self.backingController.fetchRequest
                                  managedObjectContext:self.backingController.managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:cacheName];
        self.backingController.delegate = self;
    }
}

- (NSString *)cacheName
{
    return self.backingController.cacheName;
}

+ (void)deleteCacheWithName:(NSString *)name
{
    [NSFetchedResultsController deleteCacheWithName:name];
}

- (NSString *)identifierKeyPath
{
    //fall back to objectID in case the data model doesn't have a value defined.
    //This is necessary because managed objects themselves cannot be used as
    //identifiers because identifiers are used as dictionary keys and therefore
    //must implement NSCoding (which NSManagedObject does not).
    NSString *identifierKeyPath = self.dataModel.identifierKeyPath ? self.dataModel.identifierKeyPath : @"objectID";
    return identifierKeyPath;
}

- (void)setIgnoreIncrementalChanges:(BOOL)ignoreIncrementalChanges
{
    if (_ignoreIncrementalChanges != ignoreIncrementalChanges) {
        _ignoreIncrementalChanges = ignoreIncrementalChanges;
        //if fetch was ever performed, automatically re-perform fetch when
        //ignoring is disabled.
        //TODO we might want to consider queueing up the incremental changes
        //that get reported by the backing controller while ignoring is enabled
        //and not having to perform a full fetch.
        if (NO == ignoreIncrementalChanges && self.isFetched) {
            [self performFetch:nil];
        }
    }
}

#pragma mark - In-memory filtering and sorting

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
        self.dataModel = [self convertFetchedObjectsToDataModel];
    }
}


- (NSArray *)coreDataFetchedObjects
{
    return self.backingController.fetchedObjects;
}

- (TLIndexPathDataModel *)convertFetchedObjectsToDataModel {
    NSArray *filteredItems = self.inMemoryPredicate ? [self.coreDataFetchedObjects filteredArrayUsingPredicate:self.inMemoryPredicate] : self.coreDataFetchedObjects;
    NSArray *sortedFilteredItems = self.inMemorySortDescriptors ? [filteredItems sortedArrayUsingDescriptors:self.inMemorySortDescriptors] : filteredItems;
    return [[TLIndexPathDataModel alloc] initWithItems:sortedFilteredItems
                                 andSectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  andIdentifierKeyPath:self.identifierKeyPath
                              andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.ignoreIncrementalChanges) {
        self.dataModel = [self convertFetchedObjectsToDataModel];
    }
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
