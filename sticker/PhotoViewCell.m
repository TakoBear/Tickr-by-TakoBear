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
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imgView];
        [_imgView release];
    }
    return self;
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
