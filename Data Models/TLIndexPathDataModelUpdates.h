//
//  TLIndexPathDataModelUpdates.h
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import <Foundation/Foundation.h>
#import "TLIndexPathDataModel.h"

// TODO Update modified items in performBatchUpdates

@interface TLIndexPathDataModelUpdates : NSObject
@property (strong, nonatomic, readonly) TLIndexPathDataModel *oldDataModel;
@property (strong, nonatomic, readonly) TLIndexPathDataModel *updatedDataModel;
@property (strong, nonatomic, readonly) NSArray *insertedSectionNames;
@property (strong, nonatomic, readonly) NSArray *deletedSectionNames;
@property (strong, nonatomic, readonly) NSArray *movedSectionNames;
@property (strong, nonatomic, readonly) NSArray *insertedItems;
@property (strong, nonatomic, readonly) NSArray *deletedItems;
@property (strong, nonatomic, readonly) NSArray *movedItems;
@property (strong, nonatomic, readonly) NSArray *modifiedItems;
- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation;
- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView;
- (id)initWithOldDataModel:(TLIndexPathDataModel *)oldDataModel updatedDataModel:(TLIndexPathDataModel *)updatedDataModel;
@end
