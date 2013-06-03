//
//  ShuffleCollectionViewController.m
//  Shuffle
//
//  Created by Tim Moose on 5/29/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ShuffleCollectionViewController.h"
#import "TLIndexPathDataModel.h"
#import "UIColor+Hex.h"

#define IDX_TEXT 0
#define IDX_COLOR 1

@implementation ShuffleCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //initialize the controller with a list data items. To keep it simple, we'll
    //just use two element arrays (text and color) for our items.
    NSArray *items = @[
           @[@"A" ,[UIColor colorWithHexRGB:0x96D6C1]],
           @[@"B" ,[UIColor colorWithHexRGB:0xD696A3]],
           @[@"C" ,[UIColor colorWithHexRGB:0xFACB96]],
           @[@"D" ,[UIColor colorWithHexRGB:0xFAED96]],
           @[@"E" ,[UIColor colorWithHexRGB:0x96FAC3]],
           @[@"F" ,[UIColor colorWithHexRGB:0x6AA9CF]],
           ];
    self.indexPathController.items = items;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //retrieve the cell data for the given index path from the controller
    //and set the cell's text label and background color
    NSArray *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = item[IDX_TEXT];
    cell.backgroundColor = item[IDX_COLOR];
    cell.layer.cornerRadius = 10;
}

- (void)shuffle
{
    //shuffle the items randomly and update the controller with the shuffled items
    NSMutableArray *shuffledItems = [NSMutableArray arrayWithArray:self.indexPathController.items];
    NSInteger count = shuffledItems.count;
    for (int i = 0; i < count; i++) {
        [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % count];
    }
    self.indexPathController.items = shuffledItems;
}

@end
