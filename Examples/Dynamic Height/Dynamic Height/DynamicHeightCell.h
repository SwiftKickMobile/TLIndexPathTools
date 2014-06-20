//
//  DynamicHeightCell.h
//  Dynamic Height
//
//  Created by Tim Moose on 6/20/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLDynamicSizeView.h>

@interface DynamicHeightCell : UITableViewCell <TLDynamicSizeView>
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
