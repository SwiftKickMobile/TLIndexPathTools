//
//  TLTreeDataModel.h
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

/**
 Data model representing the current state of a tree of `TLIndexPathTreeItems`
 based on the given set of collapsed node identifiers. This class must be initialized
 using one of the two initializers defined here providing an array of top level
 `TLIndexPathTreeItems` (or an array of `TLIndexPathSectionInfos` containing top
 level items) and the current set of collapsed node identifiers. These initializers
 generate the flat array of items (or sections of items) to be displayed in the table.
 This flattened data is passed up to the `TLIndexPathDataModel` initializer and, thus,
 the data model APIs reflect only the data that is currently displayed in the table.
 The full tree item data is retained in the `treeItems` and `treeItemSections`
 properties.
 
 This data model can be plugged into a `TLTableViewController`, but
 the `TLTreeTableViewController` contains the additional logic to manage the set
 of collapsed nodes and udpate the data model as nodes are expanded and collapsed.
 It also provides a mechanism to lazy load nodes.
 */

#import "TLIndexPathDataModel.h"

@interface TLTreeDataModel : TLIndexPathDataModel
@property (copy, nonatomic, readonly) NSArray *collapsedNodeIdentifiers;
@property (copy, nonatomic, readonly) NSArray *treeItems;
@property (copy, nonatomic, readonly) NSArray *treeItemSections;
- (instancetype)initWithTreeItems:(NSArray *)treeItems collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers;
- (instancetype)initWithTreeItemSections:(NSArray *)treeItemSections collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers;
@end
