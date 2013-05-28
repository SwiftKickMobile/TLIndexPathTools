//
//  OutlineTableViewController.m
//  Outline
//
//  Created by Tim Moose on 5/27/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "OutlineTableViewController.h"
#import "TLIndexPathTreeItem.h"

#define CELL_ID_LEVEL1 @"Level1"
#define CELL_ID_LEVEL2 @"Level2"
#define CELL_ID_LEVEL3 @"Level3"

#define SECTION_1 @"Section 1"
#define SUBSECTION_1_1 @"Subsection 1.1"
#define LEAF_ITEM_1_1_1 @"Leaf Item 1.1.1"
#define LEAF_ITEM_1_1_2 @"Leaf Item 1.1.2"
#define SUBSECTION_1_2 @"Subsection 1.2"
#define LEAF_ITEM_1_2_1 @"Leaf Item 1.2.1"
#define SECTION_2 @"Section 2"
#define SUBSECTION_2_1 @"Subsection 2.1"
#define LEAF_ITEM_2_1_1 @"Leaf Item 2.1.1"
#define LEAF_ITEM_2_1_2 @"Leaf Item 2.1.2"

@interface OutlineTableViewController ()
@property (strong, nonatomic) NSArray *treeItems;
@end

@implementation OutlineTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup item heirarchy for data model
    
    TLIndexPathTreeItem *leaf111 = [[TLIndexPathTreeItem alloc] initWithIdentifier:LEAF_ITEM_1_1_1
                                                                       sectionName:nil
                                                                    cellIdentifier:CELL_ID_LEVEL3
                                                                              data:nil];

    TLIndexPathTreeItem *leaf112 = [[TLIndexPathTreeItem alloc] initWithIdentifier:LEAF_ITEM_1_1_2
                                                                       sectionName:nil
                                                                    cellIdentifier:CELL_ID_LEVEL3
                                                                              data:nil];
    
    TLIndexPathTreeItem *subsection11 = [[TLIndexPathTreeItem alloc] initWithIdentifier:SUBSECTION_1_1
                                                                            sectionName:nil
                                                                         cellIdentifier:CELL_ID_LEVEL2
                                                                                   data:nil
                                                                          andChildItems:@[leaf111, leaf112]];

    TLIndexPathTreeItem *leaf121 = [[TLIndexPathTreeItem alloc] initWithIdentifier:LEAF_ITEM_1_2_1
                                                                       sectionName:nil
                                                                    cellIdentifier:CELL_ID_LEVEL3
                                                                              data:nil];
    
    TLIndexPathTreeItem *subsection12 = [[TLIndexPathTreeItem alloc] initWithIdentifier:SUBSECTION_1_2
                                                                            sectionName:nil
                                                                         cellIdentifier:CELL_ID_LEVEL2
                                                                                   data:nil
                                                                          andChildItems:@[leaf121]];

    TLIndexPathTreeItem *section1 = [[TLIndexPathTreeItem alloc] initWithIdentifier:SECTION_1
                                                                            sectionName:nil
                                                                         cellIdentifier:CELL_ID_LEVEL1
                                                                                   data:nil
                                                                          andChildItems:@[subsection11, subsection12]];
    
    TLIndexPathTreeItem *leaf211 = [[TLIndexPathTreeItem alloc] initWithIdentifier:LEAF_ITEM_2_1_1
                                                                       sectionName:nil
                                                                    cellIdentifier:CELL_ID_LEVEL3
                                                                              data:nil];
    
    TLIndexPathTreeItem *leaf212 = [[TLIndexPathTreeItem alloc] initWithIdentifier:LEAF_ITEM_2_1_2
                                                                       sectionName:nil
                                                                    cellIdentifier:CELL_ID_LEVEL3
                                                                              data:nil];

    TLIndexPathTreeItem *subsection21 = [[TLIndexPathTreeItem alloc] initWithIdentifier:SUBSECTION_2_1
                                                                            sectionName:nil
                                                                         cellIdentifier:CELL_ID_LEVEL2
                                                                                   data:nil
                                                                          andChildItems:@[leaf211, leaf212]];

    TLIndexPathTreeItem *section2 = [[TLIndexPathTreeItem alloc] initWithIdentifier:SECTION_2
                                                                        sectionName:nil
                                                                     cellIdentifier:CELL_ID_LEVEL1
                                                                               data:nil
                                                                      andChildItems:@[subsection21]];
    
    self.treeItems = @[section1, section2];

    //set data model with top-level items collapsed
    
    NSMutableArray *topLevelIdentifiers = [[NSMutableArray alloc] initWithCapacity:self.treeItems.count];
    for (TLIndexPathTreeItem *treeItem in self.treeItems) {
        [topLevelIdentifiers addObject:treeItem.identifier];
    }
    
    self.dataModel = [[TLTreeDataModel alloc] initWithTreeItems:self.treeItems collapsedNodeIdentifiers:[NSSet setWithArray:topLevelIdentifiers]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.dataModel identifierAtIndexPath:indexPath];
    cell.textLabel.text = identifier;
}

@end
