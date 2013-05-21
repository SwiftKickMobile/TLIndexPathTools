//
//  TLTableViewController.m
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import "TLTableViewController.h"
#import "TLIndexPathItem.h"
#import "TLDynamicHeightView.h"

@interface TLTableViewController ()
@property (strong, nonatomic) NSMutableDictionary *prototypeCells;
@property (strong, nonatomic, readonly) TLIndexPathDataModel *dataModel;
@end

@implementation TLTableViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        _indexPathController = [[TLIndexPathController alloc] init];
        _indexPathController.delegate = self;
    }
    return self;
}

#pragma mark - Index path controller

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    if (_indexPathController != indexPathController) {
        _indexPathController = indexPathController;
        _indexPathController.delegate = self;
        [self.tableView reloadData];
    }
}

- (TLIndexPathDataModel *)dataModel
{
    return self.indexPathController.dataModel;
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

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataModel cellIdentifierAtIndexPath:indexPath];
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
    NSString *cellId = [self cellIdentifierAtIndexPath:indexPath];
    if (!cellId) {
        cellId = @"Cell";
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.dataModel itemAtIndexPath:indexPath];
    NSString *cellId = [self cellIdentifierAtIndexPath:indexPath];
    if (cellId) {
        UITableViewCell *cell = [self.prototypeCells objectForKey:cellId];
        if (!cell) {
            if (!self.prototypeCells) {
                self.prototypeCells = [[NSMutableDictionary alloc] init];
            }
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            [self.prototypeCells setObject:cell forKey:cellId];
        }
        if ([cell conformsToProtocol:@protocol(TLDynamicHeightView)]) {
            id<TLDynamicHeightView> v = (id<TLDynamicHeightView>)cell;
            id data;
            if ([item isKindOfClass:[TLIndexPathItem class]]) {
                TLIndexPathItem *i = (TLIndexPathItem *)item;
                data = i.data;
            } else {
                data = item;
            }
            return [v heightWithData:data];
        } else {
            return cell.bounds.size.height;
        }
    }
    
    return 44.0;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];
}

@end
