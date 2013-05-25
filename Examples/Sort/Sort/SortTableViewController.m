//
//  SortTableViewController.m
//  Sort
//
//  Created by Tim Moose on 5/25/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "SortTableViewController.h"

@implementation SortTableViewController

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

- (void)sortAlphabetically
{
    NSArray *items = self.indexPathController.items;
    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.indexPathController.items = sortedItems;
}

- (void)sortByLength
{
    NSArray *items = self.indexPathController.dataModel.items;
    NSArray *sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *number1 = [self lengthOfCellLabelWithText:obj1];
        NSNumber *number2 = [self lengthOfCellLabelWithText:obj2];
        return [number1 compare:number2];
    }];
    self.indexPathController.items = sortedItems;
}

- (NSNumber *)lengthOfCellLabelWithText:(NSString *)text
{
    UITableViewCell *cell = [self prototypeForCellIdentifier:@"Cell"];
    cell.textLabel.text = text;
    [cell.textLabel sizeToFit];
    return @(cell.textLabel.bounds.size.width);
}

@end
