//
//  TLInMemoryFetchedResultsController.h
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

/**
 Subclass of NSFetchedResultsController that can sort and filter the result set
 with smooth animation in UITableView and UICollectionView. The standard
 NSFetchedResultsController cannot do this because any change to the fetch
 request requires a full reload on the table or collection view, which is not
 animated. The sorting and filtering is done in-memory, so this class may
 may not scale to large data sets.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TLIndexPathUpdates.h"

//sent whenever a TLDataModelController changes it's content for any reason
extern NSString * const TLDataModelControllerChangedNotification;


@class TLInMemoryFetchedResultsController;

@protocol TLInMemoryFetchedResultsControllerDelegate <NSFetchedResultsControllerDelegate>
@optional
- (void)controller:(TLInMemoryFetchedResultsController *)controller didChangeContentWithUpdates:(TLIndexPathUpdates *)updates;
@end

@interface TLInMemoryFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) id<NSFetchedResultsControllerDelegate> delegate;
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@property (strong, nonatomic, readonly) NSArray *coreDataFetchedObjects;
@property (strong, nonatomic) NSPredicate *inMemoryPredicate;
@property (strong, nonatomic) NSArray *inMemorySortDescriptors;
@property (nonatomic) BOOL isFetched;
- (void)setInMemoryPredicate:(NSPredicate *)inMemoryPredicate andInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors;
- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name;
@end
