//
//  TLFetchedResultsController.h
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import <CoreData/CoreData.h>

#import "TLIndexPathController.h"

@interface TLFetchedResultsController : TLIndexPathController <NSFetchedResultsControllerDelegate>

#pragma mark - Initialization

/**
 Returns an index path controller initialized with the given fetch request and
 configuration parameters.
 
 @param fetchRequest
 @param context
 @param sectionNameKeyPath
 @param identifierKeyPath
 @param cacheName
 @return the index path controller with a default data model representation of the given fetch request
 
 */
- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name;

#pragma mark - Fetchingd data

/**
 Calling this method executes the fetch request and causes a new data model to be
 created with the fetch result and any changes propagated to the controller's
 delegate. Unlike NSFetchedResultsController, repeated calls to this method will
 continue to propagate batch changes. This makes it possible to modify the fetch
 request's predicate and/or sort descriptors and have the new fetch result be
 propagated as batch changes.
 */
- (BOOL)performFetch:(NSError *__autoreleasing *)error;

/**
 Returns YES if `performFetch:` has ever been called.
 
 This property does not indicate whether the fetched results are fresh or stale.
 For example, if the `fetchRequest` is modified after `performFetch:` has been
 called, the `isFetched` property will continue to return YES.
 */
@property (nonatomic) BOOL isFetched;

/**
 Determines whether incremental fetch request changes are ignored.
 
 This property can be set to YES to temporarily ignore incremental fetch
 request changes, such as when a table is in edit mode. This can also be useful
 for explicitly setting the data model and not having the changes overwritten
 by the fetch request.
 */
@property (nonatomic) BOOL ignoreIncrementalChanges;

#pragma mark - Configuration information

/**
 The controller's fetch request.
 
 Unlike, NSFetchedResultsController, this property is writeable. After changing
 the fetch request, `performFetch:` must be called to trigger updates.
 */
@property (strong, nonatomic) NSFetchRequest *fetchRequest;

/**
 The managed object context in which the fetch request is performed.
 
 Unlike, NSFetchedResultsController, this property is writeable. After changing
 the fetch request, `performFetch:` must be called to trigger updates.
 */
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 The name of the file used by this classe's internal NSFetchedResultsController to cache
 section information.
 
 Unlike NSFetchedResultsController, this property is writeable. After changing
 the fetch request, `performFetch:` must be called to trigger updates.
 */
@property (strong, nonatomic) NSString *cacheName;

+ (void)deleteCacheWithName:(NSString *)name;

@end
