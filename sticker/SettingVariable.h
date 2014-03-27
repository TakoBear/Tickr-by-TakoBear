//
//  settingVariable.h
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFileStoreDirectory      @"StickerDocument"
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]

//ChatApp type key
#define kChooseChatAppTypeKey @"choose_chatApp_key"

typedef NS_ENUM(int, ChatAppType) {
    ChatAppType_Line,
    ChatAppType_WhatsApp
};

@interface SettingVariable : NSObject

+ (SettingVariable *)sharedInstance;

@property (nonatomic, retain) NSMutableDictionary *variableDictonary;

@end
