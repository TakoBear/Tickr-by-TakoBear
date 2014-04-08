//
//  JMDropMenuView.m
//  animatePractice
//
//  Created by 李健銘 on 2014/3/31.
//  Copyright (c) 2014年 李健銘. All rights reserved.
//

#import "JMDropMenuView.h"

typedef void (^JMDropAnimation)(void);
typedef void (^JMDropAnimationComplete)(BOOL finished);

@interface JMDropMenuView ()
{
    __block NSInteger imgViewsCount;
}
@end

@implementation JMDropMenuView

@synthesize imgViews = _imgViews;

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
        if (!_animateInterval) {
            _animateInterval = 0.5f;
        }
        
        if (!_animateDirect) {
            _animateDirect = Animate_Drop_To_Bottom;
        }
    }
    return self;
}

- (void)dealloc
{
    [_imgViews release]; _imgViews = nil;
    [super dealloc];
}

- (void)setDelegate:(id<JMDropMenuViewDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        [self setUpViews];
    }
}

#pragma mark - Initialization
- (void)setUpViews
{
    imgViewsCount = 0;
    
    for (id obj in self.subviews) {
        if ([obj isKindOfClass:[UIImageView class]] || [obj isKindOfClass:[UIView class]]) {
            [obj removeFromSuperview];
        }
    }
    
    // Set up self frame
    id obj = [_imgViews objectAtIndex:0];
    CGFloat width = CGRectGetWidth([obj bounds]);
    CGFloat height = CGRectGetHeight([obj bounds]);
    
    switch (_animateDirect) {
        case Animate_Drop_To_Top:
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - height * (_imgViews.count - 1), width, height * _imgViews.count)];
        }
            break;
        case Animate_Drop_To_Bottom:
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height * _imgViews.count)];
        }
            break;
        case Animate_Drop_To_Left:
        {
            [self setFrame:CGRectMake(self.frame.origin.x - width * (_imgViews.count - 1), self.frame.origin.y, width * _imgViews.count, height)];
        }
            break;
        case Animate_Drop_To_Right:
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width * _imgViews.count, height)];
        }
            break;
            
        default:
            break;
    }
    
    // Add gesture
    for (NSInteger i = 0; i < _imgViews.count; i++) {
        id obj = [_imgViews objectAtIndex:i];
        if ([obj isKindOfClass:[UIImageView class]] || [obj isKindOfClass:[UIView class]]) {
            [obj setUserInteractionEnabled:NO];
            [obj setAlpha:0.0f];
            [(UIView *)obj setTransform:CGAffineTransformMakeRotation(M_PI)];
            
            CGFloat width = CGRectGetWidth([obj bounds]);
            CGFloat height = CGRectGetHeight([obj bounds]);
            NSInteger sequence;
            
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    sequence = _imgViews.count - i - 1 ;
                    if (sequence == _imgViews.count - 1) {
                        [obj setFrame:CGRectMake(0, sequence * width, width, height)];
                    } else {
                        [obj setFrame:CGRectMake(0,(sequence + 1) * height, width, height)];
                    }
                    
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    sequence = i;
                    if (sequence == 0) {
                        [obj setFrame:CGRectMake(0, 0, width, height)];
                    } else {
                        [obj setFrame:CGRectMake(0, (sequence - 1) * height, width, height)];
                    }
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    sequence = _imgViews.count - i - 1 ;
                    if (sequence == _imgViews.count - 1) {
                        [obj setFrame:CGRectMake(sequence * width, 0, width, height)];
                    } else {
                        [obj setFrame:CGRectMake((sequence + 1) * width, 0, width, height)];
                    }
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    sequence = i;
                    if (sequence == 0) {
                        [obj setFrame:CGRectMake(0, 0, width, height)];
                    } else {
                        [obj setFrame:CGRectMake((sequence - 1) * width, 0, width, height)];
                    }
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
    JMDropAnimation animation = ^(void) {
        
        UIView *view = (UIView *)[_imgViews objectAtIndex:imgViewsCount];
        view.transform = CGAffineTransformRotate(view.transform, -M_PI);
        view.alpha = 1;
        
        CGFloat width = CGRectGetWidth([view bounds]);
        CGFloat height = CGRectGetHeight([view bounds]);
        
        NSInteger backSequece  = _imgViews.count - imgViewsCount - 1 ;
        if (imgViewsCount > 0) {
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    [view setFrame:CGRectMake(0, backSequece * height, width, height)];
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    [view setFrame:CGRectMake(0, imgViewsCount * height, width, height)];
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    [view setFrame:CGRectMake(backSequece * height, 0, width, height)];
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    [view setFrame:CGRectMake(imgViewsCount * width, 0, width, height)];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        imgViewsCount++;
        
        if (imgViewsCount == _imgViews.count) {
            imgViewsCount = 0;
            
            for (id subView in self.subviews) {
                [subView setUserInteractionEnabled:YES];
            }
            
        }
    };
    
    JMDropAnimationComplete complete = ^(BOOL finished) {
        if (finished && (imgViewsCount != _imgViews.count) && (imgViewsCount != 0)) {
            [self popOut];
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(didFinishedPopOutWithDropMenu:)]) {
                [_delegate didFinishedPopOutWithDropMenu:self];
            }
        }
    };
    
    [UIView animateWithDuration:_animateInterval delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:complete];
    
}

