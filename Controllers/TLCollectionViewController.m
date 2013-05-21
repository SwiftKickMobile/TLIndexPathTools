//
//  TLCollectionViewController.m
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

#import "TLCollectionViewController.h"

@interface TLCollectionViewController ()
@property (strong, nonatomic, readonly) TLIndexPathDataModel *dataModel;
@end

@implementation TLCollectionViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

#pragma mark - Index path controller

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    if (_indexPathController != indexPathController) {
        _indexPathController = indexPathController;
        _indexPathController.delegate = self;
        [self.collectionView reloadData];
    }
}

- (TLIndexPathDataModel *)dataModel
{
    return self.indexPathController.dataModel;
}

#pragma mark - Configuration

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)reconfigureVisibleCells
{
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self configureCell:cell atIndexPath:indexPath];
    }
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataModel cellIdentifierAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataModel numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataModel numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.dataModel cellIdentifierAtIndexPath:indexPath];
    if (!identifier) {
        identifier = @"Cell";
    }
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnCollectionView:self.collectionView];
}

@end
