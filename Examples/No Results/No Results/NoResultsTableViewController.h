//
//  NoResultsTableViewController.h
//  No Results
//
//  Created by Tim Moose on 8/22/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "TLTableViewController.h"

@interface NoResultsTableViewController : TLTableViewController
@property (strong, nonatomic) IBOutlet UIButton *hideRowsButton;
- (IBAction)toggleHideRows;
@end
