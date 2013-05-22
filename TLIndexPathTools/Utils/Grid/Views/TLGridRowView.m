//
//  TLGridRowView.m
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

#import "TLGridRowView.h"

@interface TLGridRowView ()
@property (strong, nonatomic) NSMutableArray *mutableCells;
@end

@implementation TLGridRowView

- (void)setNumberOfColumns:(NSInteger)numberOfColumns
{
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        [_mutableCells removeAllObjects];
        _columnWidths = nil;
        [self setNeedsLayout];
    }
}

- (void)setColumnWidths:(NSArray *)columnWidths
{
    if (columnWidths && columnWidths.count != self.numberOfColumns) {
        [NSException raise:@"Invalid Column Widths" format:@"TODO"];
    }
    if (![_columnWidths isEqualToArray:columnWidths]) {
        _columnWidths = columnWidths;
        [self setNeedsLayout];
    }
}

- (void)setNewCellView:(TLGridCellView *(^)(NSInteger))newCellView
{
    if (_newCellView != newCellView) {
        _newCellView = newCellView;
        [_mutableCells removeAllObjects];
        _columnWidths = nil;
        [self setNeedsLayout];
    }
}

- (NSArray *)cells
{
    if (!_mutableCells) {
        _mutableCells = [[NSMutableArray alloc] initWithCapacity:self.numberOfColumns];
    }
    // Add or remove columns to equal numberOfColumns
    for (int col = _mutableCells.count; col < self.numberOfColumns; col++) {
        TLGridCellView *cell;
        if (self.newCellView) {
            cell = self.newCellView(col);
        }
        if (!cell) {
            cell = [[self class] newCellView];
        }
        [_mutableCells addObject:cell];
        [self addSubview:cell];
    }
    return [_mutableCells copy];
}

+ (TLGridCellView *)newCellView
{
    return [[TLGridCellView alloc] init];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    CGFloat cellHeight = self.bounds.size.height - self.contentInsets.top - self.contentInsets.bottom;
    CGFloat totalWidth = self.bounds.size.width - self.contentInsets.left - self.contentInsets.right;
    
    NSArray *widthFractions = [self internalColumnWidthFractions];

    __block CGFloat startingX = self.contentInsets.left;
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TLGridCellView *cell = obj;
        NSNumber *widthFraction = widthFractions[idx];
        CGFloat width = roundf(totalWidth * [widthFraction floatValue]);
        CGRect frame = CGRectMake(startingX, self.contentInsets.top, width, cellHeight);
        cell.frame = frame;
        startingX += width;
    }];
}

- (NSArray *)internalColumnWidthFractions
{
    NSMutableArray *widths = [[NSMutableArray alloc] initWithCapacity:self.numberOfColumns];
    
    if (self.columnWidths) {
        CGFloat sumExplicitWidths = [[self.columnWidths valueForKeyPath:@"@sum.floatValue"] floatValue];
        for (int col = 0; col < self.numberOfColumns; col++) {
            NSNumber *explicitWidth = self.columnWidths[col];
            [widths addObject:@([explicitWidth floatValue] / sumExplicitWidths)];
        }
    } else {
        // Evenly sized columns
        for (int col = 0; col < self.numberOfColumns; col++) {
            [widths addObject:@((CGFloat) 1 / self.numberOfColumns)];
        }
    }
    
    return widths;    
}

@end
