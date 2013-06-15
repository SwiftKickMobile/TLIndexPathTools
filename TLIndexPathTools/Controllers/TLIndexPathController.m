//
//  TLIndexPathController.m
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

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"
#import "TLIndexPathUpdates.h"

NSString * const TLIndexPathControllerChangedNotification = @"TLIndexPathControllerChangedNotification";

@interface TLIndexPathController ()
@property (strong, nonatomic) NSFetchedResultsController *backingController;
@end

@implementation TLIndexPathController

- (void)dealloc {
    //the delegate property is an 'assign' property
    //not technically needed because the FRC will dealloc when we do, but it's a good idea.
    self.backingController.delegate = nil;
}

#pragma mark - Initilization

- (instancetype)initWithItems:(NSArray *)items
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:items andSectionNameKeyPath:nil andIdentifierKeyPath:nil];
    return [self initWithDataModel:dataModel];
}

- (instancetype)initWithIndexPathItems:(NSArray *)items
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithIndexPathItems:items];
    return [self initWithDataModel:dataModel];
}

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel
{
    if (self = [super init]) {
        _dataModel = dataModel;
    }
    return self;
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:nil andSectionNameKeyPath:sectionNameKeyPath andIdentifierKeyPath:identifierKeyPath];
    if (self = [self initWithDataModel:dataModel]) {
        //initialize the backing controller with nil sectionNameKeyPath because we don't require
        //items to be sorted by section, but NSFetchedResultsController does.
        _backingController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:name];
        _backingController.delegate = self;
    }
    return self;
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

- (void)setIgnoreFetchedResultsChanges:(BOOL)ignoreFetchedResultsChanges
{
    if (_ignoreFetchedResultsChanges != ignoreFetchedResultsChanges) {
        _ignoreFetchedResultsChanges = ignoreFetchedResultsChanges;
        //if fetch was ever performed, automatically re-perform fetch when
        //ignoring is disabled.
        //TODO we might want to consider queueing up the incremental changes
        //that get reported by the backing controller while ignoring is enabled
        //and not having to perform a full fetch.
        if (NO == ignoreFetchedResultsChanges && self.isFetched) {
            [self performFetch:nil];
        }
    }
}

#pragma mark - Accessing data

- (NSArray *)items
{
    return self.dataModel.items;
}

- (void)setItems:(NSArray *)items
{
    if (![self.items isEqualToArray:items]) {
        id last = [items lastObject];
        TLIndexPathDataModel *dataModel;
        if ([last isKindOfClass:[TLIndexPathItem class]]) {
            dataModel = [[TLIndexPathDataModel alloc] initWithIndexPathItems:items];
        } else {
            dataModel = [[TLIndexPathDataModel alloc] initWithItems:items
                                              andSectionNameKeyPath:self.dataModel.sectionNameKeyPath
                                               andIdentifierKeyPath:self.dataModel.identifierKeyPath
                                           andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
        }
        self.dataModel = dataModel;
    }
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel
{
    if (![_dataModel isEqual:dataModel]) {
        TLIndexPathDataModel *oldDataModel = _dataModel;
        _dataModel = dataModel;
        if ([self.delegate respondsToSelector:@selector(controller:didUpdateDataModel:)]) {
            TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:dataModel];
            [self.delegate controller:self didUpdateDataModel:updates];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TLIndexPathControllerChangedNotification object:self];
    }
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
    //fall back to objectID in case the data model doesn't have a value defined.
    //This is necessary because managed objects themselves cannot be used as
    //identifiers because identifiers are used as dictionary keys and therefore
    //must implement NSCoding (which NSManagedObject does not).
    NSString *identifierKeyPath = self.dataModel.identifierKeyPath ? self.dataModel.identifierKeyPath : @"objectID";
    return [[TLIndexPathDataModel alloc] initWithItems:sortedFilteredItems
                                 andSectionNameKeyPath:self.dataModel.sectionNameKeyPath
                                  andIdentifierKeyPath:identifierKeyPath
                              andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.ignoreFetchedResultsChanges) {
            self.dataModel = [self convertFetchedObjectsToDataModel];
        }
    });
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
