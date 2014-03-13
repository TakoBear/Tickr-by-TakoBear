//
//  PhotoViewCell.m
//  sticker
//
//  Created by 李健銘 on 2014/2/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PhotoViewCell.h"

@implementation PhotoViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setIsProgress:NO];
        
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:_imgView];
        [self.contentView addSubview:_progressView];
        
        [_imgView release];
    }
    return self;
}

- (void)setIsProgress:(BOOL)isProgress
{
    _isProgress = isProgress;
    if (_isProgress) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:self.bounds];
        _progressView.roundedCorners = YES;
        _progressView.trackTintColor = [UIColor clearColor];
        [self.contentView addSubview:_progressView];
    }
}

@end
