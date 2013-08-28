//
//  SectionInfoTableViewController.m
//  Section Info
//
//  Created by Tim Moose on 7/5/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "SectionInfoTableViewController.h"
#import <TLIndexPathTools/TLIndexPathDataModel.h>
#import <TLIndexPathTools/TLIndexPathSectionInfo.h>

/**
 Demonstrates how to explicitly define sections with instances of `TLIndexPathSectionInfo`.
 This approach allows for empty sections (whereas creating sections using 
 `sectionNameKeyPath` does not).
 */

@interface SectionInfoTableViewController ()

@end

@implementation SectionInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TLIndexPathSectionInfo *section1 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 1.1", @"Item 1.2"] name:@"Section 1"];
    TLIndexPathSectionInfo *section2 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 2.1"] name:@"Section 2"];
    TLIndexPathSectionInfo *section3 = [[TLIndexPathSectionInfo alloc] initWithItems:nil name:@"Section 3"];
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2, section3]
                                                                       identifierKeyPath:nil];
    
    UILabel *headerLabel = (UILabel *)self.tableView.tableHeaderView;
    headerLabel.text = [NSString stringWithFormat:@"%d total items in table.", self.indexPathController.items.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    return cell;
}

@end
