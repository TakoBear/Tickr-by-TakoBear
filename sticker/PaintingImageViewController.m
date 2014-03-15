//
//  PaintingImageViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PaintingImageViewController.h"

@interface PaintingImageViewController ()
{
    UIImage *_srcImage;
}

@end

@implementation PaintingImageViewController

- (id)initWithImage:(UIImage *)img
{
    self = [super init];
    if (self) {
        _srcImage = img;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide search bar
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            [view setHidden:YES];
        }
    }
}

@end
