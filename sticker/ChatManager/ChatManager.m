//
//  ChatManager.m
//  sticker
//
//  Created by 李健銘 on 2014/3/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "ChatManager.h"
#import "SettingVariable.h"
#import "LineChat.h"
#import "WhatsApp.h"

@implementation ChatManager

- (ChatApp *)currentChatAppWithType
{
    int chatAppType = [[[SettingVariable sharedInstance].variableDictionary objectForKey:kChooseChatAppTypeKey] intValue];
    switch (chatAppType) {
        case ChatAppType_Line:
        {
            ChatApp *chat = [LineChat new];
            return chat;
        }
            break;
        case ChatAppType_WhatsApp:
        {
            ChatApp *chat = [WhatsApp new];
            return chat;
        }
        default:
            break;
    }
    
    
    return NULL;
}

@end
