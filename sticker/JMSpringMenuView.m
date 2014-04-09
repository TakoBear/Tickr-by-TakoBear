//
//  JMSpringMenuView.m
//  sticker
//
//  Created by 李健銘 on 2014/4/9.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "JMSpringMenuView.h"


@interface JMSpringMenuView ()
{
    __block NSInteger imgViewsCount;
}

@end

@implementation JMSpringMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithViews:(NSArray *)imgViews
{
    self = [super init];
    if (self) {
        _imgViews = [imgViews copy];
        _animateDirect = Animate_Drop_To_Bottom;
        _viewsInterval = 0;
        _animateInterval = 0.5f;
        _animateDelay = 0;
        _animateVelocity = 0.5;
        _animateDamping = 0.5;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setDelegate:(id<JMSpringMenuViewDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        [self setUpViews];
    }
}

- (void)setUpViews
{
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    id view  = [_imgViews objectAtIndex:0];
    CGFloat originX = self.frame.origin.x;
    CGFloat originY = self.frame.origin.y;
    CGFloat width = CGRectGetWidth([view bounds]);
    CGFloat viewsInterval = width + _viewsInterval;
    
    switch (_animateDirect) {
        case Animate_Drop_To_Top:
        {
            [self setFrame:CGRectMake(originX,originY - viewsInterval * _imgViews.count , width, viewsInterval * (_imgViews.count+1))];
        }
            break;
        case Animate_Drop_To_Bottom:
        {
            [self setFrame:CGRectMake(originX,originY, width, viewsInterval * (_imgViews.count+1))];
        }
            break;
        case Animate_Drop_To_Left:
        {
            [self setFrame:CGRectMake(originX - viewsInterval * _imgViews.count, originY, viewsInterval * _imgViews.count, width)];
        }
            break;
        case Animate_Drop_To_Right:
        {
            [self setFrame:CGRectMake(originX,originY, viewsInterval * _imgViews.count, width)];
        }
            break;
            
        default:
            break;
    }
    
    for (NSInteger i = 0; i < _imgViews.count; i++) {
        id obj = [_imgViews objectAtIndex:i];
        if ([obj isKindOfClass:[UIImageView class]] || [obj isKindOfClass:[UIView class]]) {
            [obj setUserInteractionEnabled:NO];
            [obj setAlpha:0.0f];
            
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    [obj setFrame:CGRectMake(0, viewsInterval * _imgViews.count , width, width)];
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    [obj setFrame:CGRectMake(0, 0, width, width)];
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    [obj setFrame:CGRectMake(viewsInterval * _imgViews.count, 0, width, width)];
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    [obj setFrame:CGRectMake(0, 0 , width, width)];
                }
                    break;
                    
                default:
                    break;
            }
            
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [obj addGestureRecognizer:tapGesture];
            [tapGesture release];
            [self addSubview:obj];
        }
    }

    
}

#pragma mark - Animation

- (void)popOut
{
    id view  = [_imgViews objectAtIndex:0];
    CGFloat width = CGRectGetWidth([view bounds]);
    CGFloat viewsInterval = width + _viewsInterval;
    
    [UIView animateWithDuration:_animateInterval delay:_animateDelay usingSpringWithDamping:_animateDamping initialSpringVelocity:_animateVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (int count = 1 ; count <= _imgViews.count ; count ++) {
            
            id obj = [_imgViews objectAtIndex:(count-1)];
            [obj setAlpha:1.0f];
            
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    [obj setFrame:CGRectMake(0, viewsInterval * (_imgViews.count-count)  , width, width)];
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    [obj setFrame:CGRectMake(0, viewsInterval * count , width, width)];
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    [obj setFrame:CGRectMake(viewsInterval * (_imgViews.count-count), 0, width, width)];
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    [obj setFrame:CGRectMake(viewsInterval * count, 0 , width, width)];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    }completion:^(BOOL finished){
        if (finished) {
            for (id subviews in self.subviews) {
                [subviews setUserInteractionEnabled:YES];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(didFinishedPopOutWithDropMenu:)]) {
                [_delegate didFinishedPopOutWithSpringMenu:self];
            }
        }
    }];
}

- (void)dismiss
{
    id view  = [_imgViews objectAtIndex:0];
    CGFloat width = CGRectGetWidth([view bounds]);
    CGFloat viewsInterval = width + _viewsInterval;
    
    [UIView animateWithDuration:_animateInterval delay:_animateDelay usingSpringWithDamping:_animateDamping initialSpringVelocity:_animateVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (int count = 1 ; count <= _imgViews.count ; count ++) {
            
            id obj = [_imgViews objectAtIndex:(count-1)];
            [obj setAlpha:0.0f];
            
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    [obj setFrame:CGRectMake(0, viewsInterval * _imgViews.count , width, width)];
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    [obj setFrame:CGRectMake(0, 0, width, width)];
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    [obj setFrame:CGRectMake(viewsInterval * _imgViews.count, 0, width, width)];
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    [obj setFrame:CGRectMake(0, 0 , width, width)];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    }completion:^(BOOL finished){
        if (finished) {
            for (id subviews in self.subviews) {
                [subviews setUserInteractionEnabled:NO];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(didFinishedDismissWithDropMenu:)]) {
                [_delegate didFinishedDismissWithSpringMenu:self];
            }
        }
    }];

}

#pragma mark - Gesture

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    NSInteger index = [_imgViews indexOfObject:view];
    
    if (_delegate && [_delegate respondsToSelector:@selector(springMenu:didSelectAtIndex:)]) {
        [_delegate springMenu:self didSelectAtIndex:index];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
