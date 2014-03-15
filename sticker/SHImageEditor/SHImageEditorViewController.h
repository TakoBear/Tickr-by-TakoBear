//
//  SHImageEditorViewController.h
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHImageEditorFrameView.h"

@protocol SHImageEditorFrameProtocol;

typedef void(^SHEditingImageDoneCallback)(UIImage *image, BOOL canceled);

@interface SHImageEditorViewController : UIViewController <UIGestureRecognizerDelegate>
{
@public
    UIPanGestureRecognizer *panRecognizer;
    UIRotationGestureRecognizer *rotationRecognizer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    
    UIImageView *imageView;
    SHImageEditorFrameView *frameView;
    
    NSUInteger gestureCount;
    CGPoint touchCenter;
    CGPoint rotationCenter;
    CGPoint scaleCenter;
    CGFloat scale;
    
    CGRect initialImageFrame;
    CGAffineTransform validTransform;
}

@property (nonatomic, assign) id<SHImageEditorFrameProtocol>delegate;

@property(nonatomic,copy) SHEditingImageDoneCallback doneCallback;

@property(nonatomic,copy) UIImage *sourceImage;
@property(nonatomic,copy) UIImage *previewImage;

@property(nonatomic,assign) CGSize cropSize;
@property(nonatomic,assign) CGRect cropRect;
@property(nonatomic,assign) CGFloat outputWidth;
@property(nonatomic,assign) CGFloat minimumScale;
@property(nonatomic,assign) CGFloat maximumScale;

@property(nonatomic,assign) BOOL panEnabled;
@property(nonatomic,assign) BOOL rotateEnabled;
@property(nonatomic,assign) BOOL scaleEnabled;
@property(nonatomic,assign) BOOL tapToResetEnabled;
@property(nonatomic,assign) BOOL checkBounds;

@property(nonatomic,readonly) CGRect cropBoundsInSourceImage;

- (void)reset:(BOOL)animated;
- (void)doneAction:(id)sender;
- (void)cancelAction:(id)sender;
- (void)resetAction:(id)sender;
- (void)resetAnimatedAction:(id)sender;

// Virtual Function - For Hooking
- (void) currentImageBeginToScale;
- (void) finishTransformingImage:(UIImage *)img;

@end
