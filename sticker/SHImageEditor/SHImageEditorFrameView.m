//
//  SHImageEditorFrameView.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "SHImageEditorFrameView.h"
#import <QuartzCore/QuartzCore.h>

@interface SHImageEditorFrameView ()
{
    UIImageView *imgView;
}

@end

@implementation SHImageEditorFrameView

@synthesize cropRect = _cropRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.opaque = NO;
    self.layer.opacity = 0.7f;
    self.backgroundColor = [UIColor clearColor];
    imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:imgView];
}

- (void)dealloc
{
    [imgView release], imgView = nil;
    [super dealloc];
}

#pragma mark - SHImageEditorFrameProtocol

- (void)setCropRect:(CGRect)cropRect
{
    if (!CGRectEqualToRect(_cropRect, cropRect)) {
        _cropRect = CGRectOffset(cropRect, self.frame.origin.x, self.frame.origin.y);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor blackColor] setFill];
        UIRectFill(self.bounds);
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor);
        CGContextStrokeRect(context, cropRect);
        [[UIColor clearColor] setFill];
        UIRectFill(CGRectInset(cropRect, 1, 1));
        imgView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
}

@end
