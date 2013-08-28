//
//  ViewController.h
//  Minimal
//
//  Created by Tim Moose on 6/24/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TLIndexPathTools/TLIndexPathController.h>

@interface ViewController : UIViewController <TLIndexPathControllerDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
