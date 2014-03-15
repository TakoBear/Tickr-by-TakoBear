//
//  SHImageEditorFrameProtocol.h
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHImageEditorFrameProtocol <NSObject>

@required
@property(nonatomic,assign) CGRect cropRect;

@optional
- (void)SHEditorImageViewControllerWillBeginEditing;
- (void)SHEditorImageViewControllerDidFinishEditing;

@end
