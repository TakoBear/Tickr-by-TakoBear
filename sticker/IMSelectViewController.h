//
//  IMSelectViewController.h
//  sticker
//
//  Created by shouian on 2014/4/3.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMSelectViewController;

@protocol IMSelectViewControllerDelegate <NSObject>
@optional
- (void)IMViewController:(IMSelectViewController *)viewController didSelectAtIndex:(NSIndexPath *)indexPath;
@end

@interface IMSelectViewController : UIViewController

- (id)initWithImageData:(NSData *)imgData;

@property (nonatomic, assign) id<IMSelectViewControllerDelegate>delegate;

@end