- (void)dismiss
{
    JMDropAnimation animation = ^(void) {
        NSInteger count = _imgViews.count - imgViewsCount - 1;
        UIView *view = (UIView *)[_imgViews objectAtIndex:count];
        view.transform = CGAffineTransformRotate(view.transform, -M_PI);
        view.alpha = 0;
        
        CGFloat width = CGRectGetWidth([view bounds]);
        CGFloat height = CGRectGetHeight([view bounds]);
        
        if (count != 0) {
            switch (_animateDirect) {
                case Animate_Drop_To_Top:
                {
                    [view setFrame:CGRectMake(0,imgViewsCount * width, width, height)];
                }
                    break;
                case Animate_Drop_To_Bottom:
                {
                    [view setFrame:CGRectMake(0, (count-1) * width, width, height)];
                }
                    break;
                case Animate_Drop_To_Left:
                {
                    [view setFrame:CGRectMake(imgViewsCount * height, 0, width, height)];
                    
                }
                    break;
                case Animate_Drop_To_Right:
                {
                    [view setFrame:CGRectMake((count-1) * height, 0, width, height)];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        imgViewsCount++;
        
        if (imgViewsCount == _imgViews.count) {
            imgViewsCount = 0;
            
            for (id subView in self.subviews) {
                [subView setUserInteractionEnabled:YES];
            }
        }
    };
    
    JMDropAnimationComplete complete = ^(BOOL finished) {
        if (finished && (imgViewsCount != _imgViews.count) && (imgViewsCount != 0)) {
            [self dismiss];
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(didFinishedDismissWithDropMenu:)]) {
                [_delegate didFinishedDismissWithDropMenu:self];
            }
        }
    };
    
    [UIView animateWithDuration:_animateInterval delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:complete];
    
}

- (void)resetPosition
{
    for (int i = 0; i < _imgViews.count; i++) {
        id obj = [_imgViews objectAtIndex:i];
        if ([obj isKindOfClass:[UIImageView class]] || [obj isKindOfClass:[UIView class]]) {
            [obj setUserInteractionEnabled:NO];
            [obj setAlpha:0.0f];
            [(UIView *)obj setTransform:CGAffineTransformMakeRotation(M_PI)];
            
            CGFloat width = CGRectGetWidth([obj bounds]);
            CGFloat height = CGRectGetHeight([obj bounds]);
            
            NSInteger backSequece  = _imgViews.count - i - 1 ;
            if (imgViewsCount > 0) {
                switch (_animateDirect) {
                    case Animate_Drop_To_Top:
                    {
                        [obj setFrame:CGRectMake(0, backSequece * height, width, height)];
                    }
                        break;
                    case Animate_Drop_To_Bottom:
                    {
                        [obj setFrame:CGRectMake(0, i * height, width, height)];
                    }
                        break;
                    case Animate_Drop_To_Left:
                    {
                        [obj setFrame:CGRectMake(backSequece * height, 0, width, height)];
                    }
                        break;
                    case Animate_Drop_To_Right:
                    {
                        [obj setFrame:CGRectMake(i * width, 0, width, height)];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}
#pragma mark - Gesture
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    
    NSInteger index = [_imgViews indexOfObject:view];
    
    if (_delegate && [_delegate respondsToSelector:@selector(dropMenu:didSelectAtIndex:)]) {
        [_delegate dropMenu:self didSelectAtIndex:index];
    }
}

@end
