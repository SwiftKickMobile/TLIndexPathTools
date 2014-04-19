//
//  CollapseTableViewController.m
//  TLindexPathtools
//
//  Created by Tim Moose on 5/27/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "CollapseTableViewController.h"
#import <TLIndexPathTools/TLIndexPathSectionInfo.h>
#import <TLIndexPathTools/TLCollapsibleDataModel.h>

#define SECTION1_NAME @"Section 1"
#define SECTION2_NAME @"Section 2"

@implementation CollapseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //define items for two sections
    NSArray *section1Items = @[
                               @"Fredricksburg",
                               @"George Washington",
                               @"Grand Canyon"];
    NSArray *section2Items = @[
                               @"Jelly Bean",
                               @"Bibliography",
                               @"Keyboard Shortcut",
                               @"Metadata",
                               @"Fundamental",
                               @"Cellar Door",
                               @"Asteroid",
                               @"Avalanche",
                               @"Goatee",
                               @"Tapestry",
                               @"Monolithic",
                               @"Northwest",
                               ];

    //We're using plain string items, so we don't have a sectionNameKeyPath property
    //to use, so instead we explicitly create section info objects
    TLIndexPathSectionInfo *section1 = [[TLIndexPathSectionInfo alloc] initWithItems:section1Items name:SECTION1_NAME];
    TLIndexPathSectionInfo *section2 = [[TLIndexPathSectionInfo alloc] initWithItems:section2Items name:SECTION2_NAME];
    
    //create the backing model, which contains all sections and items
    TLIndexPathDataModel *backingDataModel = [[TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2]
                                                          identifierKeyPath:nil];
    [self collapseAll:backingDataModel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *item = [self.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = item;
    return cell;
}

- (IBAction)toggleSingleSectionExpanded:(UISwitch *)sender {
    self.singleExpandedSection = sender.isOn;
    [self collapseAll];
}

- (void)collapseAll
{
    [self collapseAll:self.dataModel.backingDataModel];
}

- (void)collapseAll:(TLIndexPathDataModel *)backingDataModel
{
    self.dataModel = [[TLCollapsibleDataModel alloc] initWithBackingDataModel:backingDataModel
                                                         expandedSectionNames:nil];
}

@end
