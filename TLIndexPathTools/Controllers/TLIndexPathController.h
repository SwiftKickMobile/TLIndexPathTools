//
//  TLIndexPathController.h
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

#import <Foundation/Foundation.h>

#import "TLIndexPathDataModel.h"
#import "TLIndexPathUpdates.h"

//sent whenever a TLIndexPathController changes it's content for any reason
extern NSString * const TLIndexPathControllerChangedNotification;

@class TLIndexPathController;

#pragma mark - TLIndexPathControllerDelegate

/**
 An instance of `TLIndexPathController` uses this protocol to notify it's delegate
 about batch changes to the data model, providing access to the `TLIndexPathDataModelUpdates`
 instance which can be uses to perform batch updates on a table or collection view.
 */
@protocol TLIndexPathControllerDelegate <NSObject>

@optional

/**
 Notifies the reciever of batch data model changes.
 
 @param controller  the index path controller that sent the message.
 @param updates  the updates object that can be used to perform batch updates on a table or collection view.
 */
- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates;

@end

@interface TLIndexPathController : NSObject <NSFetchedResultsControllerDelegate>

#pragma mark - Initialization

/**
 Returns an index path controller initialized with the given items.
 
 @param items  the aray of items
 @return the index path controller with a default data model representation of the given items
 
 A default data model is initialized with items where the properties `identifierKeyPath`,
 `sectionNameKeyPath` are all `nil`. If any of these are required, use `initWithDataModel:` instead.
 */
- (instancetype)initWithItems:(NSArray *)items;

/**
 Returns an index path controller initialized with the given data model.
 
 @param dataModel  the data model
 @return the index path controller with the given data model representation
 */
- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel;

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
- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name;

#pragma mark - Configuration information

/**
 The controller's delegate.
 */
@property (weak, nonatomic) id<TLIndexPathControllerDelegate>delegate;

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

/**
 Determines whether data model changes are ignored.
 
 This property can be set to YES to prevent calling the `didUpdateDataModel`
 delegate method when the data model changes. This can be useful if the view
 controller wants to reload the table without animation by calling `reloadData`,
 rather than having the batch updates performed.
 */
@property (nonatomic) BOOL ignoreDataModelChanges;

#pragma mark - Accessing data

/**
 The items being tracked by the controller.
 
 Setting this property causes a new data model to be created and any changes propagated
 to the controller's delegate. This new data model preserves the configuration of
 the previous data model. The type of items need not necessarily be the same
 as the previous data model, provided they are consistent with the configuration,
 such as `indetifierKeyPath`. If the new data model requires a different configuration,
 set the `dataModel` property directly.
 */
@property (strong, nonatomic) NSArray *items;

/**
 The data model representation of the items being tracked by the controller.
 
 Setting this property causes the any changes to be propagated to the controller's
 delegate. The type of items and configuration of the new data model need not
 necessarily be the same as the previous data model, provided that the controller's
 delegate is prepared to handle the changes.
 */
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;

#pragma mark - Batch updates

/**
 Allows for making multiple changes to the controller with only a single
 controller:didUpdateDataModel: delegate callback. For example, change the
 fetch request (and perform fetch), in-memory sort descriptors, and in-memory
 predicate as a single update.
 
 @param udpates  a block that makes changes to the controller
 @param completion  a block to be executed after the batch updates are performed.
        Note that controller:didUpdateDataModel: is called before this block.
 
 This method is not to be confused with table or collection view batch udpates.
 It is strickly for batch changes to this controller (which may result in batch
 updates happening to the table or collection view through the delegate method).
 */
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

#pragma mark - Core Data Integration

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
 
 This property can be set to YES to temporarily ignore incremental fetched
 results changes, such as when a table is in edit mode. This can also be useful
 for explicitly setting the data model and not having the changes overwritten
 by the fetch request.
 */
@property (nonatomic) BOOL ignoreFetchedResultsChanges;

/**
 Returns the underlying core data fetched objects without the application of in-memory
 filtering or sorting.
 */
@property (strong, nonatomic, readonly) NSArray *coreDataFetchedObjects;

/**
 The in-memory predicate.
 
 This optional predicate will be evaluated in-memory against the underlying fetched
 result. If the controller is already fetched, it is not necessary to call
 `performFetch:` again after setting this property because the batch updates
 are processed immediately.
 */
@property (strong, nonatomic) NSPredicate *inMemoryPredicate;

/**
 The in-memory sort descriptors.
 
 These optional sort descriptors will be applied in-memory against the
 underlying fetched result. If the controller is already fetched, it is not necessary
 to call `performFetch:` again after setting this property because the batch
 updates are processed immediately.
 */
@property (strong, nonatomic) NSArray *inMemorySortDescriptors;

@end
