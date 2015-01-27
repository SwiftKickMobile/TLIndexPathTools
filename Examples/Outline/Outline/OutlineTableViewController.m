//
//  OutlineTableViewController.m
//  Outline
//
//  Created by Tim Moose on 5/27/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "OutlineTableViewController.h"
#import <TLIndexPathTools/TLIndexPathTreeItem.h>

#define ITEM_1 @"Heading 1"
#define ITEM_1_1 @"Heading 1.1 (sync lazy load)"
#define ITEM_1_1_1 @"Heading 1.1.1"
#define ITEM_1_1_2 @"Heading 1.1.2"
#define ITEM_1_2 @"Heading 1.2"
#define ITEM_1_2_1 @"Heading 1.2.1"
#define ITEM_2 @"Heading 2"
#define ITEM_2_1 @"Heading 2.1 (async lazy load)"
#define ITEM_2_1_1 @"Heading 2.1.1"
#define ITEM_2_1_2 @"Heading 2.1.2"
#define ITEM_2_1_3 @"Heading 2.1.3"
#define ITEM_2_1_4 @"Heading 2.1.4"
#define ITEM_2_1_5 @"Heading 2.1.5"
#define ITEM_2_1_6 @"Heading 2.1.6"
#define ITEM_2_1_7 @"Heading 2.1.7"

@interface OutlineTableViewController ()
@property (strong, nonatomic) NSArray *treeItems;
@end

@implementation OutlineTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup item heirarchy for data model
    
    //lazy loaded node. `childNodes == nil` indicates leaf node, so provide an empty array.
    TLIndexPathTreeItem *item11 = [self itemWithId:ITEM_1_1  level:1 children:@[]];
    
    TLIndexPathTreeItem *item121 = [self itemWithId:ITEM_1_2_1 level:2 children:nil];
    TLIndexPathTreeItem *item12 = [self itemWithId:ITEM_1_2 level:1 children:@[item121]];
    TLIndexPathTreeItem *item1 = [self itemWithId:ITEM_1 level:0 children:@[item11, item12]];
    TLIndexPathTreeItem *item21 = [self itemWithId:ITEM_2_1 level:1 children:@[]];
    TLIndexPathTreeItem *item2 = [self itemWithId:ITEM_2 level:0 children:@[item21]];

    self.treeItems = @[item1, item2];

    //set data model with top-level items collapsed
    
    NSArray *topLevelIdentifiers = [TLIndexPathItem identifiersForIndexPathItems:self.treeItems];
    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:self.treeItems collapsedNodeIdentifiers:topLevelIdentifiers];
    
    self.delegate = self;
}

//shorcut method for generating tree items
- (TLIndexPathTreeItem *)itemWithId:(NSString *)identifier level:(NSInteger)level children:(NSArray *)children
{
    return [[TLIndexPathTreeItem alloc] initWithIdentifier:identifier
                                               sectionName:nil
                                            cellIdentifier:[NSString stringWithFormat:@"Level%d", (int)level]
                                                      data:nil andChildItems:children];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = [self.dataModel identifierAtIndexPath:indexPath];
    cell.textLabel.text = identifier;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TLTreeTableViewControllerDelegate

- (void)controller:(TLTreeTableViewController *)controller willChangeNode:(TLIndexPathTreeItem *)treeItem collapsed:(BOOL)collapsed
{
    //try to lazy insert children the first time a node is expanded
    if (collapsed == NO && [treeItem.childItems count] == 0) {

        //example of inserting children synchronously
        if ([ITEM_1_1 isEqualToString:treeItem.identifier]) {
            
            TLIndexPathTreeItem *item111 = [self itemWithId:ITEM_1_1_1 level:2 children:nil];
            TLIndexPathTreeItem *item112 = [self itemWithId:ITEM_1_1_2 level:2 children:nil];
            TLIndexPathTreeItem *item11 = [treeItem copyWithChildren:@[item111, item112]];
            [self setNewVersionOfItem:item11 collapsedChildNodeIdentifiers:[TLIndexPathItem identifiersForIndexPathItems:item11.childItems] optimizeScroll:YES];
        }
        
        //example of inserting children asynchronously
        else if ([ITEM_2_1 isEqualToString:treeItem.identifier]) {

            //typically, one would fetch child data on a background thread and then
            //set new version of item on main thread in the completion handler of the fetch
            //(for simplicity, not actually fetching items here. just inserting items
            //after a 1 second delay to simulate a fetch response)
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                TLIndexPathTreeItem *item211 = [self itemWithId:ITEM_2_1_1 level:2 children:nil];
                TLIndexPathTreeItem *item212 = [self itemWithId:ITEM_2_1_2 level:2 children:nil];
                TLIndexPathTreeItem *item213 = [self itemWithId:ITEM_2_1_3 level:2 children:nil];
                TLIndexPathTreeItem *item214 = [self itemWithId:ITEM_2_1_4 level:2 children:nil];
                TLIndexPathTreeItem *item215 = [self itemWithId:ITEM_2_1_5 level:2 children:nil];
                TLIndexPathTreeItem *item216 = [self itemWithId:ITEM_2_1_6 level:2 children:nil];
                TLIndexPathTreeItem *item217 = [self itemWithId:ITEM_2_1_7 level:2 children:nil];
                TLIndexPathTreeItem *item21 = [treeItem copyWithChildren:@[item211, item212, item213, item214, item215, item216, item217]];
                [self setNewVersionOfItem:item21 collapsedChildNodeIdentifiers:[TLIndexPathItem identifiersForIndexPathItems:item21.childItems] optimizeScroll:YES];
            });            
        }
    }
}

@end
