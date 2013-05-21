//
//  TLTableViewController.h
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import <UIKit/UIKit.h>

#import "TLIndexPathController.h"

@interface TLTableViewController : UITableViewController <TLIndexPathControllerDelegate>
@property (strong, nonatomic) TLIndexPathController *indexPathController;
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reconfigureVisibleCells;
@end
