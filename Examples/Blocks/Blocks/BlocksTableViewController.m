//
//  BlocksTableViewController.m
//  Blocks
//
//  Created by Tim Moose on 9/18/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

/**
 Demonstrates block based data model initializer used to organize a list of sorted
 strings into sections based on the first letter of each string.
 */

#import "BlocksTableViewController.h"

#import <TLIndexPathTools/TLIndexPathDataModel.h>

@implementation BlocksTableViewController

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        
        NSArray *items = [@[
               @"Fredricksburg",
               @"Jelly Bean",
               @"George Washington",
               @"Grand Canyon",
               @"Bibliography",
               @"Keyboard Shortcut",
               @"Metadata",
               @"Fundamental",
               @"Cellar Door"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

        //generate section names by taking the first letter of each item
        self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:items
                                                                        sectionNameBlock:^NSString *(id item) {
            return [((NSString *)item) substringToIndex:1];
        } identifierBlock:nil];
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel sectionNameForSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.indexPathController.dataModel sectionNames];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.indexPathController.dataModel sectionForSectionName:title];
}

@end
