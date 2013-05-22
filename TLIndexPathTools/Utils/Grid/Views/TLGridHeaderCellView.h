//
//  TLGridHeaderCellView.h
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

#import "TLGridCellView.h"
#import "TLGridDataModel.h"

@interface TLGridHeaderCellView : TLGridCellView

/**
 If YES, the cell will report taps to the through the TLGridHeaderRowView's
 sortHandler callback. It is up to the client code to update the data model
 and set the sortDirection property.
 */
@property (nonatomic) BOOL sortable;

/**
 The current sort direction of this column. It is up to the client code to
 sort the data model and set this property accordingly. See also sortable.
 */
@property (nonatomic) TLGridColumnSortDirection sortDirection;

/**
 If set and sortable is YES, this view will be displayed to the right of the
 label when sortDirection is TLGridColumnSortDirectionNone
 */
@property (strong, nonatomic) UIView *noneSortView;

/**
 If set and sortable is YES, this view will be displayed to the right of the
 label when sortDirection is TLGridColumnSortDirectionAscending
 */
@property (strong, nonatomic) UIView *ascendingSortView;

/**
 If set and sortable is YES, this view will be displayed to the right of the
 label when sortDirection is TLGridColumnSortDirectionDescending
 */
@property (strong, nonatomic) UIView *descendingSortView;

@end
