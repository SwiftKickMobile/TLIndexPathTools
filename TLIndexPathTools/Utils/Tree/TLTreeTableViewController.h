//
//  TLTreeTableViewController.h
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

#import "TLTableViewController.h"
#import "TLTreeDataModel.h"
#import "TLIndexPathTreeItem.h"

@class TLTreeTableViewController;

@protocol TLTreeTableViewControllerDelegate <NSObject>
@optional
- (void)controller:(TLTreeTableViewController *)controller didChangeNode:(TLIndexPathTreeItem *)treeItem collapsed:(BOOL)collapsed;
@end

@interface TLTreeTableViewController : TLTableViewController

@property (weak, nonatomic) id<TLTreeTableViewControllerDelegate>delegate;

/**
 A type-safe shortcut for getting and setting the tree data model on the
 underlying index path controller.
 */
@property (strong, nonatomic) TLTreeDataModel *dataModel;

@end
