//
//  TLGridHeaderCellView.m
//  DealerCarStory
//
//  Created by Tim Moose on 3/26/13.
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

#import "TLGridHeaderCellView.h"

@interface TLGridHeaderCellView ()
@property (nonatomic) BOOL explicitRightView;
@end

@implementation TLGridHeaderCellView

- (void)setRightView:(UIView *)rightView
{
    [super setRightView:rightView];    
    self.explicitRightView = rightView != nil;
}

- (void)setSortDirection:(TLGridColumnSortDirection)sortDirection
{
    if (_sortDirection != sortDirection) {
        _sortDirection = sortDirection;
        [self setNeedsLayout];
    }
}

- (void)setSortable:(BOOL)sortable
{
    if (_sortable != sortable) {
        _sortable = sortable;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    //only control the right view if it hasn't been explicitly
    //set by the client
    if (!self.explicitRightView) {
        if (self.sortable) {
            //set right view based on sort direction
            UIView *rightView;
            switch (self.sortDirection) {
                case TLGridColumnSortDirectionNone:
                    rightView = self.noneSortView;
                    break;
                case TLGridColumnSortDirectionDescending:
                    rightView = self.descendingSortView;
                    break;
                case TLGridColumnSortDirectionAscending:
                    rightView = self.ascendingSortView;
                    break;
                default:
                    break;
            }
            [super setRightView:rightView];
        } else {
            //clear out any residual right view becauase we're not sortable
            [super setRightView:nil];
        }
    }
    
    [super layoutSubviews];
}

@end
