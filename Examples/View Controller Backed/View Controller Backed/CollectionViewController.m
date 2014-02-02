//
//  CollectionViewController.m
//  View Controller Backed
//
//  Created by Tim Moose on 2/2/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import "CollectionViewController.h"
#import "CellViewController.h"

/**
 Demonstrates view controller-backed cells, which are enabled by overriding
 `-[TLCollectionViewController collectionView:instantiateViewControllerForCell:atIndexPath:].
 */

@implementation CollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *items = @[
           @"Item 1",
           @"Item 2",
           @"Item 3",
           @"Item 4",
           @"Item 5",
           ];
    self.indexPathController.items = items;
}

- (UIViewController *)collectionView:(UICollectionView *)collectionView instantiateViewControllerForCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CellViewController *controller = (CellViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CellController"];
    controller.view.frame = cell.bounds;
    // add controller's view to the cell. Don't do this in `cellForItemAtIndexpath` because it only
    // needs to be done once for a given cell.
    [cell addSubview:controller.view];
    return controller;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    // retrieve the view controller for the given cell. Note that `TLCollectionViewController` keeps
    // track of this internally, so custom code does not need to do this bookkeeping.
    CellViewController *controller = (CellViewController *)[self collectionView:collectionView viewControllerForCell:cell];
    NSString *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    controller.label.text = item;
    return cell;
}

@end
