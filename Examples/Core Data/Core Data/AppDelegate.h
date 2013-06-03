//
//  AppDelegate.h
//  Core Data
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIManagedDocument *document;
- (void)documentWithHandler:(void (^)(UIManagedDocument *doc))block;
@end
