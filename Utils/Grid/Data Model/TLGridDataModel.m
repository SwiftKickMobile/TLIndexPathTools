//
//  TLGridDataModel.m
//  DealerCarStory
//
//  Created by Tim Moose on 3/14/13.
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

#import "TLGridDataModel.h"
#import "TLGridItem.h"
#import "TLGridHeaderItem.h"

@implementation TLGridDataModel

- (NSArray *)items
{
    return [super items];
}

- (NSInteger)sortColumn
{
    return self.headerItem ? self.headerItem.sortColumn : NSNotFound;
}

- (TLGridColumnSortDirection)sortDirection
{
    return self.headerItem.sortDirection;
}

- (id)initWithHeaderItem:(TLGridHeaderItem *)headerItem RowItems:(NSArray *)rowItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:rowItems.count + 1];
    if (headerItem) {
        [items addObject:headerItem];
    }
    [items addObjectsFromArray:rowItems];
    if (self = [super initWithIndexPathItems:items]) {
        _headerItem = headerItem;
        _rowItems = rowItems;
    }
    //set number of columns equal to the max number of columns across all items
    _numberOfColumns = 0;
    for (TLGridItem *item in items) {
        _numberOfColumns = MAX(_numberOfColumns, item.numberOfColumns);
    }
    return self;
}

@end
