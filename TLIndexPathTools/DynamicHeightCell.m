//
//  DynamicHeightCell.m
//  Dynamic Height
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "DynamicHeightCell.h"

@interface DynamicHeightCell ()
@property (nonatomic) CGSize originalSize;
@property (nonatomic) CGSize originalLabelSize;
@end

@implementation DynamicHeightCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.originalSize = self.bounds.size;
    self.originalLabelSize = self.label.bounds.size;
}

#pragma mark - TLDynamicSizeView

- (CGSize)sizeWithData:(id)data
{
    self.label.text = data;
    [self.label sizeToFit];
    CGSize labelSize = self.label.bounds.size;
    CGSize size = self.originalSize;
    size.width += labelSize.width - self.originalLabelSize.width;
    size.height += labelSize.height - self.originalLabelSize.height;
    return size;
}

@end
