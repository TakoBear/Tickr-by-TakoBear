//
//  ChatApp.h
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatApp : NSObject

- (BOOL)isUserInstalledApp;

- (void)shareWithImage:(NSData *)imageData;

@end
