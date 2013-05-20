//
//  TLIndexPathController.m
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"
#import "TLIndexPathUpdates.h"

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
    }
}

@end
