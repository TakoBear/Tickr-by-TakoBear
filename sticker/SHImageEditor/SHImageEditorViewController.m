//
//  SHImageEditorViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "SHImageEditorViewController.h"
#import "SHImageEditorFrameView.h"
#import "SHImageEditorFrameProtocol.h"
#import <QuartzCore/QuartzCore.h>

typedef struct {
    CGPoint tl,tr,bl,br;
} Rectangle;

static const CGFloat kMaxUIImageSize = 1024;
static const CGFloat kPreviewImageSize = 120;
static const CGFloat kDefaultCropWidth = 320;
static const CGFloat kDefaultCropHeight = 320;
//static const CGFloat kBoundingBoxInset = 15;
static const NSTimeInterval kAnimationIntervalReset = 0.25;
static const NSTimeInterval kAnimationIntervalTransform = 0.2;

@interface SHImageEditorViewController ()

@end

@implementation SHImageEditorViewController

@dynamic cropBoundsInSourceImage;
@dynamic cropRect;
@dynamic cropSize;

@synthesize tapToResetEnabled = _tapToResetEnabled;
@synthesize panEnabled = _panEnabled;
@synthesize scaleEnabled = _scaleEnabled;
@synthesize rotateEnabled = _rotateEnabled;

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _tapToResetEnabled = YES;
    _panEnabled = YES;
    _scaleEnabled = YES;
    _rotateEnabled = YES;
}

#pragma mark - Properties : Setter & Getter
- (void)setCropRect:(CGRect)cropRect
{
    frameView.cropRect = cropRect;
}

- (CGRect)cropRect
{
    if(frameView.cropRect.size.width == 0 || frameView.cropRect.size.height == 0) {
        frameView.cropRect = CGRectMake((frameView.bounds.size.width-kDefaultCropWidth)/2,
                                             (frameView.bounds.size.height-kDefaultCropHeight)/2,
                                             kDefaultCropWidth,kDefaultCropHeight);
    }
    return frameView.cropRect;
}

- (void)setCropSize:(CGSize)cropSize
{
    self.cropRect = CGRectMake((frameView.bounds.size.width-cropSize.width)/2,
                               (frameView.bounds.size.height-cropSize.height)/2,
                               cropSize.width,cropSize.height);
}

- (CGSize)cropSize
{
    return frameView.cropRect.size;
}

- (UIImage *)previewImage
{
    if(_previewImage == nil && _sourceImage != nil) {
        if(self.sourceImage.size.height > kMaxUIImageSize || self.sourceImage.size.width > kMaxUIImageSize) {
            CGFloat aspect = self.sourceImage.size.height/self.sourceImage.size.width;
            CGSize size;
            if(aspect >= 1.0) { //square or portrait
                size = CGSizeMake(kPreviewImageSize,kPreviewImageSize*aspect);
            } else { // landscape
                size = CGSizeMake(kPreviewImageSize,kPreviewImageSize*aspect);
            }
            _previewImage = [self scaledImage:self.sourceImage  toSize:size withQuality:kCGInterpolationLow];
        } else {
            _previewImage = _sourceImage;
        }
    }
    return  _previewImage;
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    if(sourceImage != _sourceImage) {
        _sourceImage = sourceImage;
        self.previewImage = nil;
    }
}

- (void)setPanEnabled:(BOOL)panEnabled
{
    _panEnabled = panEnabled;
    panRecognizer.enabled = panEnabled;
}

- (void)setScaleEnabled:(BOOL)scaleEnabled
{
    _scaleEnabled = scaleEnabled;
    pinchRecognizer.enabled = scaleEnabled;
}

- (void)setRotateEnabled:(BOOL)rotateEnabled
{
    _rotateEnabled = rotateEnabled;
    rotationRecognizer.enabled = rotateEnabled;
}

- (void)setTapToResetEnabled:(BOOL)tapToResetEnabled
{
    _tapToResetEnabled = tapToResetEnabled;
    tapRecognizer.enabled = tapToResetEnabled;
}

