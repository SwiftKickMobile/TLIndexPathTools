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

- (void)configureWithText:(NSString *)text
{
    self.label.text = text;
    [self.label sizeToFit];
}

#pragma mark - TLDynamicSizeView

- (CGSize)sizeWithData:(id)data
{
    [self configureWithText:data];
    //the dynamic size is calculated by taking the original size and incrementing
    //by the change in the label's size after configuring
    CGSize labelSize = self.label.bounds.size;
    CGSize size = self.originalSize;
    size.width += labelSize.width - self.originalLabelSize.width;
    size.height += labelSize.height - self.originalLabelSize.height;
    return size;
}

@end
