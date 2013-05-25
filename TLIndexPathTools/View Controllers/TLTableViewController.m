//
//  TLTableViewController.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLTableViewController.h"
#import "TLIndexPathItem.h"
#import "TLDynamicSizeView.h"

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

#pragma mark - Prototypes

- (UITableViewCell *)prototypeForCellIdentifier:(NSString *)cellIdentifier
{
    UITableViewCell *cell;
    if (cellIdentifier) {
        cell = [self.prototypeCells objectForKey:cellIdentifier];
        if (!cell) {
            if (!self.prototypeCells) {
                self.prototypeCells = [[NSMutableDictionary alloc] init];
            }
            cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [self.prototypeCells setObject:cell forKey:cellIdentifier];
        }
    }
    return cell;
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
        UITableViewCell *cell = [self prototypeForCellIdentifier:cellId];
        if ([cell conformsToProtocol:@protocol(TLDynamicSizeView)]) {
            id<TLDynamicSizeView> v = (id<TLDynamicSizeView>)cell;
            id data;
            if ([item isKindOfClass:[TLIndexPathItem class]]) {
                TLIndexPathItem *i = (TLIndexPathItem *)item;
                data = i.data;
            } else {
                data = item;
            }
            CGSize computedSize = [v sizeWithData:data];
            return computedSize.height;
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
