//
//  AppDelegate.m
//  sticker
//
//  Created by 李健銘 on 2014/2/18.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "AppDelegate.h"
#import "IndexViewController.h"
#import "WXApi.h"
#import "SettingVariable.h"

#import "External/WYPopoverController/WYPopoverController.h"

@interface AppDelegate() <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:WXAPI_KEY];
    
    [[UINavigationBar appearance] setBarTintColor:RGBA(247.0f, 166.0f, 0.0f, 1.0f)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    UINavigationBar *navBarInPopoverAppearance = [UINavigationBar appearanceWhenContainedIn:[UINavigationController class], [WYPopoverBackgroundView class], nil];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor clearColor]];
    [shadow setShadowOffset:CGSizeZero];
    
    [navBarInPopoverAppearance setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName : [UIColor purpleColor],
       NSShadowAttributeName: shadow
       }];
    
    WYPopoverBackgroundView* popoverAppearance = [WYPopoverBackgroundView appearance];
    [popoverAppearance setOuterCornerRadius:0.0f];
    [popoverAppearance setInnerCornerRadius:0.0f];
    [popoverAppearance setFillTopColor:RGBA(127, 127, 127, 0.8f)];
    [popoverAppearance setViewContentInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Override point for customization after application launch
    IndexViewController *indexVC = [[IndexViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:indexVC];
    [navigation setToolbarHidden:YES];
    [_window setRootViewController:navigation];
    [_window setBackgroundColor:[UIColor whiteColor]];
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *scheme = (NSString *)url.scheme;
    BOOL bResult = YES;
    
    if ([scheme isEqualToString:WXAPI_KEY]) {
        bResult = [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

@end
