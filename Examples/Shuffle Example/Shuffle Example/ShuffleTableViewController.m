//
//  ShuffleTableViewController.m
//  Shuffle Example
//
//  Created by Tim Moose on 5/22/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "ShuffleTableViewController.h"

@implementation ShuffleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //initialize the controller with a list of strings to display in the table
    self.indexPathController.items = @[
                                       @"Fredricksburg",
                                       @"Jelly Bean",
                                       @"George Washington",
                                       @"Grand Canyon",
                                       @"Bibliography",
                                       @"Keyboard Shortcut",
                                       @"Metadata",
                                       @"Fundamental",
                                       @"Cellar Door"];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //retrieve the string for the given index path from the controller
    //and set the cell's text label.
    NSString *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = item;
}

- (void)shuffle
{
    //shuffle the items randomly and update the controller with the shuffled items
    NSMutableArray *shuffledItems = [NSMutableArray arrayWithArray:self.indexPathController.items];
    NSInteger count = shuffledItems.count;
    for (int i = 0; i < count; i++) {
        [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % count];
    }
    self.indexPathController.items = shuffledItems;
}

@end
