//
//  TLIndexPathUpdates.h
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

#import <UIKit/UIKit.h>
#import "TLIndexPathDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Takes two versions of a data model and computes the changes, i.e. the inserts,
 moves, deletes and modifications. A variety of `performBatchUpdatesOn*` methods
 are provided for performing batch updates on the table or collection view.
 */

@interface TLIndexPathUpdates : NSObject

#pragma mark - Creating updates

/**
 * Takes two versions of a data model and computes the changes, i.e. the inserts,
 * moves, deletes and modifications.
 *
 * @param oldDataModel                The previous data model.
 * @param updatedDataModel            The updated data model.
 * @return A newly initialized TLIndexPathUpdates object.
 * @see initWithOldDataModel:updatedDataModel:modificationComparatorBlock:
 */
- (id)initWithOldDataModel:(TLIndexPathDataModel * __nullable)oldDataModel updatedDataModel:(TLIndexPathDataModel * __nullable)updatedDataModel;

/**
 * Takes two versions of a data model and computes the changes, i.e. the inserts,
 * moves, deletes and modifications.
 *
 * @param oldDataModel                The previous data model.
 * @param updatedDataModel            The updated data model.
 * @param modificationComparatorBlock A block which is used to determine if an old data model object has been modified. This is passed two objects and should return `NO` if the objects are to be considered the same, or `YES` if modifications have occurred. This block can be `nil`.
 *
 * @return A newly initialized TLIndexPathUpdates object.
 * @see initWithOldDataModel:updatedDataModel:
 */
- (id)initWithOldDataModel:(TLIndexPathDataModel * __nullable)oldDataModel updatedDataModel:(TLIndexPathDataModel * __nullable)updatedDataModel modificationComparatorBlock:(BOOL(^ __nullable)(id item1, id item2))modificationComparatorBlock;

#pragma mark - Performing batch updates

- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation;
- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation completion:(void(^  __nullable)(BOOL finished))completion;
- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView;
- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView completion:(void(^ __nullable)(BOOL finished))completion;

#pragma mark - Customizing batch update behavior

/*
 If `NO`, modified items will be ignored in the `performBatchUpdates*` methods.
 This can be useful for updating modified items with custom animation.
 Default value is `YES`.
 */
@property (nonatomic) BOOL updateModifiedItems;

#pragma mark - Comparing data models

@property (strong, readonly, nonatomic, nullable) TLIndexPathDataModel *oldDataModel;
@property (strong, readonly, nonatomic, nullable) TLIndexPathDataModel *updatedDataModel;
@property (readonly, nonatomic) BOOL hasChanges;
@property (copy, readonly, nonatomic) NSArray<NSString *> *insertedSectionNames;
@property (copy, readonly, nonatomic) NSArray<NSString *> *deletedSectionNames;
@property (copy, readonly, nonatomic) NSArray<NSString *> *movedSectionNames;
@property (copy, readonly, nonatomic) NSArray *insertedItems;
@property (copy, readonly, nonatomic) NSArray *deletedItems;
@property (copy, readonly, nonatomic) NSArray *movedItems;
@property (copy, readonly, nonatomic) NSArray *modifiedItems;
@end

NS_ASSUME_NONNULL_END
