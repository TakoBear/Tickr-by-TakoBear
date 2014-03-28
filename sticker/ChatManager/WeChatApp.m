//
//  WeChatApp.m
//  sticker
//
//  Created by 李健銘 on 2014/3/28.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "WeChatApp.h"
#import "WeChatSDK/WXApi.h"
#import "UIImage+ResizeImage.h"

@implementation WeChatApp

- (BOOL)isUserInstalledApp
{
    BOOL installed = [WXApi isWXAppInstalled];
    BOOL supportApi = [WXApi isWXAppSupportApi];
    return installed && supportApi;
}

- (void)shareWithImage:(NSData *)imageData
{
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.mediaObject = ext;
    // Create thumbnail, size must be less than 32KB
    UIImage *img = [UIImage imageWithData:imageData];
    [message setThumbImage:[UIImage resizeImageWithSize:img resize:CGSizeMake(128, 128)]];
//    [message setThumbImage:[QFileAppDelegate resizeImageWithSize:image resize:CGSizeMake(128, 128)]];
    
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

@end
