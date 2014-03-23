//
//  PaintingImageViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PaintingImageViewController.h"
#import "StickerAppConstants.h"

#define kMAIN_IMGVIEW_TAG       1001
#define kTMP_DRAWIMGVIEW_TAG    1002

@interface PaintingImageViewController ()
{
    UIImage *_srcImage;
    UIColor *_drawColor;
    CGPoint lastPoint;
    
    CGFloat brushWidth;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat opacity;
    
    BOOL mouseSwiped;
}

@end

@implementation PaintingImageViewController

- (id)initWithImage:(UIImage *)img
{
    self = [super init];
    if (self) {
        _srcImage = [img copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    red = 0.0f;
    green = 0.0f;
    blue = 0.0f;
    opacity = 1.0f;
    _drawColor = RGBA(red, green, blue, opacity);
    brushWidth = 10.0f;
    
    UIImageView *mainImgView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    mainImgView.image = _srcImage;
    mainImgView.tag = kMAIN_IMGVIEW_TAG;
    [self setView:mainImgView];
    
    UIImageView *tmpDrawImgView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    tmpDrawImgView.tag = kTMP_DRAWIMGVIEW_TAG;
    mainImgView.userInteractionEnabled = YES;
    [self.view addSubview:tmpDrawImgView];
    
    UIBarButtonItem *saveBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(savePhotos:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide search bar
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            [view setHidden:YES];
        }
    }
}

#pragma mark - Touch Action

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    UIImageView *imgView = (UIImageView *)[self view];
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [imgView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}

#pragma mark - Action

- (void)savePhotos:(id)sender
{
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    UIImageView *imgView = (UIImageView *)[self view];
    
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, NO, 0.0);
    [imgView.image drawInRect:CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height)];
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(saveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    /*
    [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Succeed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alerView show];
        [alerView release];
    }];
    */
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved.Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    }
}


@end
