//
//  DynamicHeightTableViewController.m
//  Dynamic Height
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "DynamicHeightTableViewController.h"
#import <TLIndexPathTools/TLDynamicHeightLabelCell.h>

@implementation DynamicHeightTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indexPathController.items = @[
          @"Quisque tincidunt rhoncus.",
          @"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
          @"Fusce ac erat at lectus pulvinar porttitor vitae in mauris. Nam non eleifend tortor.",
          @"Quisque tincidunt rhoncus pellentesque.",
          @"Duis mauris nunc, fringilla nec elementum nec, lacinia at turpis. Duis mauris nunc, fringilla nec elementum nec, lacinia at turpis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
          @"Lorem ipsum dolor sit amet, consectetur.",
          @"Fusce ac erat at lectus pulvinar porttitor.",
          @"Duis mauris nunc, fringilla nec elementum nec, lacinia at turpis. Duis mauris nunc, fringilla nec elementum nec, lacinia at turpis. Class aptent taciti.",
          ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    TLDynamicHeightLabelCell *dynamicCell = (TLDynamicHeightLabelCell *)cell;
    [dynamicCell configureWithText:item];
    return cell;
}

@end
