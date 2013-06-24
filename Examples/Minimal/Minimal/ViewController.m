//
//  ViewController.m
//  Minimal
//
//  Created by Tim Moose on 6/24/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

/**
 This example demonstrates how to use TLIndexPathTools with minimal dependencies
 by interfacing with TLIndexPathController directly rather than subclassing
 the `TLTableViewController` or `TLTableViewDelegateImpl` classes.
 */

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) TLIndexPathController *indexPathController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indexPathController = [[TLIndexPathController alloc] initWithItems:@[
                                @"Chevrolet",
                                @"Bubble Gum",
                                @"Chalkboard"]
                                ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSString *title = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}

@end
