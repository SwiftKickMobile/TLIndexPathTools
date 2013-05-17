//
//  TLFetchedResultsController.h
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import <CoreData/CoreData.h>

#import "TLIndexPathController.h"

@interface TLFetchedResultsController : TLIndexPathController

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

/**
 Calling this method executes the fetch request and causes a new data model to be
 created with the fetch result and any changes propagated to the controller's
 delegate. Unlike NSFetchedResultsController, repeated calls to this method will
 continue to propagate batch changes. This makes it possible to modify the fetch
 request's predicate and/or sort descriptors and have the new fetch result be
 propagated as batch changes.
 */
- (void)performFetch;

#pragma mark - Configuration information

/**
 The controller's fetch request.
 
 Unlike, NSFetchedResultsController, this property is writeable. Once changed,
 calling `performFetch` causes a new data model to be created and any changes propagated to
 the controller's delegate.
 */
@property (nonatomic) NSFetchRequest *fetchRequest;

/**
 The managed object context in which the fetch request is performed.
 
 Unlike, NSFetchedResultsController, this property is writeable. Once changed,
 calling `performFetch` causes a new data model to be created and any changes propagated to
 the controller's delegate.
 */
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly) NSString *cacheName;

+ (void)deleteCacheWithName:(NSString *)name;

@end
