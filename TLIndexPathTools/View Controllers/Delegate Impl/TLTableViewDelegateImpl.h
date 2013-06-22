//
//  TLTableViewDelegateImpl.h
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

/**
 Minimal implementation of `UITableViewDataSource` & `UITableViewDelegate`. Can
 be set as the delegate and data source directly or other delegates and data sources
 can forward messages (see, for example `TLTableViewController`).
 */

@interface TLTableViewDelegateImpl : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 Client code must set this block before any delegate methods are called. The block
 is responsible for returning the data model for the given tableView.
 */
@property (strong, nonatomic) TLIndexPathDataModel *(^dataModelProvider)(UITableView *tableView);

/**
 The implementation of `tableView:cellForRowAtIndexPath:` calls this method
 to ask for the cell's identifier before attempting to dequeue a cell. The default
 implementation of this method first asks the data model for an identifier and,
 if none is provided, returns the "Cell". Data models that don't use
 `TLIndexPathItem` as their item type typically return `nil` and so it is not
 uncommon to override this method with custom logic.
 */
- (NSString *)tableView:(UITableView *)tableView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;

/*
 This method is intended to be overridden with the cell's configuration logic.
 It is called by by this classes implementation of `tableView:cellForRowAtIndexPath:`
 after the cell has been created/dequeued. The default implementation does nothing.
 
 Alternatively, one can override `tableView:cellForRowAtIndexPath:` and either
 call the super implementation to get the unconfigured cell or or create/dequeue
 the cell directly.
 */
- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns a prototype instance of the specified cell. This can be useful for getting
 basic information about the table view's cells outside of the scope of any specific
 cell. For example, this method is used internally to automatically calculate
 the cell's height in `tableView:heightForRowAtIndexPath:`.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView prototypeForCellIdentifier:(NSString *)cellIdentifier;

@end
