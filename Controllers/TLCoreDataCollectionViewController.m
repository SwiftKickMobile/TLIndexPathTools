//
//  TLCoreDataCollectionViewController.m
//
//  Created by Tim Moose on 10/3/12.
//
//

#import "TLCoreDataCollectionViewController.h"

@interface TLCoreDataCollectionViewController ()
{
    NSMutableArray *_sectionChangeQueue;
    NSMutableArray *_objectChangeQueue;
    BOOL isEmptyFetch;
}
@end

@implementation TLCoreDataCollectionViewController

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        [fetchedResultsController setDelegate:self];
        isEmptyFetch = [fetchedResultsController fetchedObjects].count == 0;
        [self.collectionView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objectChangeQueue = [[NSMutableArray alloc] init];
    _sectionChangeQueue = [[NSMutableArray alloc] init];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sectionCount = [[self.fetchedResultsController sections] count];
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger rowCount = [sectionInfo numberOfObjects];
    return rowCount;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }

    [_sectionChangeQueue addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        change[@(type)] = newIndexPath;
        break;
        case NSFetchedResultsChangeDelete:
        change[@(type)] = indexPath;
        break;
        case NSFetchedResultsChangeUpdate:
        change[@(type)] = indexPath;
        break;
        case NSFetchedResultsChangeMove:
        change[@(type)] = @[indexPath, newIndexPath];
        break;
    }
    [_objectChangeQueue addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Workaround for UICollectionView bug(?) inserting item from empty state
    if (isEmptyFetch) {
        [self.collectionView reloadData];
        isEmptyFetch = NO;
        [_sectionChangeQueue removeAllObjects];
        [_objectChangeQueue removeAllObjects];
        return;
    }

    if ([_sectionChangeQueue count] > 0 || [_objectChangeQueue count] > 0) {
        [self.collectionView performBatchUpdates:^{

            for (NSDictionary *change in _sectionChangeQueue) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                        case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                        case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    }
                }];
            }

            for (NSDictionary *change in _objectChangeQueue) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                        case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];                        
                        break;
                        case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                        case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                    }
                }];
                
            }
            
        } completion:nil];
    }
    
    [_sectionChangeQueue removeAllObjects];
    [_objectChangeQueue removeAllObjects];
}

@end
