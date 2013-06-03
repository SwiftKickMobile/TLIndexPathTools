//
//  AppDelegate.m
//  Core Data
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)documentWithHandler:(void (^)(UIManagedDocument *doc))block
{
    if (self.document) {
        block(self.document);
    } else {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *docURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask] lastObject];
        docURL = [docURL URLByAppendingPathComponent:@"CodeDataDoc"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:docURL];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[docURL path]]) {
            [self.document openWithCompletionHandler:^(BOOL success){
                block(self.document);
            }];
        }
        else {
            [self.document saveToURL:docURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                block(self.document);
            }];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

@end
