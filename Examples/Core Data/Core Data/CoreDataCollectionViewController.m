//
//  CoreDataCollectionViewController.m
//  Core Data
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

#import "CoreDataCollectionViewController.h"
#import "Item.h"
#import "UIColor+Hex.h"

#define MAX_ITEMS 20
#define DELAY_SECONDS .35

@interface CoreDataCollectionViewController ()
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) Item *lastModifiedItem;
@end

@implementation CoreDataCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.colors = @[
                    [UIColor colorWithHexRGB:0xBF0C43],
                    [UIColor colorWithHexRGB:0xF9BA15],
                    [UIColor colorWithHexRGB:0x8EAC00],
                    [UIColor colorWithHexRGB:0x127A97],
                    [UIColor colorWithHexRGB:0x452B72],
                    ];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) documentWithHandler:^(UIManagedDocument *doc) {
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
        fetch.sortDescriptors = @[];
        self.indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:fetch managedObjectContext:doc.managedObjectContext sectionNameKeyPath:nil identifierKeyPath:nil cacheName:nil];
        [self.indexPathController performFetch:nil];
        [self insertItem];
    }];
}

- (void)insertItem
{
    UIManagedDocument *doc = ((AppDelegate *)[UIApplication sharedApplication].delegate).document;
    
    Item *item;
    //if we've reached max items, randomly select an existing item
    if (self.indexPathController.items.count == MAX_ITEMS) {
        item = self.indexPathController.items[rand() % MAX_ITEMS];
        self.lastModifiedItem = item;
    }
    //otherwise, insert a new item
    else {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:doc.managedObjectContext];
        self.lastModifiedItem = nil;
    }

    //set a random letter and color on the item
    item.text = [NSString stringWithFormat:@"%c", 'A' + rand() % 26];
    item.color = @(rand() % self.colors.count);
    
    //reconfigure the cell (if it existing and is visible) to reflect the new data
    NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:item];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [self collectionView:self.collectionView configureCell:cell atIndexPath:indexPath];
    
    //save the document so that changes will be propagated to the table's index path controller
    [doc savePresentedItemChangesWithCompletionHandler:^(NSError *errorOrNil) {
        [self performSelector:@selector(insertItem) withObject:self afterDelay:DELAY_SECONDS];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    //if this is an existing item being modified, do a flip animation.
    BOOL animated = self.lastModifiedItem == item;
    CGFloat duration = animated ? 0.35 : 0;
    UIViewAnimationOptions animationOption = animated ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionNone;
    cell.backgroundColor = self.colors[[item.color integerValue]];
    [UIView transitionWithView:cell duration:duration options:animationOption animations:^{
        label.text = item.text;
        label.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
        cell.layer.cornerRadius = 10;
    } completion:nil];
}

- (IBAction)sortAlphabetically:(id)sender {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES];
    NSFetchRequest *fetch = [self.indexPathController.fetchRequest copy];
    fetch.sortDescriptors = @[sort];
    self.indexPathController.fetchRequest = fetch;
    [self.indexPathController performFetch:nil];
}

- (IBAction)sortByColor:(id)sender {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"color" ascending:YES];
    NSFetchRequest *fetch = [self.indexPathController.fetchRequest copy];
    fetch.sortDescriptors = @[sort];
    self.indexPathController.fetchRequest = fetch;
    [self.indexPathController performFetch:nil];
}

@end
