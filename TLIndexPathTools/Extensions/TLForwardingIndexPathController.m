//
//  TLForwardingIndexPathController.m
//  HomeStory
//
//  Created by Tim Moose on 7/24/13.
//  Copyright (c) 2013 tmoose@vast.com. All rights reserved.
//

#import "TLForwardingIndexPathController.h"

@interface TLForwardingIndexPathController ()
@property TLIndexPathController *controller;
@end

@implementation TLForwardingIndexPathController

#pragma mark - Initialization

- (id)initWithController:(TLIndexPathController *)controller
{
    if (self = [super init]) {
        _controller = controller;
    }
    return self;
}

#pragma mark - Configuration information

- (NSFetchRequest *)fetchRequest
{
    return self.controller.fetchRequest;
}

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest
{
    self.controller.fetchRequest = fetchRequest;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.controller.managedObjectContext;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self.controller.managedObjectContext = managedObjectContext;
}

- (NSString *)cacheName
{
    return self.controller.cacheName;
}

- (void)setCacheName:(NSString *)cacheName
{
    self.controller.cacheName = cacheName;
}

- (BOOL)ignoreDataModelChanges
{
    return self.controller.ignoreDataModelChanges;
}

- (void)setIgnoreDataModelChanges:(BOOL)ignoreDataModelChanges
{
    self.controller.ignoreDataModelChanges = ignoreDataModelChanges;
}

#pragma mark - Accessing data

- (NSArray *)items
{
    return self.controller.items;
}

- (void)setItems:(NSArray *)items
{
    self.controller.items = items;
}

- (TLIndexPathDataModel *)dataModel
{
    return self.controller.dataModel;
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel
{
    self.controller.dataModel = dataModel;
}

#pragma mark - Fetchingd data

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    return [self.controller performFetch:error];
}

- (BOOL)isFetched
{
    return self.controller.isFetched;
}

- (BOOL)ignoreFetchedResultsChanges
{
    return self.controller.ignoreFetchedResultsChanges;
}

- (void)setIgnoreFetchedResultsChanges:(BOOL)ignoreFetchedResultsChanges
{
    self.controller.ignoreFetchedResultsChanges = ignoreFetchedResultsChanges;
}

#pragma mark - In-memory filtering and sorting

- (NSPredicate *)inMemoryPredicate
{
    return self.controller.inMemoryPredicate;
}

- (void)setInMemoryPredicate:(NSPredicate *)inMemoryPredicate
{
    self.controller.inMemoryPredicate = inMemoryPredicate;
}

- (NSArray *)inMemorySortDescriptors
{
    return self.controller.inMemorySortDescriptors;
}

- (void)setInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors
{
    self.controller.inMemorySortDescriptors = inMemorySortDescriptors;
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion
{
    [self.controller performBatchUpdates:updates completion:completion];
}

- (NSArray *)coreDataFetchedObjects
{
    return self.controller.coreDataFetchedObjects;
}

@end
