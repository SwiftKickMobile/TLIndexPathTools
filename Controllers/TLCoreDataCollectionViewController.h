//
//  TLCoreDataCollectionViewController.h
//
//  Created by Tim Moose on 10/3/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TLCoreDataCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
