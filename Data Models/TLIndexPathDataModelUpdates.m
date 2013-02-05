//
//  TLIndexPathDataModelUpdates.m
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import "TLIndexPathDataModelUpdates.h"

@implementation TLIndexPathDataModelUpdates


- (id)initWithOldDataModel:(TLIndexPathDataModel *)oldDataModel updatedDataModel:(TLIndexPathDataModel *)updatedDataModel
{
    if (self = [super init]) {
        
        _oldDataModel = oldDataModel;
        _updatedDataModel = updatedDataModel;
        
        NSMutableArray *insertedSectionNames = [[NSMutableArray alloc] init];
        NSMutableArray *deletedSectionNames = [[NSMutableArray alloc] init];
        NSMutableArray *movedSectionNames = [[NSMutableArray alloc] init];
        NSMutableArray *insertedItems = [[NSMutableArray alloc] init];
        NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
        NSMutableArray *movedItems = [[NSMutableArray alloc] init];
        NSMutableArray *modifiedItems = [[NSMutableArray alloc] init];

        _insertedSectionNames = insertedSectionNames;
        _deletedSectionNames = deletedSectionNames;
        _movedSectionNames = movedSectionNames;
        _insertedItems = insertedItems;
        _deletedItems = deletedItems;
        _movedItems = movedItems;
        _modifiedItems = modifiedItems;
        
        NSOrderedSet *oldSectionNames = [NSOrderedSet orderedSetWithArray:oldDataModel.sectionNames];
        NSOrderedSet *updatedSectionNames = [NSOrderedSet orderedSetWithArray:updatedDataModel.sectionNames];
        
        // Deleted and moved sections        
        for (NSString *sectionName in oldSectionNames) {
            if ([updatedSectionNames containsObject:sectionName]) {
                NSInteger oldSection = [oldDataModel sectionForSectionName:sectionName];
                NSInteger updatedSection = [updatedDataModel sectionForSectionName:sectionName];
                // TODO Not sure if this is correct when moves are combined with inserts and/or deletes
                if (oldSection != updatedSection) {
                    [movedSectionNames addObject:sectionName];
                }
            } else {
                [deletedSectionNames addObject:sectionName];
            }
        }
        
        // Inserted sections
        for (NSString *sectionName in updatedSectionNames) {
            if (![oldSectionNames containsObject:sectionName]) {
                [insertedSectionNames addObject:sectionName];
            }
        }
        
        // Deleted and moved items
        NSOrderedSet *oldItems = [NSOrderedSet orderedSetWithArray:[oldDataModel items]];        
        for (id item in oldItems) {
            NSIndexPath *oldIndexPath = [oldDataModel indexPathForItem:item];
            NSString *sectionName = [oldDataModel sectionNameForSection:oldIndexPath.section];
            if ([updatedDataModel containsItem:item]) {
                NSIndexPath *updatedIndexPath = [updatedDataModel indexPathForItem:item];
                if (![oldIndexPath isEqual:updatedIndexPath]) {
                    // Don't move items in moved sections
                    if (![movedSectionNames containsObject:sectionName]) {
                        // TODO Not sure if this is correct when moves are combined with inserts and/or deletes
                        // Don't report as moved if the only change is the section
                        // has moved
                        if (oldIndexPath.item == updatedIndexPath.item) {
                            NSString *oldSectionName = [oldDataModel sectionNameForSection:oldIndexPath.section];
                            NSString *updatedSectionName = [updatedDataModel sectionNameForSection:updatedIndexPath.section];
                            if ([oldSectionName isEqualToString:updatedSectionName]) continue;
                        }
                        [movedItems addObject:item];
                    }
                }
            } else {
                // Don't delete items in deleted sections
                if (![deletedSectionNames containsObject:sectionName]) {
                    [deletedItems addObject:item];
                }
            }
        }
        
        // Inserted and modified items
        NSOrderedSet *updatedItems = [NSOrderedSet orderedSetWithArray:[updatedDataModel items]];
        for (id item in updatedItems) {
            id oldItem = [oldDataModel currentVersionOfItem:item];
            if (oldItem) {
                if (![oldItem isEqual:item]) {
                    [modifiedItems addObject:item];
                }
            } else {
                NSIndexPath *updatedIndexPath = [updatedDataModel indexPathForItem:item];
                NSString *sectionName = [updatedDataModel sectionNameForSection:updatedIndexPath.section];
                // Don't insert items in inserted sections
                if (![insertedSectionNames containsObject:sectionName]) {
                    [insertedItems addObject:item];
                }
            }
        }
    }
    
    return self;
}

- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!self.oldDataModel) {
        [tableView reloadData];
        return;
    }
    
    [tableView beginUpdates];

    if (self.insertedSectionNames.count) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSString *sectionName in self.insertedSectionNames) {
            NSInteger section = [self.updatedDataModel sectionForSectionName:sectionName];
            [indexSet addIndex:section];
        }
        [tableView insertSections:indexSet withRowAnimation:animation];
    }

    if (self.deletedSectionNames.count) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSString *sectionName in self.deletedSectionNames) {
            NSInteger section = [self.oldDataModel sectionForSectionName:sectionName];
            [indexSet addIndex:section];
        }
        [tableView deleteSections:indexSet withRowAnimation:animation];
    }

// TODO Disable reordering sections because it may cause duplicate animations
// when a item is inserted, deleted, or moved in that section. Need to figure
// out how to avoid the duplicate animation.
//    if (self.movedSectionNames.count) {
//        for (NSString *sectionName in self.movedSectionNames) {
//            NSInteger oldSection = [self.oldDataModel sectionForSectionName:sectionName];
//            NSInteger updatedSection = [self.updatedDataModel sectionForSectionName:sectionName];
//            [tableView moveSection:oldSection toSection:updatedSection];
//        }
//    }
    
    if (self.insertedItems.count) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in self.insertedItems) {
            NSIndexPath *indexPath = [self.updatedDataModel indexPathForItem:item];
            [indexPaths addObject:indexPath];
        }
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }

    if (self.deletedItems.count) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in self.deletedItems) {
            NSIndexPath *indexPath = [self.oldDataModel indexPathForItem:item];
            [indexPaths addObject:indexPath];
        }
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }

    if (self.movedItems.count) {
        for (id item in self.movedItems) {
            NSIndexPath *oldIndexPath = [self.oldDataModel indexPathForItem:item];
            NSIndexPath *updatedIndexPath = [self.updatedDataModel indexPathForItem:item];
            [tableView moveRowAtIndexPath:oldIndexPath toIndexPath:updatedIndexPath];
        }
    }

    [tableView endUpdates];
}

- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView
{
    if (!self.oldDataModel) {
        [collectionView reloadData];
        return;
    }

    [collectionView performBatchUpdates:^{

        if (self.insertedSectionNames.count) {
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (NSString *sectionName in self.insertedSectionNames) {
                NSInteger section = [self.updatedDataModel sectionForSectionName:sectionName];
                [indexSet addIndex:section];
            }
            [collectionView insertSections:indexSet];
        }
        
        if (self.deletedSectionNames.count) {
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (NSString *sectionName in self.deletedSectionNames) {
                NSInteger section = [self.oldDataModel sectionForSectionName:sectionName];
                [indexSet addIndex:section];
            }
            [collectionView deleteSections:indexSet];
        }
        
        if (self.movedSectionNames.count) {
            for (NSString *sectionName in self.movedSectionNames) {
                NSInteger oldSection = [self.oldDataModel sectionForSectionName:sectionName];
                NSInteger updatedSection = [self.updatedDataModel sectionForSectionName:sectionName];
                [collectionView moveSection:oldSection toSection:updatedSection];
            }
        }
        
        if (self.insertedItems.count) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (id item in self.insertedItems) {
                NSIndexPath *indexPath = [self.updatedDataModel indexPathForItem:item];
                [indexPaths addObject:indexPath];
            }
            [collectionView insertItemsAtIndexPaths:indexPaths];
        }
        
        if (self.deletedItems.count) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (id item in self.deletedItems) {
                NSIndexPath *indexPath = [self.oldDataModel indexPathForItem:item];
                [indexPaths addObject:indexPath];
            }
            [collectionView deleteItemsAtIndexPaths:indexPaths];
        }
        
        if (self.movedItems.count) {
            for (id item in self.movedItems) {
                NSIndexPath *oldIndexPath = [self.oldDataModel indexPathForItem:item];
                NSIndexPath *updatedIndexPath = [self.updatedDataModel indexPathForItem:item];
                [collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:updatedIndexPath];
            }
        }
    
    } completion:^(BOOL finished) {
        // Completion
    }];    
}

@end
