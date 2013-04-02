//
//  TLGridHeaderRowView.m
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

#import "TLGridHeaderRowView.h"
#import "TLGridHeaderCellView.h"
#import "TLGridDataModel.h"

@interface TLGridHeaderRowView ()
@property (strong, nonatomic) NSMutableSet *configuredCells;
@end

@implementation TLGridHeaderRowView

- (void)configureWithHeaderItem:(TLGridHeaderItem *)item
{
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TLGridHeaderCellView *cell = obj;
        if (item.sortColumn == idx) {
            cell.sortDirection = item.sortDirection;
        } else {
            cell.sortDirection = TLGridColumnSortDirectionNone;
        }
    }];
}

- (NSArray *)cells
{
    NSArray *cells = super.cells;
    NSMutableSet *configuredCells = [[NSMutableSet alloc] init];
    //add tap recognizer to any cells that haven't been configured yet
    for (UIView *cell in cells) {
        if (![self.configuredCells containsObject:cell]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
            tap.numberOfTapsRequired = 1;
            [cell addGestureRecognizer:tap];
        }
        [configuredCells addObject:cell];
    }
    self.configuredCells = configuredCells;
    return cells;
}

- (void)cellTapped:(UITapGestureRecognizer *)sender
{
    TLGridHeaderCellView *cell = (TLGridHeaderCellView *)sender.view;
    if (self.sortHandler && cell.sortable) {
        NSArray *cells = self.cells;
        NSInteger column = [cells indexOfObject:cell];
        if (column != NSNotFound) {
            self.sortHandler(column);
        }
    }
}

+ (TLGridHeaderCellView *)newCellView
{
    return [[TLGridHeaderCellView alloc] init];
}

@end
