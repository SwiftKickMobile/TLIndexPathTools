//
//  TLTreeDataModel.m
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

#import "TLTreeDataModel.h"
#import "TLIndexPathTreeItem.h"

@implementation TLTreeDataModel

- (instancetype)initWithTreeItems:(NSArray *)treeItems collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers
{
    NSMutableArray *items = [NSMutableArray array];
    for (TLIndexPathTreeItem *item in treeItems) {
        [self flattenTreeItem:item intoArray:items withCollapsedNodeIdentifiers:collapsedNodeIdentifiers];
    }
    if (self = [super initWithItems:items]) {
        _collapsedNodeIdentifiers = collapsedNodeIdentifiers;
        _treeItems = treeItems;
    }
    return self;
}

- (void)flattenTreeItem:(TLIndexPathTreeItem *)item intoArray:(NSMutableArray *)items withCollapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers
{
    if (item) {
        [items addObject:item];
        if (![collapsedNodeIdentifiers containsObject:item.identifier]) {
            for (TLIndexPathTreeItem *childItem in item.childItems) {
                [self flattenTreeItem:childItem intoArray:items withCollapsedNodeIdentifiers:collapsedNodeIdentifiers];
            }
        }
    }
}

@end
