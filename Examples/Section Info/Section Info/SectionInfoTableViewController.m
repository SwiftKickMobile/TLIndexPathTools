//
//  SectionInfoTableViewController.m
//  Section Info
//
//  Created by Tim Moose on 7/5/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "SectionInfoTableViewController.h"
#import "TLIndexPathDataModel.h"
#import "TLIndexPathSectionInfo.h"

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
    
    TLIndexPathSectionInfo *section1 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 1.1", @"Item 1.2"] andName:@"Section 1"];
    TLIndexPathSectionInfo *section2 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 2.1"] andName:@"Section 2"];
    TLIndexPathSectionInfo *section3 = [[TLIndexPathSectionInfo alloc] initWithItems:nil andName:@"Section 3"];
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2, section3]
                                                                       andIdentifierKeyPath:nil
                                                                   andCellIdentifierKeyPath:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    return cell;
}

@end
