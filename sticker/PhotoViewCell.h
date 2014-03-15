//
//  PhotoViewCell.h
//  sticker
//
//  Created by 李健銘 on 2014/2/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface PhotoViewCell : UICollectionViewCell

@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic) BOOL isProgress;
@property (nonatomic, assign) DACircularProgressView *progressView;

@end
