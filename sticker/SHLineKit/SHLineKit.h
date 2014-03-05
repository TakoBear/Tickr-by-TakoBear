//
//  SHLineKit.h
//  SHLineKitDemo
//
//  Created by shouian on 2014/2/2.
//  Copyright (c) 2014年 shouian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHLineKit : NSObject

+ (BOOL)isUserInstallLine;

+ (void)shareLineWithMessage:(NSString *)message;
+ (void)shareLineWithImage:(UIImage *)image;

@end
