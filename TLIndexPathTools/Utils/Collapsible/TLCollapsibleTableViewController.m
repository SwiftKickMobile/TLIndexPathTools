//
//  TLCollapsibleTableViewController.m
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

#import "TLCollapsibleTableViewController.h"
#import "TLCollapsibleHeaderView.h"

@interface TLCollapsibleTableViewController ()

@end

@implementation TLCollapsibleTableViewController

- (TLCollapsibleDataModel *)dataModel {
    return (TLCollapsibleDataModel *)self.indexPathController.dataModel;
}

- (void)setDataModel:(TLCollapsibleDataModel *)dataModel
{
    self.indexPathController.dataModel = dataModel;
}

- (void)configureHeaderView:(TLCollapsibleHeaderView *)headerView forSection:(NSInteger)section
{
}

#pragma mark - UITableViewDelegate

/**
 Override this to customize header view height
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section];
    TLCollapsibleHeaderView *headerView = [[TLCollapsibleHeaderView alloc] initWithFrame:CGRectMake(0, 0, width, height) andSection:section];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTap:)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addGestureRecognizer:tapRecognizer];
    [self configureHeaderView:headerView forSection:section];
    return headerView;
}

- (void) handleSectionTap:(UITapGestureRecognizer *)sender
{
    TLCollapsibleHeaderView *headerView = (TLCollapsibleHeaderView *)sender.view;
    NSInteger section = headerView.section;
    NSString *sectionName = [self.dataModel sectionNameForSection:section];
    NSMutableArray *collapsedSectionNames = [NSMutableArray arrayWithArray:self.dataModel.collapsedSectionNames];
    BOOL collapsed = NO;
    if ([collapsedSectionNames containsObject:sectionName]) {
        if (self.singleExpandedSection) {
            [collapsedSectionNames removeAllObjects];
            [collapsedSectionNames addObjectsFromArray:[self.dataModel sectionNames]];
        }
        [collapsedSectionNames removeObject:sectionName];
    } else {
        [collapsedSectionNames addObject:sectionName];
        collapsed = YES;
    }

    self.dataModel = [[TLCollapsibleDataModel alloc] initWithBackingDataModel:self.dataModel.backingDataModel collapsedSectionNames:collapsedSectionNames];

    if ([self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [self.delegate controller:self didChangeSection:section collapsed:collapsed];
    }
    if (!collapsed) {
        [self optimizeScrollPositionForSection:section headerView:headerView animated:YES];
    }
    
    [self configureHeaderView:headerView forSection:section];
}

#pragma mark - Scroll optimization

- (void)optimizeScrollPositionForSection:(NSInteger)section headerView:(UIView *)headerView animated:(BOOL)animated
{
    return;
    // TODO Why is headerViewForSection: returning nil??? Shouldn't need to pass it in
    //    UIView *headerView = [self.tableView headerViewForSection:section];
    //    if (!headerView) {
    //        return;
    //    }
    CGFloat sectionTop = headerView.frame.origin.y - self.tableView.contentOffset.y;
    if (sectionTop > 0) {
        
        // If top of section is visible, see if we can scroll up to expose more rows in the section
        
        // Compute how much space visible below the top of the section so we can calculate
        // what parts of the section will not be visible
        CGFloat visibleSpaceBelowSectionTop = self.tableView.bounds.size.height - sectionTop;
        
        // Start calculating how much space can be made visible before the section
        // top scrolls out of view above
        CGFloat offsetBelowTopToMakeVisible = headerView.bounds.size.height;
        
        // Calculate how much of the header is not visible
        CGFloat spaceNotVisible = offsetBelowTopToMakeVisible - visibleSpaceBelowSectionTop;
        
        // If there is not enough room to make the header visible, scroll the header to the top
        if (spaceNotVisible > sectionTop) {
            CGFloat locationToMakeVisible = headerView.frame.origin.y + visibleSpaceBelowSectionTop + sectionTop;
            [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
            return;
        }
        
        // Iterate over rows to find out how many can be made visible
        id<NSFetchedResultsSectionInfo>sectionInfo = self.dataModel.sections[section];
        for (id item in sectionInfo.objects) {
            NSIndexPath *indexPath = [self.dataModel indexPathForItem:item];
            offsetBelowTopToMakeVisible += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            spaceNotVisible = offsetBelowTopToMakeVisible - visibleSpaceBelowSectionTop;
            // If we run out of space to display all rows, scroll the header to the top
            if (spaceNotVisible > sectionTop) {
                CGSize contentSize = self.tableView.contentSize;
                contentSize.height = 1000;
                self.tableView.contentSize = contentSize;
                CGFloat locationToMakeVisible = headerView.frame.origin.y + visibleSpaceBelowSectionTop + sectionTop;
                [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
                return;
            }
        }
        
        // The entire section can be displayed, so scroll as much as needed
        if (spaceNotVisible > 0) {
            CGFloat locationToMakeVisible = headerView.frame.origin.y + offsetBelowTopToMakeVisible;
            [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
            return;
        }
        
    } else {
        [self.tableView scrollRectToVisible:headerView.frame animated:animated];
    }
}

/*
 Force table to scroll to the specified location even if it is beyond the current
 content area. Use this to scroll to a future location during animiated table updates
 with the assumption that the location will be valid after the updates.
 */
- (void)forceTableScrollBasedOnExpectedSize:(CGFloat)scrollLocation animated:(BOOL)animated
{
    CGSize expectedMinimumContentSize = self.tableView.contentSize;
    if (expectedMinimumContentSize.height < scrollLocation) {
        // Temporarily expand the content area to contain the scroll location.
        // The table will overwrite this during the update process.
        expectedMinimumContentSize.height = scrollLocation;
        self.tableView.contentSize = expectedMinimumContentSize;
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, scrollLocation-1, 1, 1) animated:animated];
}

@end
