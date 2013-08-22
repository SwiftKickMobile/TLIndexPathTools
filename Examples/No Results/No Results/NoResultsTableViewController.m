//
//  NoResultsTableViewController.m
//  No Results
//
//  Created by Tim Moose on 8/22/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "NoResultsTableViewController.h"
#import "TLNoResultsTableDataModel.h"
#import "TLIndexPathItem.h"

/**
 Demonstrates use of the `TLNoResultsDataModel` extension to display a "no results" message
 when there are no items to display. Also demonstrates how to manipulate the data model
 via the index path controller delegate's `willUpdateDataModel` method.
 */

@interface NoResultsTableViewController ()
@property (strong, nonatomic) NSArray *allItems;
@property (nonatomic) BOOL hideRows;
@end

@implementation NoResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allItems = @[
           @"Fredricksburg",
           @"Jelly Bean",
           @"George Washington",
           @"Grand Canyon",
           @"Bibliography",
           @"Keyboard Shortcut",
           @"Metadata",
           @"Fundamental",
           @"Cellar Door"];
    self.hideRows = NO;
}

- (IBAction)toggleHideRows {
    self.hideRows = !self.hideRows;
}

- (void)setHideRows:(BOOL)hideRows
{
    //either display all rows or non depending on the state of the toggle button
    _hideRows = hideRows;
    NSArray *items = hideRows ? nil : self.allItems;
    self.indexPathController.items = items;
    [self.hideRowsButton setTitle:hideRows ? @"Show Rows" : @"Hide Rows" forState:UIControlStateNormal];
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *cellId = [self tableView:tableView cellIdentifierAtIndexPath:indexPath];
    if ([@"Cell" isEqualToString:cellId]) {
        //regular rows have NSString items
        cell.textLabel.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    } else {
        //TLNoResultsTableDataModel rows have TLIndexPathItem items (so that they can
        //specify their own `cellId`.
        TLIndexPathItem *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        cell.textLabel.text = item.data;
    }
    return cell;
}

#pragma mark - TLIndexPathControllerDelegate

- (TLIndexPathDataModel *)controller:(TLIndexPathController *)controller willUpdateDataModel:(TLIndexPathDataModel *)oldDataModel withDataModel:(TLIndexPathDataModel *)updatedDataModel
{
    //intercept the update and substitute a `TLNoResultsTableDataModel` if there
    //are no items to display. This is a good place to insert the "no results"
    //message because it will always work no matter how the view controller
    //manipulates the data model.
    if (updatedDataModel.items.count == 0) {
        return [[TLNoResultsTableDataModel alloc] initWithRows:3 blankCellId:@"BlankCell" noResultsCellId:@"NoResultsCell" noResultsText:@"No results to display"];
    }
    return nil;
}

@end
