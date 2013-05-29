//
//  ShuffleCollectionViewController.m
//  Shuffle
//
//  Created by Tim Moose on 5/29/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "ShuffleCollectionViewController.h"
#import "TLIndexPathDataModel.h"

#pragma mark - ShuffleData

@interface ShuffleData : NSObject
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *color;
- (instancetype)initWithText:(NSString *)text color:(UIColor *)color;
@end

@implementation ShuffleData
- (instancetype)initWithText:(NSString *)text color:(UIColor *)color
{
    if (self = [super init]) {
        _text = text;
        _color = color;
    }
    return self;
}
@end

#pragma mark - ShuffleCollectionViewController

@implementation ShuffleCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //initialize the controller with a list of shuffle data objects
    NSArray *items = @[
           [[ShuffleData alloc] initWithText:@"A" color:[self colorWithHexRGB:0x96D6C1]],
           [[ShuffleData alloc] initWithText:@"B" color:[self colorWithHexRGB:0xD696A3]],
           [[ShuffleData alloc] initWithText:@"C" color:[self colorWithHexRGB:0xFACB96]],
           [[ShuffleData alloc] initWithText:@"D" color:[self colorWithHexRGB:0xFAED96]],
           [[ShuffleData alloc] initWithText:@"E" color:[self colorWithHexRGB:0x96FAC3]],
           [[ShuffleData alloc] initWithText:@"F" color:[self colorWithHexRGB:0x6AA9CF]],
           ];
    //rather than just passing the list of items to the index path controller, we create an explicit
    //data model in order to set a custom identifier key path (we could let ShuffleData serve as its own
    //identifier, but we'd need to implement `copyWithZone:`)
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:items andSectionNameKeyPath:nil andIdentifierKeyPath:@"text"];
    self.indexPathController.dataModel = dataModel;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //retrieve the cell data for the given index path from the controller
    //and set the cell's text label and background color
    ShuffleData *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = item.text;
    cell.backgroundColor = item.color;
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

- (UIColor *)colorWithHexRGB:(unsigned)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
