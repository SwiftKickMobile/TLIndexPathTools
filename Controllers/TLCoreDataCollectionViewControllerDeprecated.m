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

#import "TLCoreDataCollectionViewControllerDeprecated.h"

@interface TLCoreDataCollectionViewControllerDeprecated ()
@property (strong, nonatomic) NSMutableArray *sectionChangeQueue;
@property (strong, nonatomic) NSMutableArray *objectChangeQueue;
@end

@implementation TLCoreDataCollectionViewControllerDeprecated

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
            //when the main thread is under very heavy load.
            //
            //It looks like reloadData does *not* immediately reload the table, but rather on the very next
            //run loop iteration, it does it lazily. Until then, the value is set as undefined, and the next call to either
            //numberOfItemsInSection or the execution of the job placed on the main run loop will cause the value to
            //be stored. From then on, the UICollectionView keeps track of it's item/section counts just by the number
            //of calls to insert/delete/move section and item.
            //
            //Unfortunately, if your main thread is under very heavy load and if that load mutates your data model,
            //things can get out of sync. For example, imagine a situation like this
            // 1) Changes from a background context are merged into the main thread's context. This will cause
            //    the TLCoreDataCollectionViewController to recalulate the data model and send deltas to the delegate
            //    methods on this class - note, TLInMemoryFetchedResultsController does all of this in one run-loop iteration
            //    so that by the time controllerDidChangeContent has been invoked, there has been enough time for a background
            //    thread to schedule another merge changes job (from a new change) onto the main runloop. The call to reloadData
            //    above sets the item count to undefined, and schedules a job on the main runloop to intialize from the data
            //    source on the main run loop. Unfortunately, this job is scheduled *after* the previous merge job that will
            //    mutate the data model again.
            // 2) The second merge changes job runs, and causes another sequence of calls to willChangeContent/didChangeContent.
            //    The (unfortunately needed) workaround above in shouldReloadCollectionViewToPreventKnownIssue has to call
            //    numberOfItemsInSection. This causes the collection view to set the item count as defined and at the current
            //    count in the data model, which at this point is 2.
            // 3) We attempt to insert items below. TLInMemoryFetchedResultsController (correctly) has computed that the delta
            //    is to insert 1 row into the collection, since that's all that happened. Unfortunately, at this point
            //    the collection view already thinks that we have two rows in it. Thus the call to performBatchUpdates
            //    will cause an NSInternalInconsistencyException and the update fails.
            //
            // There are two solutions to this problem -
            // 1) make sure that all jobs on the main thread run at a low
            //  priority so that UI elements get a chance to update themselves before the job starts.
            // 2) Immediately precache the contents of the table right here and now by calling numberOfItemsInSection
            //
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
            }
        }];
    }
    return shouldReload;
}

@end
