//
//  TLDynamicHeightView.h
//  DealerCarStory
//
//  Created by Tim Moose on 4/28/13.
//
//

#import <Foundation/Foundation.h>

@protocol TLDynamicHeightView <NSObject>
- (CGFloat) heightWithData:(id)data;
@end
