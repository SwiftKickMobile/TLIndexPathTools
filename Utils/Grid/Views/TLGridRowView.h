//
//  TLGridRowView.h
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

#import <UIKit/UIKit.h>
#import "TLGridCellView.h"
#import "TLGridDataModel.h"

@interface TLGridRowView : UIView

@property (nonatomic) NSInteger numberOfColumns;

/**
 Array of numbers defining the columns widths as fractions of the overall
 width. If the numbers do not add up to 1, they will be internally scaled
 them as needed.
 */
@property (strong, nonatomic) NSArray *columnWidths;

/**
 Array of TLGridCells
 */
@property (strong, nonatomic, readonly) NSArray *cells;

/**
 Defines the cell placement boundaries
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 Optional cell factory block. Use this when subclassing TLGridCellView
 */
@property (strong, nonatomic) TLGridCellView *(^newCellView)(NSInteger column);

/**
 Default cell factory method. Set the newCellView property to override.
 */
+ (TLGridCellView *)newCellView;

@end
