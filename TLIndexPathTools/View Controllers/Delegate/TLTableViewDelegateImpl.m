//
//  TLTableViewDelegateImpl.m
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

#import "TLTableViewDelegateImpl.h"
#import "TLDynamicSizeView.h"
#import "TLIndexPathItem.h"

@interface TLTableViewDelegateImpl ()
@property (strong, nonatomic) NSMutableDictionary *prototypeCells;
@end

@implementation TLTableViewDelegateImpl

#pragma mark - Configuration

- (NSString *)tableView:(UITableView *)tableView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [self.dataModelProvider(tableView) cellIdentifierAtIndexPath:indexPath];
    if (!cellId) {
        cellId = @"Cell";
    }
    return cellId;
}

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Prototypes

- (UITableViewCell *)tableView:(UITableView *)tableView prototypeForCellIdentifier:(NSString *)cellIdentifier
{
    UITableViewCell *cell;
    if (cellIdentifier) {
        cell = [self.prototypeCells objectForKey:cellIdentifier];
        if (!cell) {
            if (!self.prototypeCells) {
                self.prototypeCells = [[NSMutableDictionary alloc] init];
            }
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            //TODO this will fail if multiple tables are being used and they have
            //overlapping identifiers. The key needs to be unique to the table
            [self.prototypeCells setObject:cell forKey:cellIdentifier];
        }
    }
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataModelProvider(tableView) numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModelProvider(tableView) numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [self tableView:tableView cellIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataModelProvider(tableView) sectionTitleForSection:section];
}

/**
 Automatically calculate cell height by retrieving a prototype and either a)
 returning the existing height or b) if the cell implements the `TLDynamicHeightView`
 protocol, returning the value of sizeWithData:. For (b), the data passed to the
 cell will be the item returned by the data model or, if the item is an instance
 of `TLIndexPathItem`, the value of the item's `data` property.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.dataModelProvider(tableView) itemAtIndexPath:indexPath];
    NSString *cellId = [self tableView:tableView cellIdentifierAtIndexPath:indexPath];
    if (cellId) {
        UITableViewCell *cell = [self tableView:tableView prototypeForCellIdentifier:cellId];
        if ([cell conformsToProtocol:@protocol(TLDynamicSizeView)]) {
            id<TLDynamicSizeView> v = (id<TLDynamicSizeView>)cell;
            id data;
            if ([item isKindOfClass:[TLIndexPathItem class]]) {
                TLIndexPathItem *i = (TLIndexPathItem *)item;
                data = i.data;
            } else {
                data = item;
            }
            CGSize computedSize = [v sizeWithData:data];
            return computedSize.height;
        } else {
            return cell.bounds.size.height;
        }
    }
    
    return 44.0;
}

@end
