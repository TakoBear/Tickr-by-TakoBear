//
//  LineChat.m
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "LineChat.h"

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

@implementation LineChat

- (BOOL)isUserInstalledApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

- (void)shareWithImage:(NSData *)imageData
{
    UIPasteboard *pasteboard = [UIPasteboard generatePasteLineBoard];
    [pasteboard setData:imageData forPasteboardType:@"public.jpeg"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name]]];
}



@end
