//
//  OutlineTableViewController.m
//  Outline
//
//  Created by Tim Moose on 5/27/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "OutlineTableViewController.h"
#import "TLIndexPathTreeItem.h"

#define ITEM_1 @"Heading 1"
#define ITEM_1_1 @"Heading 1.1"
#define ITEM_1_1_1 @"Heading 1.1.1"
#define ITEM_1_1_2 @"Heading 1.1.2"
#define ITEM_1_2 @"Heading 1.2"
#define ITEM_1_2_1 @"Heading 1.2.1"
#define ITEM_2 @"Heading 2"
#define ITEM_2_1 @"Heading 2.1"
#define ITEM_2_1_1 @"Heading 2.1.1"
#define ITEM_2_1_2 @"Heading 2.1.2"

@interface OutlineTableViewController ()
@property (strong, nonatomic) NSArray *treeItems;
@end

@implementation OutlineTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup item heirarchy for data model
    TLIndexPathTreeItem *item111 = [self itemWithId:ITEM_1_1_1 level:2 children:nil];
    TLIndexPathTreeItem *item112 = [self itemWithId:ITEM_1_1_2 level:2 children:nil];
    TLIndexPathTreeItem *item11 = [self itemWithId:ITEM_1_1  level:1 children:@[item111, item112]];
    TLIndexPathTreeItem *item121 = [self itemWithId:ITEM_1_2_1 level:2 children:nil];
    TLIndexPathTreeItem *item12 = [self itemWithId:ITEM_1_2 level:1 children:@[item121]];
    TLIndexPathTreeItem *item1 = [self itemWithId:ITEM_1 level:0 children:@[item11, item12]];
    TLIndexPathTreeItem *item211 = [self itemWithId:ITEM_2_1_1 level:2 children:nil];
    TLIndexPathTreeItem *item212 = [self itemWithId:ITEM_2_1_2 level:2 children:nil];
    TLIndexPathTreeItem *item21 = [self itemWithId:ITEM_2_1 level:1 children:@[item211, item212]];
    TLIndexPathTreeItem *item2 = [self itemWithId:ITEM_2 level:0 children:@[item21]];

    self.treeItems = @[item1, item2];

    //set data model with top-level items collapsed
    
    NSMutableArray *topLevelIdentifiers = [[NSMutableArray alloc] initWithCapacity:self.treeItems.count];
    for (TLIndexPathTreeItem *treeItem in self.treeItems) {
        [topLevelIdentifiers addObject:treeItem.identifier];
    }
    
    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:self.treeItems collapsedNodeIdentifiers:[NSSet setWithArray:topLevelIdentifiers]];
}

//shorcut method for generating tree items
- (TLIndexPathTreeItem *)itemWithId:(NSString *)identifier level:(NSInteger)level children:(NSArray *)children
{
    return [[TLIndexPathTreeItem alloc] initWithIdentifier:identifier
                                               sectionName:nil
                                            cellIdentifier:[NSString stringWithFormat:@"Level%d", level]
                                                      data:nil andChildItems:children];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = [self.dataModel identifierAtIndexPath:indexPath];
    cell.textLabel.text = identifier;
    return cell;
}

@end
