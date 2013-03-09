//
//  TLCoreDataCollectionViewController.m
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

#import "TLCoreDataCollectionViewController.h"

@interface TLCoreDataCollectionViewController ()
@property (strong, nonatomic) NSMutableArray *sectionChangeQueue;
@property (strong, nonatomic) NSMutableArray *objectChangeQueue;
@end

@implementation TLCoreDataCollectionViewController

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        [fetchedResultsController setDelegate:self];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if(self.sectionChangeQueue.count > 0 || self.objectChangeQueue.count > 0) {
        //This is kind of a big deal.
        NSLog(@"Content has changed while currently processing batch updates.");
    }
    [self.sectionChangeQueue removeAllObjects];
    [self.objectChangeQueue removeAllObjects];
}

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

    [self.sectionChangeQueue addObject:change];
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
    [self.objectChangeQueue addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self.sectionChangeQueue count] > 0 || [self.objectChangeQueue count] > 0) {
        
        if([self shouldReloadCollectionViewToPreventKnownIssue]) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            // Note - this may not be strictly necessary, but I'm putting it in to be sure
            [self.collectionView reloadData];
            //the following line is a workaround for a subtle but annoying problem with UICollectionView
            //It looks like reloadData does *not* immediately reload the table, but rather
            //does it lazily. When you call this method, the internal row count is set to undefined/zero.
            //The *next* time that numberOfItemsInSection is called, the collection view will query the datasource
            //and then use that as it's initial value. Unfortunately, the reloading of the table data can happen out of band.
            //Under certain cases, this can cause the collection view to get confused and throw an exeption. An example of this is as follows -
            //
            //Fire a batch update with a single insert into this collection view. Since the collection view is empty, we need to do
            //the above workaround to reset the table. State at this point
            //Collection View row count - 0/undefined/uncached
            //Data source row count - 1
            //
            //Immediately begin another sequence of calls to create a batch update transaction. At this point, the collection view
            //has not reloaded itself or defined the number of rows in the table. At this point, when we do the check in
            //shouldReloadCollectionViewToPreventKnownIssue to determine if we need to reload or batch process, the table
            //calls to the datasource to get the current number of rows, since it's not yet cached/lazy loaded. The data source
            //returns the (correct) count of two, and the table thinks that it has two rows. Unfortunately, we still
            //have the batch of updates to process, which causes an internal consistency exception in the performBatchUpdates
            //block - the table expects to have more rows after it than it did before.
            //To see this in action, just comment out the line below and then start a batch update from an empty state.
            for(int i=0;i<self.collectionView.numberOfSections;i++) {
                [self.collectionView numberOfItemsInSection:i];
            }

        } else {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary *change in self.sectionChangeQueue) {
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
                
                for (NSDictionary *change in self.objectChangeQueue) {
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
    }
    [self.sectionChangeQueue removeAllObjects];
    [self.objectChangeQueue removeAllObjects];        
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChangeQueue) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert: {
                    //note - do not call numberOfItemsInSection on the collectionview itself while doing
                    //batch updates - it appears to cache the value and cause the collection view
                    //to think it has more rows than are present, thus causing subsequent batch updates to fail
                    NSUInteger count = [self.collectionView numberOfItemsInSection:indexPath.section];
                    if (count == 0) {
                        shouldReload = YES;
                        *stop = YES;
                    }
                    break;
                }
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                        *stop = YES;
                    }
                    break;
//                case NSFetchedResultsChangeUpdate:
//                    shouldReload = NO;
//                    break;
//                case NSFetchedResultsChangeMove:
//                    shouldReload = NO;
//                    break;
            }
        }];
    }
    return shouldReload;
}

@end
