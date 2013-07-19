//
//  TLTreeTableViewController.m
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

#import "TLTreeTableViewController.h"
#import "UITableViewController+ScrollOptimizer.h"

@interface TLTreeTableViewController ()
@end

@implementation TLTreeTableViewController

- (TLTreeDataModel *)dataModel {
    return (TLTreeDataModel *)self.indexPathController.dataModel;
}

- (void)setDataModel:(TLTreeDataModel *)dataModel
{
    self.indexPathController.dataModel = dataModel;
}

//- (void)addItem:(TLIndexPathTreeItem *)item
//{
//    TLIndexPathTreeItem *oldItem = [self.indexPathController.dataModel itemForIdentifier:item.identifier];
//    NSMutableArray *items = [NSMutableArray arrayWithArray:self.indexPathController.dataModel.items];
//    NSInteger index = [items indexOfObject:oldItem];
//    if (index == NSNotFound) {
//        [items addObject:item];
//    } else {
//        [items replaceObjectAtIndex:index withObject:item];
//    }
//    
//    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:items
//                                       collapsedNodeIdentifiers:self.dataModel.collapsedNodeIdentifiers];
//}

#pragma mark - Manipulating the tree

- (void)setNewVersionOfItem:(TLIndexPathTreeItem *)item
{
    if ([self.dataModel itemForIdentifier:item.identifier]) {
        NSArray *treeItems = [self rebuildTreeItems:self.dataModel.treeItems withNewVersionOfItem:item];
        self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:treeItems
                                           collapsedNodeIdentifiers:self.dataModel.collapsedNodeIdentifiers];
    }
}

- (NSArray *)rebuildTreeItems:(NSArray *)treeItems withNewVersionOfItem:(TLIndexPathTreeItem *)newVersionOfItem
{
    NSMutableArray *newTreeItems = [[NSMutableArray alloc] initWithCapacity:treeItems.count];
    for (TLIndexPathTreeItem *item in treeItems) {
        if ([newVersionOfItem.identifier isEqual:item.identifier]) {
            [newTreeItems addObject:newVersionOfItem];
        } else {
            NSArray *newChildItems = [self rebuildTreeItems:item.childItems withNewVersionOfItem:newVersionOfItem];
            TLIndexPathTreeItem *newItem = [item copyWithChildren:newChildItems];
            [newTreeItems addObject:newItem];
        }
    }
    return newTreeItems;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathTreeItem *item = [self.dataModel itemAtIndexPath:indexPath];
    NSMutableSet *collapsedNodeIdentifiers = [NSMutableSet setWithSet:self.dataModel.collapsedNodeIdentifiers];
    //`collapsed` represents the __new__ state
    BOOL collapsed = ![collapsedNodeIdentifiers containsObject:item.identifier];

    TLIndexPathTreeItem *newItem;
    if ([self.delegate respondsToSelector:@selector(controller:willChangeNode:collapsed:)]) {
        newItem = [self.delegate controller:self willChangeNode:item collapsed:collapsed];
    }
    NSArray *treeItems;
    if ([self.dataModel itemForIdentifier:newItem.identifier]) {
        treeItems = [self rebuildTreeItems:self.dataModel.treeItems withNewVersionOfItem:newItem];
    } else {
        treeItems = self.dataModel.treeItems;
    }
    
    if (collapsed == NO) {
        [collapsedNodeIdentifiers removeObject:item.identifier];
        for (TLIndexPathTreeItem *child in item.childItems) {
            //use the convention that `childItems==nil` indicates a leaf node
            if (child.childItems) {
                [collapsedNodeIdentifiers addObject:child.identifier];
            }
        }
    } else {
        for (TLIndexPathTreeItem *child in item.childItems) {
            [collapsedNodeIdentifiers removeObject:child.identifier];
        }
        [collapsedNodeIdentifiers addObject:item.identifier];
    }

    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:treeItems
                                       collapsedNodeIdentifiers:collapsedNodeIdentifiers];
    
    if ([self.delegate respondsToSelector:@selector(controller:didChangeNode:collapsed:)]) {
        [self.delegate controller:self didChangeNode:item collapsed:collapsed];
    }

//TODO redesign scroll optimizer to work with tree controller
//    if (!collapsed) {
//        UIView *headerView = [tableView cellForRowAtIndexPath:indexPath];
//        [self optimizeScrollPositionForSection:indexPath.section
//                                    headerView:headerView
//                                     dataModel:self.dataModel
//                                      animated:YES];
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
