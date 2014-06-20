//
//  DynamicHeightCell.m
//  Dynamic Height
//
//  Created by Tim Moose on 6/20/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import "DynamicHeightCell.h"

@implementation DynamicHeightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
