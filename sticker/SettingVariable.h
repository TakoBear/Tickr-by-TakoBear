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
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kAddMenuIconSize    80
#define kColorButtonSize    50

// Register
#define WXAPI_KEY               @"wxa4216b78b4ef4a3c"

//Variable Dictionary key
#define kChooseChatAppTypeKey @"choose_chatApp_key"
#define kImageDataArrayKey    @"Image_Data_Array"
#define kIMDefaultKey         @"IM_Default_Key"
#define kSaveAlbumKey         @"Save_Album_Key"

#define KTakoBearKey          @"Load_TakoBear"


typedef NS_ENUM(int, ChatAppType) {
    ChatAppType_Line,
    ChatAppType_WhatsApp,
    ChatAppType_WeChat
};

typedef NS_ENUM(int, PaintingColor) {
    PaintingColorRed,
    PaintingColorOrange,
    PaintingColorYellow,
    PaintingColorGray,
    PaintingColorBlue,
    PaintingColorCyne,
    PaintingColorGreen,
};

typedef NS_ENUM(int, PaintingBrush) {
    PaintingBrush1,
    PaintingBrush2,
    PaintingBrush3,
    PaintingBrush4,
    PaintingBrush5
};

@interface SettingVariable : NSObject

+ (SettingVariable *)sharedInstance;

- (void)addImagetoImageDataArray:(NSString *)imageName;

@property (nonatomic, retain) NSMutableDictionary *variableDictionary;

@end
