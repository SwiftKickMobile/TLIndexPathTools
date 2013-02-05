//
//  TLInMemoryFetchedResultsController.h
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TLIndexPathDataModelUpdates.h"

@class TLInMemoryFetchedResultsController;

@protocol TLInMemoryFetchedResultsControllerDelegate <NSFetchedResultsControllerDelegate>
@optional
- (void)controller:(TLInMemoryFetchedResultsController *)controller didChangeContentWithUpdates:(TLIndexPathDataModelUpdates *)updates;
@end

@interface TLInMemoryFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate>
@property(nonatomic, weak) id <NSFetchedResultsControllerDelegate> delegate;
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@property (strong, nonatomic, readonly) NSArray *coreDataFetchedObjects;
@property (strong, nonatomic) NSPredicate *inMemoryPredicate;
@property (strong, nonatomic) NSArray *inMemorySortDescriptors;
@property (nonatomic) BOOL isFetched;
- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name;
- (void)performBatchChanges:(void (^)(void))changes completion:(void (^)(BOOL finished))completion;
@end
