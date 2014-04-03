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
#import "WeChatApp.h"

@implementation ChatManager

- (ChatApp *)currentChatAppWithType
{
    int chatAppType = [[[SettingVariable sharedInstance].variableDictionary objectForKey:kChooseChatAppTypeKey] intValue];
    ChatApp *chat;
    switch (chatAppType) {
        case ChatAppType_Line:
        {
            chat = [LineChat new];
            return chat;
        }
            break;
        case ChatAppType_WhatsApp:
        {
            chat = [WhatsApp new];
            return chat;
        }
            break;
        case ChatAppType_WeChat:
        {
            chat = [WeChatApp new];
            return chat;
        }
            break;
        default:
            break;
    }
    
    
    return NULL;
}

- (ChatApp *)chatAppWithType:(NSInteger)type
{
    ChatApp *chat;
    switch (type) {
        case ChatAppType_Line:
        {
            chat = [LineChat new];
            return chat;
        }
            break;
        case ChatAppType_WhatsApp:
        {
            chat = [WhatsApp new];
            return chat;
        }
            break;
        case ChatAppType_WeChat:
        {
            chat = [WeChatApp new];
            return chat;
        }
            break;
        default:
            break;
    }
    
    
    return NULL;
}

@end