#pragma mark - Method 
- (void)reset:(BOOL)animated
{
    CGFloat w = 0.0f;
    CGFloat h = 0.0f;
    CGFloat sourceAspect = self.sourceImage.size.height/self.sourceImage.size.width;
    CGFloat cropAspect = self.cropRect.size.height/self.cropRect.size.width;
    
    if(sourceAspect > cropAspect) {
        w = CGRectGetWidth(self.cropRect);
        h = sourceAspect * w;
    } else {
        h = CGRectGetHeight(self.cropRect);
        w = h / sourceAspect;
    }
    scale = 1;
    if(self.checkBounds) {
        self.minimumScale = 1;
    }
    initialImageFrame = CGRectMake(CGRectGetMidX(self.cropRect) - w/2, CGRectGetMidY(self.cropRect) - h/2,w,h);
    validTransform = CGAffineTransformMakeScale(scale, scale);
    
    void (^doReset)(void) = ^{
        imageView.transform = CGAffineTransformIdentity;
        imageView.frame = initialImageFrame;
        imageView.transform = validTransform;
    };
    
    if(animated) {
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:kAnimationIntervalReset animations:doReset completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    } else {
        doReset();
    }
}

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.masksToBounds = YES;
    
    frameView = [[SHImageEditorFrameView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:frameView];
    
    imageView = [[UIImageView alloc] init];
    [self.view insertSubview:imageView belowSubview:frameView];
    
    [self.view setMultipleTouchEnabled:YES];
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.cancelsTouchesInView = NO;
    panRecognizer.delegate = self;
    panRecognizer.enabled = self.panEnabled;
    [frameView addGestureRecognizer:panRecognizer];
    
    rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationRecognizer.cancelsTouchesInView = NO;
    rotationRecognizer.delegate = self;
    rotationRecognizer.enabled = self.rotateEnabled;
    [frameView addGestureRecognizer:rotationRecognizer];
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.cancelsTouchesInView = NO;
    pinchRecognizer.delegate = self;
    pinchRecognizer.enabled = self.scaleEnabled;
    [frameView addGestureRecognizer:pinchRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.enabled = self.tapToResetEnabled;
    [frameView addGestureRecognizer:tapRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reset:NO];
    imageView.image = self.previewImage;
    
    if(self.previewImage != self.sourceImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGImageRef hiresCGImage = NULL;
            CGFloat aspect = self.sourceImage.size.height/self.sourceImage.size.width;
            CGSize size;
            if(aspect >= 1.0) { //square or portrait
                size = CGSizeMake(kMaxUIImageSize*aspect,kMaxUIImageSize);
            } else { // landscape
                size = CGSizeMake(kMaxUIImageSize,kMaxUIImageSize*aspect);
            }
            hiresCGImage = [self newScaledImage:self.sourceImage.CGImage withOrientation:self.sourceImage.imageOrientation toSize:size withQuality:kCGInterpolationDefault];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithCGImage:hiresCGImage scale:1.0 orientation:UIImageOrientationUp];
                CGImageRelease(hiresCGImage);
            });
        });
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - UI Action

- (void)doneAction:(id)sender
{
    self.view.userInteractionEnabled = NO;
    if ([_delegate respondsToSelector:@selector(SHEditorImageViewControllerWillBeginEditing)]) {
        [_delegate SHEditorImageViewControllerWillBeginEditing];
    }
    
    // Virtual Function
    [self currentImageBeginToScale];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef resultRef = [self newTransformedImage:imageView.transform
                                             sourceImage:self.sourceImage.CGImage
                                              sourceSize:self.sourceImage.size
                                       sourceOrientation:self.sourceImage.imageOrientation
                                             outputWidth:self.outputWidth ? self.outputWidth : self.sourceImage.size.width
                                                cropRect:self.cropRect
                                           imageViewSize:imageView.bounds.size];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *transform =  [UIImage imageWithCGImage:resultRef scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(resultRef);
            self.view.userInteractionEnabled = YES;
            if(self.doneCallback) {
                self.doneCallback(transform, NO);
            }
            if ([_delegate respondsToSelector:@selector(SHEditorImageViewControllerDidFinishEditing)]) {
                [_delegate SHEditorImageViewControllerDidFinishEditing];
            }
            // Virtual Function
            [self finishTransformingImage:transform];
        });
    });
}

- (void)cancelAction:(id)sender
{
    if(self.doneCallback) {
        self.doneCallback(nil, YES);
    }
}

- (void)resetAction:(id)sender
{
    [self reset:NO];
}

- (void)resetAnimatedAction:(id)sender
{
    [self reset:YES];
}

#pragma mark - Virtual function
- (void)currentImageBeginToScale
{
    // For future to implement
}

- (void)finishTransformingImage:(UIImage *)img
{
    // For future to implement
}

#pragma mark - UIGesture
- (void)handleTouches:(NSSet*)touches
{
    touchCenter = CGPointZero;
    if(touches.count < 2) return;
    
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch*)obj;
        CGPoint touchLocation = [touch locationInView:imageView];
        touchCenter = CGPointMake(touchCenter.x + touchLocation.x, touchCenter.y +touchLocation.y);
    }];
    touchCenter = CGPointMake(touchCenter.x/touches.count, touchCenter.y/touches.count);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

