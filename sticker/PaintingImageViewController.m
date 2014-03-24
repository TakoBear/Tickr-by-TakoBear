//
//  PaintingImageViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PaintingImageViewController.h"
#import "StickerAppConstants.h"
#import "FileControl.h"

#define kMAIN_IMGVIEW_TAG       1001
#define kTMP_DRAWIMGVIEW_TAG    1002

@interface PaintingImageViewController ()
{
    UIImage *_srcImage;
    UIColor *_drawColor;
    CGPoint currentPoint;
    CGPoint lastPoint;
    
    CGFloat brushWidth;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat opacity;
    
    BOOL mouseSwiped;
    BOOL isErasing;
    BOOL isGoogleSearchNavController;
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
    red = 255.0f;
    green = 0.0f;
    blue = 0.0f;
    opacity = 1.0f;
    _drawColor = [RGBA(red, green, blue, opacity) retain];
    brushWidth = 10.0f;
    isGoogleSearchNavController = NO;
    isErasing = NO;
    
    UIImageView *mainImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width)] autorelease];
    mainImgView.image = _srcImage;
    mainImgView.backgroundColor = [UIColor clearColor];
    mainImgView.tag = kMAIN_IMGVIEW_TAG;
    [self.view addSubview:mainImgView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *tmpDrawImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width)];
    tmpDrawImgView.tag = kTMP_DRAWIMGVIEW_TAG;
    tmpDrawImgView.backgroundColor = [UIColor clearColor];
    mainImgView.userInteractionEnabled = YES;
    [self.view addSubview:tmpDrawImgView];
    
    UIBarButtonItem *saveBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(savePhotos:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    UIBarButtonItem *writeBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Write", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setWritingMode:)] autorelease];
    UIBarButtonItem *eraseBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Erase", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setEraseMode:)] autorelease];
    self.toolbarItems = @[writeBtn, eraseBtn];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide search bar
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            [view setHidden:YES];
            isGoogleSearchNavController = YES;
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
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
    
    [self handleTouches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
    
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    
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

}

- (void)handleTouches
{
    if (!isErasing) {
        [self drawNewLine];
    } else {
        [self eraseLine];
    }
}

- (void)drawNewLine
{
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _drawColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
}

- (void)eraseLine
{
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    [tempDrawImage setBackgroundColor:[UIColor clearColor]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    lastPoint = currentPoint;
    
    [tempDrawImage setNeedsDisplay];
}

#pragma mark - Action

- (void)setWritingMode:(id)sender
{
    isErasing = NO;
}

- (void)setEraseMode:(id)sender
{
    isErasing = YES;
}

- (void)savePhotos:(id)sender
{
    UIImageView *tempDrawImage = (UIImageView *)[self.view viewWithTag:kTMP_DRAWIMGVIEW_TAG];
    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:kMAIN_IMGVIEW_TAG];
    
    UIGraphicsBeginImageContext(imgView.frame.size);
    [imgView.image drawInRect:CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(imgView.image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *imageName = [NSString stringWithFormat:@"Sticker%@",[dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    
//    NSArray *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [[docDirectory objectAtIndex:0] retain];
//    NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
    NSString *stickerPath = [[[FileControl mainPath] documentPath] stringByAppendingPathComponent:kFileStoreDirectory];
    
    NSData *imageData = UIImagePNGRepresentation(imgView.image);
    [imageData writeToFile:[stickerPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]] atomically:YES];
    
    if (isGoogleSearchNavController) {
        [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Succeed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alerView show];
            [alerView release];
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Helper Method

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
