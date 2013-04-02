//
//  TLGridCellView.m
//  DealerCarStory
//
//  Created by Tim Moose on 3/22/13.
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

#import "TLGridCellView.h"
#import "TLLayerDelegate.h"

@interface TLGridCellView ()
@property (strong, nonatomic) CALayer *gridLayer;
@property (strong, nonatomic) TLLayerDelegate *layerDelegate;
@end

@implementation TLGridCellView

- (void)setLeftView:(UIView *)leftView
{
    if (_leftView != leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        [self addSubview:leftView];
    }
}

- (void)setRightView:(UIView *)rightView
{
    if (_rightView != rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        [self addSubview:rightView];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (_backgroundView != backgroundView) {
        if (self.backgroundView) {
            [self.backgroundView removeFromSuperview];
        }
        _backgroundView = backgroundView;
        if (backgroundView) {
            backgroundView.frame = self.bounds;
            [self insertSubview:backgroundView atIndex:0];
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (backgroundImage) {
        UIImageView *view = [[UIImageView alloc] initWithImage:backgroundImage];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView = view;
    } else {
        self.backgroundView = nil;
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.gridLayer.frame = self.bounds;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    CGRect labelRect = UIEdgeInsetsInsetRect(contentRect, self.labelInsets);
    
    if (self.leftView) {
        CGFloat width = self.leftView.bounds.size.width;
        self.leftView.center = CGPointMake(contentRect.origin.x + width / 2.0, CGRectGetMidY(contentRect));
        labelRect.size.width -= width;
        labelRect.origin.x += width;
    }

    if (self.rightView) {
        CGFloat width = self.rightView.bounds.size.width;
        self.rightView.center = CGPointMake(CGRectGetMaxX(contentRect) - width / 2.0, CGRectGetMidY(contentRect));
        labelRect.size.width -= width;
    }
    
    self.label.frame = labelRect;
}

- (void)drawGridLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGFloat borderWidth = 1;

    CGRect rect = layer.frame;
    
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, borderWidth);
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    
    if (self.border & TLGridBorderTop) {
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, 0);
        CGContextStrokePath(ctx);
    }
    
    if (self.border & TLGridBorderLeft) {
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, 0, rect.size.height);
        CGContextStrokePath(ctx);
    }
    
    if (self.border & TLGridBorderBottom) {
        CGContextMoveToPoint(ctx, 0, rect.size.height);
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
        CGContextStrokePath(ctx);
    }
    
    if (self.border & TLGridBorderRight) {
        CGContextMoveToPoint(ctx, rect.size.width, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
        CGContextStrokePath(ctx);
    }
    
    CGContextRestoreGState(ctx);
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _layerDelegate = [[TLLayerDelegate alloc] initWithView:self];
        _gridLayer = [[CALayer alloc] initWithLayer:self.layer];
        _gridLayer = [[CALayer alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.name = @"Grid";
        _gridLayer.delegate = _layerDelegate;
        [_gridLayer setNeedsDisplay];
        _gridLayer.zPosition = 10000;
        [self.layer addSublayer:_gridLayer];
        [self addSubview:_label];
    }
    return self;
}

@end
