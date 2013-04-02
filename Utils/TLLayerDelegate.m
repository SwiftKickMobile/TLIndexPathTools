//
//  TLLayerDelegate.m
//  DealerCarStory
//
//  Created by Tim Moose on 3/18/13.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>

#import "TLLayerDelegate.h"

@interface TLLayerDelegate ()
@property (weak, nonatomic) UIView *view;
@end

@implementation TLLayerDelegate

-(id) initWithView: (UIView*) view {
    self = [super init];
    if (self != nil) {
        _view = view;
    }
    return self;
}

-(void) drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    NSString* methodName = [NSString stringWithFormat: @"draw%@Layer:inContext:", layer.name];
    SEL selector = NSSelectorFromString(methodName);
    if ( ![self.view respondsToSelector:selector]) {
        selector = @selector(drawLayer:inContext:);
    }
    NSMethodSignature * signature = [[self.view class] instanceMethodSignatureForSelector:selector];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self.view];
    [invocation setSelector:selector];
    [invocation setArgument:&layer atIndex:2];
    [invocation setArgument:&context atIndex:3];
    [invocation invoke];
}

@end
