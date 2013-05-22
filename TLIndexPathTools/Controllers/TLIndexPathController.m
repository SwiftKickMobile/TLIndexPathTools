//
//  TLIndexPathController.m
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

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"
#import "TLIndexPathUpdates.h"

NSString * const TLIndexPathControllerChangedNotification = @"TLIndexPathControllerChangedNotification";

@implementation TLIndexPathController

#pragma mark - Initilization

- (instancetype)initWithItems:(NSArray *)items
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:items andSectionNameKeyPath:nil andIdentifierKeyPath:nil];
    return [self initWithDataModel:dataModel];
}

- (instancetype)initWithIndexPathItems:(NSArray *)items
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithIndexPathItems:items];
    return [self initWithDataModel:dataModel];
}

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel
{
    if (self = [super init]) {
        _dataModel = dataModel;
    }
    return self;
}

#pragma mark - Accessing data

- (NSArray *)items
{
    return self.dataModel.items;
}

- (void)setItems:(NSArray *)items
{
    if (![self.items isEqualToArray:items]) {
        id last = [items lastObject];
        TLIndexPathDataModel *dataModel;
        if ([last isKindOfClass:[TLIndexPathItem class]]) {
            dataModel = [[TLIndexPathDataModel alloc] initWithIndexPathItems:items];
        } else {
            dataModel = [[TLIndexPathDataModel alloc] initWithItems:items
                                              andSectionNameKeyPath:self.dataModel.sectionNameKeyPath
                                               andIdentifierKeyPath:self.dataModel.identifierKeyPath
                                           andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
        }
        self.dataModel = dataModel;
    }
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel
{
    if (![_dataModel isEqual:dataModel]) {
        TLIndexPathDataModel *oldDataModel = _dataModel;
        _dataModel = dataModel;
        if ([self.delegate respondsToSelector:@selector(controller:didUpdateDataModel:)]) {
            TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:dataModel];
            [self.delegate controller:self didUpdateDataModel:updates];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TLIndexPathControllerChangedNotification object:self];
    }
}

@end
