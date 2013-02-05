//
//  TLTableViewController.h
//  Dart Meister
//
//  Created by Tim Moose on 1/28/13.
//
//

#import <UIKit/UIKit.h>
#import "TLIndexPathDataModel.h"

@interface TLTableViewController : UITableViewController
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reconfigureVisibleCells;
@end
