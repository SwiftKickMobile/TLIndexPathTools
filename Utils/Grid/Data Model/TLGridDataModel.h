//
//  TLGridDataModel.h
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

#import "TLIndexPathDataModel.h"

typedef NS_ENUM(NSInteger, TLGridColumnSortDirection) {
    TLGridColumnSortDirectionNone,
    TLGridColumnSortDirectionDescending,
    TLGridColumnSortDirectionAscending,
};

@class TLGridHeaderItem;

@interface TLGridDataModel : TLIndexPathDataModel

/**
 */
@property (nonatomic) NSInteger numberOfColumns;

/**
 */
@property (nonatomic, readonly) NSInteger sortColumn;

/**
 */
@property (nonatomic, readonly) TLGridColumnSortDirection sortDirection;

/**
 */
@property (strong, nonatomic, readonly) TLGridHeaderItem *headerItem;

/**
 */
@property (strong, nonatomic, readonly) NSArray *rowItems;

/**
 */
- (id)initWithHeaderItem:(TLGridHeaderItem *)headerItem RowItems:(NSArray *)rowItems;

@end
