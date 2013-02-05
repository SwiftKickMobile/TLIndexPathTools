//
//  TLTableViewController.m
//  Dart Meister
//
//  Created by Tim Moose on 1/28/13.
//
//

#import "TLTableViewController.h"
#import "TLIndexPathDataModelUpdates.h"

@interface TLTableViewController ()

@end

@implementation TLTableViewController

- (void)setDataModel:(TLIndexPathDataModel *)dataModel
{
    if (_dataModel != dataModel) {
        TLIndexPathDataModelUpdates *updates = [[TLIndexPathDataModelUpdates alloc] initWithOldDataModel:_dataModel updatedDataModel:dataModel];
        _dataModel = dataModel;
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)reconfigureVisibleCells
{
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.dataModel cellIdentifierAtIndexPath:indexPath];
    if (!identifier) {
        identifier = @"Cell";
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:cell atIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataModel sectionTitleForSection:section];
}

@end
