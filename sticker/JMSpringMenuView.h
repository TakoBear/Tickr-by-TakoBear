//
//  JMSpringMenuView.h
//  sticker
//
//  Created by 李健銘 on 2014/4/9.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMDropMenuView.h"

@class JMSpringMenuView;

@protocol JMSpringMenuViewDelegate <NSObject>

@optional
- (void)springMenu:(JMSpringMenuView *)menu didSelectAtIndex:(NSInteger)index;
- (void)didFinishedPopOutWithSpringMenu:(JMSpringMenuView *)menu;
- (void)didFinishedDismissWithSpringMenu:(JMSpringMenuView *)menu;

@end

@interface JMSpringMenuView : UIView

@property (nonatomic, assign) id<JMSpringMenuViewDelegate>delegate;
@property (readonly, retain) NSArray *imgViews;
@property (nonatomic) float animateInterval;
@property (nonatomic) float viewsInterval;
@property (nonatomic) float animateDelay;
@property (nonatomic) float animateDamping;
@property (nonatomic) float animateVelocity;
@property (nonatomic) NSInteger animateDirect;


- (id)initWithViews:(NSArray *)imgViews;
- (void)popOut;
- (void)dismiss;


@end
