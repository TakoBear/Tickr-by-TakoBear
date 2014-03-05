//
//  SHLineKit.m
//  SHLineKitDemo
//
//  Created by shouian on 2014/2/2.
//  Copyright (c) 2014年 shouian. All rights reserved.
//

#import "SHLineKit.h"

@interface UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard;

@end

@implementation UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard
{
    UIPasteboard *pasteboard;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7.0) {
        pasteboard = [UIPasteboard pasteboardWithName:@"jp.naver.linecamera.pasteboard" create:YES];
    } else {
        pasteboard = [UIPasteboard generalPasteboard];
    }
    return pasteboard;
}

@end

@implementation SHLineKit

+ (BOOL)isUserInstallLine
{
    // You can type line:// with Safari, this is the same effect
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

+ (void)shareLineWithMessage:(NSString *)message
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/text/%@", [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
}

+ (void)shareLineWithImage:(UIImage *)image
{
    UIPasteboard *pasteboard = [UIPasteboard generatePasteLineBoard];
    [pasteboard setData:UIImageJPEGRepresentation(image, 1.0f) forPasteboardType:@"public.jpeg"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name]]];
}

@end