#pragma mark Gestures

- (CGFloat)boundedScale:(CGFloat)_scale;
{
    CGFloat boundedScale = _scale;
    if(self.minimumScale > 0 && _scale < self.minimumScale) {
        boundedScale = self.minimumScale;
    } else if(self.maximumScale > 0 && _scale > self.maximumScale) {
        boundedScale = self.maximumScale;
    }
    return boundedScale;
}

- (BOOL)handleGestureState:(UIGestureRecognizerState)state
{
    BOOL handle = YES;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            gestureCount++;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            gestureCount--;
            handle = NO;
            if(gestureCount == 0) {
                CGFloat _scale = [self boundedScale:scale];
                if(_scale != scale) {
                    CGFloat deltaX = scaleCenter.x-imageView.bounds.size.width/2.0;
                    CGFloat deltaY = scaleCenter.y-imageView.bounds.size.height/2.0;
                    
                    CGAffineTransform transform =  CGAffineTransformTranslate(imageView.transform, deltaX, deltaY);
                    transform = CGAffineTransformScale(transform, _scale/scale , _scale/scale);
                    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
                    [self checkBoundsWithTransform:transform];
                    self.view.userInteractionEnabled = NO;
                    [UIView animateWithDuration:kAnimationIntervalTransform delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        imageView.transform = validTransform;
                    } completion:^(BOOL finished) {
                        self.view.userInteractionEnabled = YES;
                        scale = _scale;
                    }];
                    
                } else {
                    self.view.userInteractionEnabled = NO;
                    [UIView animateWithDuration:kAnimationIntervalTransform delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        imageView.transform = validTransform;
                    } completion:^(BOOL finished) {
                        self.view.userInteractionEnabled = YES;
                    }];
                    
                    imageView.transform = validTransform;
                }
            }
        } break;
        default:
            break;
    }
    return handle;
}


