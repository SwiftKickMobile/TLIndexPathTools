//
//  TLIndexPathUpdates.m
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

#import "TLIndexPathUpdates.h"

// TODO need to verify that this works with two data models having different
// configuration properties

@implementation TLIndexPathUpdates


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
                        if (oldIndexPath.row == updatedIndexPath.row) {
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

    //it turns out that reloading modified rows in the main beginUpdates section
    //when there are inserts, deletes, or moves being made results in an exception:
    //
    //  Terminating app due to uncaught exception 'NSInternalInconsistencyException',
    //  reason: 'Attempt to create two animations for cell'
    //
    //this needs to be investigated in more detail. But for the time being, the modified
    //rows will be reloaded here before the main beginUpdates section and we won't
    //use any row animation (because row animation seems to affect the performance
    //of the row animations in the main beginUpdate section).
    if (self.modifiedItems.count) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in self.modifiedItems) {
            NSIndexPath *indexPath = [self.updatedDataModel indexPathForItem:item];
            [indexPaths addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
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
    [self performBatchUpdatesOnCollectionView:collectionView completion:nil];
}

- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView completion:(void(^)(BOOL finished))completion
{
    if (self.oldDataModel.items.count == 0 && self.updatedDataModel.items.count == 0) {
        return;
    }
    
    if (self.oldDataModel.items.count == 0) {
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
        
        // TODO update modified items
    
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];    
}

@end
