//
//  TLGridHeaderRowView.h
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
#import "TLGridHeaderItem.h"
#import "TLGridRowView.h"
#import "TLGridHeaderCellView.h"

@interface TLGridHeaderRowView : TLGridRowView

/**
 Sort callback. When called the app should sort and update the data model.
 */
@property (strong, nonatomic) void(^sortHandler)(NSInteger column);

/**
 Optional cell factory block. Use this when subclassing TLGridHeaderCellView
 */
@property (strong, nonatomic) TLGridHeaderCellView *(^newCellView)(NSInteger column);

/**
 */
- (void)configureWithHeaderItem:(TLGridHeaderItem *)item;

/**
 Default cell factory method. Set the newCellView property to override.
 */
+ (TLGridHeaderCellView *)newCellView;

@end
