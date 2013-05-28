//
//  CollapseTableViewController.m
//  TLindexPathtools
//
//  Created by Tim Moose on 5/27/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "CollapseTableViewController.h"
#import "TLIndexPathSectionInfo.h"
#import "TLCollapsibleDataModel.h"

#define SECTION1_NAME @"Section 1"
#define SECTION2_NAME @"Section 2"

@interface CollapseTableViewController ()
@property (strong, nonatomic) TLIndexPathDataModel *backingDataModel;
@end

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
                               @"Cellar Door"];

    //We're using plain string items, so we don't have a sectionNameKeyPath property
    //to use, so instead we explicitly create section info objects
    TLIndexPathSectionInfo *section1 = [[TLIndexPathSectionInfo alloc] initWithItems:section1Items andName:SECTION1_NAME];
    TLIndexPathSectionInfo *section2 = [[TLIndexPathSectionInfo alloc] initWithItems:section2Items andName:SECTION2_NAME];
    
    //create the backing model, which contains all sections and items
    self.backingDataModel = [[TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2]
                                                                           andIdentifierKeyPath:nil andCellIdentifierKeyPath:nil];
    
    [self collapseAll];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = item;
}

- (IBAction)toggleSingleSectionExpanded:(UISwitch *)sender {
    self.singleExpandedSection = sender.isOn;
    [self collapseAll];
}

- (void)collapseAll
{
    self.dataModel = [[TLCollapsibleDataModel alloc] initWithBackingDataModel:self.backingDataModel
                                                        collapsedSectionNames:[NSSet setWithArray:self.backingDataModel.sectionNames]];
}

@end