- (void)checkBoundsWithTransform:(CGAffineTransform)transform
{
    if(!self.checkBounds) {
        validTransform = transform;
        return;
    }
    CGRect r1 = [self boundingBoxForRect:self.cropRect rotatedByRadians:[self imageRotation]];
    Rectangle r2 = [self applyTransform:transform toRect:initialImageFrame];
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(self.cropRect), CGRectGetMidY(self.cropRect));
    t = CGAffineTransformRotate(t, -[self imageRotation]);
    t = CGAffineTransformTranslate(t, -CGRectGetMidX(self.cropRect), -CGRectGetMidY(self.cropRect));
    
    Rectangle r3 = [self applyTransform:t toRectangle:r2];
    
    if(CGRectContainsRect([self CGRectFromRectangle:r3],r1)) {
        validTransform = transform;
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        CGPoint translation = [recognizer translationInView:imageView];
        CGAffineTransform transform = CGAffineTransformTranslate( imageView.transform, translation.x, translation.y);
        imageView.transform = transform;
        [self checkBoundsWithTransform:transform];
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:frameView];
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer*)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            rotationCenter = touchCenter;
        }
        CGFloat deltaX = rotationCenter.x- imageView.bounds.size.width/2;
        CGFloat deltaY = rotationCenter.y- imageView.bounds.size.height/2;
        
        CGAffineTransform transform =  CGAffineTransformTranslate(imageView.transform,deltaX,deltaY);
        transform = CGAffineTransformRotate(transform, recognizer.rotation);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        imageView.transform = transform;
        [self checkBoundsWithTransform:transform];
        
        recognizer.rotation = 0;
    }
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            scaleCenter = touchCenter;
        }
        CGFloat deltaX = scaleCenter.x-imageView.bounds.size.width/2.0;
        CGFloat deltaY = scaleCenter.y-imageView.bounds.size.height/2.0;
        
        CGAffineTransform transform =  CGAffineTransformTranslate(imageView.transform, deltaX, deltaY);
        transform = CGAffineTransformScale(transform, recognizer.scale, recognizer.scale);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        scale *= recognizer.scale;
        imageView.transform = transform;
        
        recognizer.scale = 1;
        
        [self checkBoundsWithTransform:transform];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recogniser {
    [self reset:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark Image Transformation
- (void)transform:(CGAffineTransform*)transform andSize:(CGSize *)size forOrientation:(UIImageOrientation)orientation
{
    *transform = CGAffineTransformIdentity;
    BOOL transpose = NO;
    
    switch(orientation)
    {
        case UIImageOrientationUp:// EXIF 1
        case UIImageOrientationUpMirrored:{ // EXIF 2
        } break;
        case UIImageOrientationDown: // EXIF 3
        case UIImageOrientationDownMirrored: { // EXIF 4
            *transform = CGAffineTransformMakeRotation(M_PI);
        } break;
        case UIImageOrientationLeftMirrored: // EXIF 5
        case UIImageOrientationLeft: {// EXIF 6
            *transform = CGAffineTransformMakeRotation(M_PI_2);
            transpose = YES;
        } break;
        case UIImageOrientationRightMirrored: // EXIF 7
        case UIImageOrientationRight: { // EXIF 8
            *transform = CGAffineTransformMakeRotation(-M_PI_2);
            transpose = YES;
        } break;
        default:
            break;
    }
    
    if(orientation == UIImageOrientationUpMirrored || orientation == UIImageOrientationDownMirrored ||
       orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored) {
        *transform = CGAffineTransformScale(*transform, -1, 1);
    }
    
    if(transpose) {
        *size = CGSizeMake(size->height, size->width);
    }
}


- (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGImageRef cgImage  = [self newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}


- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGAffineTransform transform;
    [self transform:&transform andSize:&srcSize forOrientation:orientation];
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropRect:(CGRect)cropRect
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = sourceImage;
    
    CGAffineTransform orientationTransform;
    [self transform:&orientationTransform andSize:&imageViewSize forOrientation:sourceOrientation];
    
    CGFloat aspect = cropRect.size.height/cropRect.size.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context,  [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width/cropRect.size.width,
                                                            outputSize.height/cropRect.size.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropRect.size.width/2.0, cropRect.size.height/2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, orientationTransform);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       ,source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return resultRef;
}

- (CGRect)cropBoundsInSourceImage
{
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(self.sourceImage.size.width/imageView.bounds.size.width,
                                                            self.sourceImage.size.height/imageView.bounds.size.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, imageView.bounds.size.width/2.0, imageView.bounds.size.height/2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    
    CGRect crop =  CGRectMake(-self.cropRect.size.width/2.0, -self.cropRect.size.height/2.0, self.cropRect.size.width, self.cropRect.size.height);
    return CGRectApplyAffineTransform(crop, CGAffineTransformConcat(CGAffineTransformInvert(imageView.transform),uiCoords));
}

#pragma mark - Util
- (CGFloat) imageRotation
{
    CGAffineTransform t = imageView.transform;
    return atan2f(t.b, t.a);
}

- (CGRect)boundingBoxForRect:(CGRect)rect rotatedByRadians:(CGFloat)angle
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    t = CGAffineTransformRotate(t,angle);
    t = CGAffineTransformTranslate(t,-CGRectGetMidX(rect), -CGRectGetMidY(rect));
    return CGRectApplyAffineTransform(rect, t);
}

- (Rectangle)RectangleFromCGRect:(CGRect)rect
{
    return (Rectangle) {
        .tl = (CGPoint){rect.origin.x, rect.origin.y},
        .tr = (CGPoint){CGRectGetMaxX(rect), rect.origin.y},
        .br = (CGPoint){CGRectGetMaxX(rect), CGRectGetMaxY(rect)},
        .bl = (CGPoint){rect.origin.x, CGRectGetMaxY(rect)}
    };
}

-(CGRect)CGRectFromRectangle:(Rectangle)rect
{
    return (CGRect) {
        .origin = rect.tl,
        .size = (CGSize){.width = rect.tr.x - rect.tl.x, .height = rect.bl.y - rect.tl.y}
    };
}

- (Rectangle)applyTransform:(CGAffineTransform)transform toRect:(CGRect)rect
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    t = CGAffineTransformConcat(imageView.transform, t);
    t = CGAffineTransformTranslate(t,-CGRectGetMidX(rect), -CGRectGetMidY(rect));
    
    Rectangle r = [self RectangleFromCGRect:rect];
    return (Rectangle) {
        .tl = CGPointApplyAffineTransform(r.tl, t),
        .tr = CGPointApplyAffineTransform(r.tr, t),
        .br = CGPointApplyAffineTransform(r.br, t),
        .bl = CGPointApplyAffineTransform(r.bl, t)
    };
}

- (Rectangle)applyTransform:(CGAffineTransform)t toRectangle:(Rectangle)r
{
    return (Rectangle) {
        .tl = CGPointApplyAffineTransform(r.tl, t),
        .tr = CGPointApplyAffineTransform(r.tr, t),
        .br = CGPointApplyAffineTransform(r.br, t),
        .bl = CGPointApplyAffineTransform(r.bl, t)
    };
}


@end
