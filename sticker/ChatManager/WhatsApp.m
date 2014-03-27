//
//  WhatsApp.m
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "WhatsApp.h"

@interface WhatsApp () <UIDocumentInteractionControllerDelegate>

@end

@implementation WhatsApp

- (BOOL)isUserInstalledApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]];
}

- (void)shareWithImage:(NSData *)imageData
{
    NSString* savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
    [imageData writeToFile:savePath atomically:YES];
    UIDocumentInteractionController* documentInteractionController = [[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]] retain];
    documentInteractionController.UTI = @"net.whatsapp.image";
    documentInteractionController.delegate = self;
    UIView *inView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    [documentInteractionController presentOpenInMenuFromRect:CGRectMake(0,0,0,0) inView:inView animated: YES];
    
}

@end
