//
//  PaintingImageViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PaintingImageViewController.h"
#import "SettingVariable.h"
#import "FileControl.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "JMSpringMenuView.h"

#define kMAIN_IMGVIEW_TAG       1001
#define kTMP_DRAWIMGVIEW_TAG    1002

#define kIMG_VIEW_STATUS_HEIGHT 120
#define kColorInterval 70

@interface PaintingImageViewController () <JMSpringMenuViewDelegate>
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
    BOOL isAnimate;
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
    
    UIImageView *mainImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, kIMG_VIEW_STATUS_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)] autorelease];
    mainImgView.image = _srcImage;
    mainImgView.backgroundColor = [UIColor clearColor];
    mainImgView.tag = kMAIN_IMGVIEW_TAG;
    [self.view addSubview:mainImgView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *tmpDrawImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kIMG_VIEW_STATUS_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)];
    tmpDrawImgView.tag = kTMP_DRAWIMGVIEW_TAG;
    tmpDrawImgView.backgroundColor = [UIColor clearColor];
    mainImgView.userInteractionEnabled = YES;
    [self.view addSubview:tmpDrawImgView];
    
    UIBarButtonItem *saveBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(savePhotos:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    UIBarButtonItem *writeBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Write", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setWritingMode:)] autorelease];
    UIBarButtonItem *eraseBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Erase", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setEraseMode:)] autorelease];
    self.toolbarItems = @[writeBtn, eraseBtn];
    
    //Create color menu
    UIImageView *colorDarkBlue = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorDarkBlue.backgroundColor = [UIColor clearColor];
    [colorDarkBlue setImage:[UIImage imageNamed:@"color_dark_blue.png"]];
    
    UIImageView *colorDarkGray = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorDarkGray.backgroundColor = [UIColor clearColor];
    [colorDarkGray setImage:[UIImage imageNamed:@"color_dark_gray.png"]];
    
    UIImageView *colorDarkYellow = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorDarkYellow.backgroundColor = [UIColor clearColor];
    [colorDarkYellow setImage:[UIImage imageNamed:@"color_dark_yellow.png"]];
    
    UIImageView *colorLightBlue = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorLightBlue.backgroundColor = [UIColor clearColor];
    [colorLightBlue setImage:[UIImage imageNamed:@"color_light_blue.png"]];
    
    UIImageView *colorLightGreen = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorLightGreen.backgroundColor = [UIColor clearColor];
    [colorLightGreen setImage:[UIImage imageNamed:@"color_light_green.png"]];
    
    UIImageView *colorLightYellow = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorLightYellow.backgroundColor = [UIColor clearColor];
    [colorLightYellow setImage:[UIImage imageNamed:@"color_light_yellow.png"]];
    
    UIImageView *colorRed = [[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
    colorRed.backgroundColor = [UIColor clearColor];
    [colorRed setImage:[UIImage imageNamed:@"color_red.png"]];
    isAnimate = NO;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 450, 100, 100)];
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(colorMenuAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    JMSpringMenuView *colorMenu= [[JMSpringMenuView alloc] initWithViews:@[colorDarkBlue,colorDarkGray,colorDarkYellow,colorLightBlue,colorLightGreen,colorLightYellow,colorRed]];
    colorMenu.frame = CGRectMake(20,self.view.frame.size.height - 60, kColorButtonSize, kColorButtonSize*8);
    colorMenu.animateInterval = 0.5;
    colorMenu.animateDirect = Animate_Drop_To_Top;
    colorMenu.viewsInterval = 15;
    colorMenu.tag = 201;
    colorMenu.delegate = self;
    [self.view addSubview:colorMenu];

    [colorMenu release];
    [colorDarkBlue release];
    [colorDarkGray release];
    [colorDarkYellow release];
    [colorLightBlue release];
    [colorLightGreen release];
    [colorLightYellow release];
    [button release];

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

#pragma mark - Spring menu Delegate 

- (void)colorMenuAnimate
{
    JMSpringMenuView *colorMenu = (JMSpringMenuView *)[self.view viewWithTag:201];
    if (!isAnimate) {
        [colorMenu popOut];
    } else {
        [colorMenu dismiss];
    }
    isAnimate = !isAnimate;
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
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y - kIMG_VIEW_STATUS_HEIGHT);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y - kIMG_VIEW_STATUS_HEIGHT);
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
    
    UIGraphicsBeginImageContext(tempDrawImage.frame.size);
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _drawColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y - kIMG_VIEW_STATUS_HEIGHT);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y - kIMG_VIEW_STATUS_HEIGHT);
    
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
    
    UIGraphicsBeginImageContext(tempDrawImage.frame.size);
    [tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y - kIMG_VIEW_STATUS_HEIGHT);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y - kIMG_VIEW_STATUS_HEIGHT);
    
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
    
//    UIImageWriteToSavedPhotosAlbum(imgView.image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:imgView.image toAlbum:kPhotoAlbumName withCompletionBlock:^(NSError *error) {
        if (error!= nil) {
            NSLog(@"Big error : %@",[error description]);
        }
    }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *imageName = [NSString stringWithFormat:@"Sticker%@.png",[dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    NSString *stickerPath = [[[FileControl mainPath] documentPath] stringByAppendingPathComponent:kFileStoreDirectory];
    NSData *imageData = UIImagePNGRepresentation(imgView.image);
    [imageData writeToFile:[stickerPath stringByAppendingPathComponent:imageName] atomically:YES];

    [[SettingVariable sharedInstance] addImagetoImageDataArray:imageName];
    
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
