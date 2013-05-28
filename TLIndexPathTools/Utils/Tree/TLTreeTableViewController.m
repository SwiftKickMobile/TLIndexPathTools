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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathTreeItem *item = [self.dataModel itemAtIndexPath:indexPath];
    NSMutableSet *collapsedNodeIdentifiers = [NSMutableSet setWithSet:self.dataModel.collapsedNodeIdentifiers];
    BOOL collapsed = NO;
    if ([collapsedNodeIdentifiers containsObject:item.identifier]) {
        [collapsedNodeIdentifiers removeObject:item.identifier];
        for (TLIndexPathTreeItem *child in item.childItems) {
            if (child.childItems.count) {
                [collapsedNodeIdentifiers addObject:child.identifier];
            }
        }
    } else {
        for (TLIndexPathTreeItem *child in item.childItems) {
            [collapsedNodeIdentifiers removeObject:child.identifier];
        }
        [collapsedNodeIdentifiers addObject:item.identifier];
        collapsed = YES;
    }
    
    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:self.dataModel.treeItems
                                       collapsedNodeIdentifiers:collapsedNodeIdentifiers];
    
    if ([self.delegate respondsToSelector:@selector(controller:didChangeNode:collapsed:)]) {
        [self.delegate controller:self didChangeNode:item.identifier collapsed:collapsed];
    }
    
    if (!collapsed) {
        UIView *headerView = [tableView cellForRowAtIndexPath:indexPath];
        [self optimizeScrollPositionForSection:indexPath.section
                                    headerView:headerView
                                     dataModel:self.dataModel
                                      animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
