//
//  EditViewController.h
//  sticker
//
//  Created by 李健銘 on 2014/2/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController

@property (nonatomic, retain) UIImage *originImage;
@property (nonatomic, retain) UIImage *completionImage;

- (id)initWithURL:(NSURL *)url;

@end
