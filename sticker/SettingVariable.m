//
//  settingVariable.m
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "SettingVariable.h"

@implementation SettingVariable

+ (SettingVariable *)sharedInstance {
    static SettingVariable *sharedInstance = nil;
    static dispatch_once_t onceToker;
    dispatch_once(&onceToker,^{
        sharedInstance = [[SettingVariable alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _variableDictionary = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if (![userDefault objectForKey:kChooseChatAppTypeKey]) {
            [userDefault setObject:[NSNumber numberWithInt:ChatAppType_Line] forKey:kChooseChatAppTypeKey];
        } else {
            [_variableDictionary setValue:[userDefault objectForKey:kChooseChatAppTypeKey] forKey:kChooseChatAppTypeKey];
        }
        
        if ([userDefault objectForKey:kIMDefaultKey] == nil) {
            [userDefault setObject:[NSNumber numberWithBool:NO] forKey:kIMDefaultKey];
        } else {
            [_variableDictionary setValue:[userDefault objectForKey:kIMDefaultKey] forKey:kIMDefaultKey];
        }
        
        if ([userDefault objectForKey:kSaveAlbumKey] == nil) {
            [userDefault setObject:[NSNumber numberWithBool:YES] forKey:kSaveAlbumKey];
        } else {
            [_variableDictionary setValue:[userDefault objectForKey:kSaveAlbumKey] forKey:kSaveAlbumKey];
        }
    
    }
    return self;
}

- (void)addImagetoImageDataArray:(NSString *)imageName
{
    if ([_variableDictionary objectForKey:kImageDataArrayKey]) {
        [[_variableDictionary objectForKey:kImageDataArrayKey] addObject:imageName];
    }
}


@end
