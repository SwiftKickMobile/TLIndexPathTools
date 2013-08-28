//
//  JSONTableViewController.m
//  JSON
//
//  Created by Tim Moose on 6/6/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "JSONTableViewController.h"
#import <TLIndexPathTools/TLIndexPathDataModel.h>

@implementation JSONTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //simulated JSON response as an array of dictionaries
    NSArray *jsonData = @[
        @{
            @"id": @(58),
            @"title": @"title59",
            @"summary": @"summary59",
            @"datetime": @"2013.02.03",
        },
        @{
            @"id": @(57),
            @"title": @"title58",
            @"summary": @"summary58",
            @"datetime": @"2013.02.04",
        },
        @{
            @"id": @(56),
            @"title": @"title57",
            @"summary": @"summary57",
            @"datetime": @"2013.02.04",
        },
        @{
            @"id": @(55),
            @"title": @"title56",
            @"summary": @"summary56",
            @"datetime": @"2013.02.05",
        }
    ];
    //initialize index path controller with a data model containing JSON data.
    //using "datetime" as the `sectionNameKeyPath` automatically groups items
    //by "datetime". For asynchronous fetch from a server, this statement would
    //be done in the completion block of the fetch (on the main thread)
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:jsonData
                                                            sectionNameKeyPath:@"datetime"
                                                             identifierKeyPath:@"id"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"summary"];
    return cell;
}

@end
