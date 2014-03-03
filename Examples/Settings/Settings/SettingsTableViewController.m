//
//  SettingsTableViewController.m
//  Settings
//
//  Created by Tim Moose on 5/22/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "SettingsTableViewController.h"

#import <TLIndexPathTools/TLIndexPathDataModel.h>
#import <TLIndexPathTools/TLIndexPathItem.h>

//item identifiers for the data model are also used as the display text for the labels.
//For unique options (i.e. all options except difficulty level settings), item IDs
//are also used as cell IDs.
#define ITEM_ID_SOUND_ENABLED @"Sound"
#define ITEM_ID_VOLUME_LEVEL @"Volume"
#define ITEM_ID_DIFFICULTY @"Difficulty"
#define ITEM_ID_DIFFICULTY_EASY @"Easy"
#define ITEM_ID_DIFFICULTY_NORMAL @"Normal"
#define ITEM_ID_DIFFICULTY_HARD @"Hard"

#define CELL_ID_DIFFICULTY_OPTION_CELL @"DifficultyOption"

//main settings section
#define SECTION_NAME_SETTINGS @"Settings"
//difficulty options section appears when the cell that displays the default
//difficultly level is tapped
#define SECTION_NAME_DIFFICULTY_OPTIONS @"Difficulty Level"

@interface SettingsTableViewController ()
@property (nonatomic) BOOL soundEnabled;
@property (nonatomic) NSInteger volumeLevel;
@property (nonatomic) BOOL autosaveEnabled;
@property (nonatomic) NSString *difficultyLevel;
@property (nonatomic) BOOL difficultyLevelExpanded;
@end

@implementation SettingsTableViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    //initialize defualt settings
    self.soundEnabled = NO;
    self.volumeLevel = 50;
    self.autosaveEnabled = NO;
    self.difficultyLevel = ITEM_ID_DIFFICULTY_NORMAL;
    self.rowAnimationStyle = UITableViewRowAnimationFade;
    self.indexPathController.dataModel = [self newDataModel];
}

#pragma mark - Data model

- (TLIndexPathDataModel *)newDataModel
{
    //we use the TLIndexPathItem wrapper class for our data model items, making
    //it easy to represent a heterogenous mix of cells types and/or data (though
    //in this case we're not using the item's data property)
    
    NSMutableArray *items = [[NSMutableArray alloc] init];

    
    //sound enabled option
    
    TLIndexPathItem *soundItem = [[TLIndexPathItem alloc] initWithIdentifier:ITEM_ID_SOUND_ENABLED
                                                                 sectionName:SECTION_NAME_SETTINGS
                                                              cellIdentifier:ITEM_ID_SOUND_ENABLED
                                                                        data:nil];
    [items addObject:soundItem];

    //volume level control. only displayed when sound is enabled
    if (self.soundEnabled) {
        TLIndexPathItem *volumeItem = [[TLIndexPathItem alloc] initWithIdentifier:ITEM_ID_VOLUME_LEVEL
                                                                      sectionName:SECTION_NAME_SETTINGS
                                                                   cellIdentifier:ITEM_ID_VOLUME_LEVEL
                                                                             data:nil];
        [items addObject:volumeItem];
    }

    //difficulty level
    
    if (self.difficultyLevelExpanded) {

        for (NSString *difficultyOption in @[ITEM_ID_DIFFICULTY_EASY, ITEM_ID_DIFFICULTY_NORMAL, ITEM_ID_DIFFICULTY_HARD]) {
            TLIndexPathItem *difficultyOptionItem = [[TLIndexPathItem alloc] initWithIdentifier:difficultyOption
                                                                                       sectionName:SECTION_NAME_DIFFICULTY_OPTIONS
                                                                                    cellIdentifier:CELL_ID_DIFFICULTY_OPTION_CELL
                                                                                              data:nil];
            [items addObject:difficultyOptionItem];
        }
        
    }
    
    else {
        
        //otherwise, show expandable difficulty level row
        
        TLIndexPathItem *difficultyItem = [[TLIndexPathItem alloc] initWithIdentifier:ITEM_ID_DIFFICULTY
                                                                          sectionName:SECTION_NAME_SETTINGS
                                                                       cellIdentifier:ITEM_ID_DIFFICULTY
                                                                                 data:nil];
        [items addObject:difficultyItem];
    }
    
    return [[TLIndexPathDataModel alloc] initWithItems:items];
}

#pragma mark - Cell configuration

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //normally, we configure the cell in `cellForItemAtIndexPath`, but in this example, we use the
    //`configureCell` hook so we can more easily update the state of cells as selections are made.

    TLIndexPathItem *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    
    if ([ITEM_ID_SOUND_ENABLED isEqualToString:item.identifier]) {
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = @"Sound";
        UISwitch *theSwitch = (UISwitch *)[cell viewWithTag:2];
        theSwitch.on = self.soundEnabled;
    }

    else if ([ITEM_ID_VOLUME_LEVEL isEqualToString:item.identifier]) {
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = [NSString stringWithFormat:@"Volume %d", self.volumeLevel];
        UISlider *slider = (UISlider *)[cell viewWithTag:2];
        slider.value = self.volumeLevel;
        slider.maximumValue = 100;
        slider.minimumValue = 0;
    }

    else if ([ITEM_ID_DIFFICULTY isEqualToString:item.identifier]) {
        cell.textLabel.text = @"Difficulty Level";
        cell.detailTextLabel.text = self.difficultyLevel;
        cell.imageView.image = [UIImage imageNamed:@"gear"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"gear_press"];
    }

    //one configuration applies to all difficulty option cells, so we check for the
    //cell identifier rather than the item identifier
    else if ([CELL_ID_DIFFICULTY_OPTION_CELL isEqualToString:item.cellIdentifier]) {
        cell.textLabel.text = item.identifier;
        cell.accessoryType = [self.difficultyLevel isEqual:item.identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathItem *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];

    if ([ITEM_ID_DIFFICULTY isEqualToString:item.identifier]) {
        self.difficultyLevelExpanded = YES;
        self.indexPathController.dataModel = [self newDataModel];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    else if ([CELL_ID_DIFFICULTY_OPTION_CELL isEqualToString:item.cellIdentifier]) {
        self.difficultyLevel = item.identifier;
        //reconfigure difficulty level options to update the position of the check mark
        for (id itemId in @[ITEM_ID_DIFFICULTY_EASY, ITEM_ID_DIFFICULTY_NORMAL, ITEM_ID_DIFFICULTY_HARD]) {
            NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForIdentifier:itemId];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self tableView:tableView configureCell:cell atIndexPath:indexPath];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Interacting with controls

- (IBAction)soundChanged:(UISwitch *)sender {
    self.soundEnabled = sender.isOn;
    //update the data model to hide or show the volume control
    self.indexPathController.dataModel = [self newDataModel];
}

- (IBAction)volumeChanged:(UISlider *)sender {
    self.volumeLevel = roundl(sender.value);
    //look up and reconfigure the volume control to refresh the label (after having
    //updated the volumeLevel property)
    NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForIdentifier:ITEM_ID_VOLUME_LEVEL];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self tableView:self.tableView configureCell:cell atIndexPath:indexPath];
}

@end
