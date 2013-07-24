//
//  TLForwardingIndexPathController.h
//  HomeStory
//
//  Created by Tim Moose on 7/24/13.
//  Copyright (c) 2013 tmoose@vast.com. All rights reserved.
//

/**
 Forwards all API calls to another controller. This can be used to have
 a single controller connected to multiple clients (it is not particularly
 easy to share a single controller since there is only one delegate.)
 */

#import "TLIndexPathController.h"

@interface TLForwardingIndexPathController : TLIndexPathController

@end
