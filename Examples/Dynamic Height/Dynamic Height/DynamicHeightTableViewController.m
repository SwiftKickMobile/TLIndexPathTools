//
//  DynamicHeightTableViewController.m
//  Dynamic Height
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "DynamicHeightTableViewController.h"
#import "DynamicHeightCell.h"

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

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    DynamicHeightCell *dynamicCell = (DynamicHeightCell *)cell;
    dynamicCell.label.text = item;
}

@end
