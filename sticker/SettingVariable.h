//
//  settingVariable.h
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFileStoreDirectory      @"StickerDocument"
#define kPhotoAlbumName          @"StickerAlbum"
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define kAddMenuIconSize    80

// Register
#define WXAPI_KEY               @"wxe386966df7b712ca"

//Variable Dictionary key
#define kChooseChatAppTypeKey @"choose_chatApp_key"
#define kImageDataArrayKey    @"Image_Data_Array"

typedef NS_ENUM(int, ChatAppType) {
    ChatAppType_Line,
    ChatAppType_WhatsApp,
    ChatAppType_WeChat
};

@interface SettingVariable : NSObject

+ (SettingVariable *)sharedInstance;

- (void)addImagetoImageDataArray:(NSString *)imageName;

@property (nonatomic, retain) NSMutableDictionary *variableDictionary;

@end
