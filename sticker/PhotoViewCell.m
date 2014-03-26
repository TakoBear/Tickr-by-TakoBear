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
        
        _deleteImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _deleteImgView.backgroundColor = [UIColor clearColor];
        _deleteImgView.userInteractionEnabled = YES;
        UIImage *deleteImage = [UIImage imageNamed:@"Delete.png"];
        [_deleteImgView setImage:deleteImage];
        _deleteImgView.frame = CGRectMake(0, 0, self.bounds.size.width *1/3, self.bounds.size.width *1/3);
        _deleteImgView.hidden = YES;
        [_imgView addSubview:_deleteImgView];
        
        [self.contentView addSubview:_imgView];
        [self.contentView addSubview:_progressView];
        [_deleteImgView release];
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
