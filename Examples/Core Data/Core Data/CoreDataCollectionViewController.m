//
//  CoreDataCollectionViewController.m
//  Core Data
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

#import "CoreDataCollectionViewController.h"
#import "Item.h"
#import "UIColor+Hex.h"

#define MAX_ITEMS 20
#define DELAY_SECONDS .5

@interface CoreDataCollectionViewController ()
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSArray *colors;
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
    [self documentWithHandler:^(UIManagedDocument *doc) {
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
        fetch.sortDescriptors = @[];
        self.indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:fetch managedObjectContext:doc.managedObjectContext sectionNameKeyPath:nil identifierKeyPath:nil cacheName:nil];
        [self insertItem];
        [self.indexPathController performFetch:nil];
    }];
}

- (void)insertItem
{
    if (self.indexPathController.items.count > MAX_ITEMS) {
        NSInteger randomItemIdx = rand() % self.indexPathController.items.count;
        Item *item = self.indexPathController.items[randomItemIdx];
        [self.document.managedObjectContext deleteObject:item];
        [self.document savePresentedItemChangesWithCompletionHandler:^(NSError *errorOrNil) {
            [self insertItem];
        }];
        return;
    }
    
    else {
        
        Item *item;
        if (self.indexPathController.items.count == MAX_ITEMS) {
            item = self.indexPathController.items[rand() % MAX_ITEMS];
        } else {
            item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.document.managedObjectContext];
        }

        //insert item with random letter and color
        item.text = [NSString stringWithFormat:@"%c", 'A' + rand() % 26];
        item.color = @(rand() % self.colors.count);
        
        NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:item];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];

    }
    
    [self.document savePresentedItemChangesWithCompletionHandler:^(NSError *errorOrNil) {
        [self performSelector:@selector(insertItem) withObject:self afterDelay:DELAY_SECONDS];
    }];
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = item.text;
    cell.backgroundColor = self.colors[[item.color integerValue]];
    label.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
    cell.layer.cornerRadius = 10;
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

#pragma mark - Accessing the managed document

- (void)documentWithHandler:(void (^)(UIManagedDocument *doc))block
{
    if (self.document) {
        block(self.document);
    } else {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *docURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask] lastObject];
        docURL = [docURL URLByAppendingPathComponent:@"CodeDataDoc"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:docURL];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[docURL path]]) {
            [self.document openWithCompletionHandler:^(BOOL success){
                block(self.document);
            }];
        }
        else {
            [self.document saveToURL:docURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                block(self.document);
            }];
        }
    }
}


@end
