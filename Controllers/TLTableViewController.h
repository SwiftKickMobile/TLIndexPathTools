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
- (void)configureCell:(UITableViewCell *)cell forIdentifier:(id)identifier andDataModel:(TLIndexPathDataModel *)dataModel;
- (void)reconfigureVisibleCells;
@end
