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
#define kCOLOR_VIEW_TAG         1003
#define kBRUSH_VIEW_TAG         1004

#define kDRAW_BUTTON_TAG        201

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
    
    int brushIndex;
    int colorIndex;
    
    NSArray *colorArray;
    NSArray *brushArray;

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
    
    UIImageView *tmpDrawImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, kIMG_VIEW_STATUS_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)] autorelease];
    tmpDrawImgView.tag = kTMP_DRAWIMGVIEW_TAG;
    tmpDrawImgView.backgroundColor = [UIColor clearColor];
    mainImgView.userInteractionEnabled = YES;
    [self.view addSubview:tmpDrawImgView];
    
    UIBarButtonItem *saveBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(savePhotos:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    UIBarButtonItem *writeBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Write", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setWritingMode:)] autorelease];
    UIBarButtonItem *eraseBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Erase", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setEraseMode:)] autorelease];
    self.toolbarItems = @[writeBtn, eraseBtn];
    
    //Create color & brush menu
    colorArray = [NSArray arrayWithObjects:@"Red",@"Orange",@"Yellow",@"Gray",@"Blue",@"Cyne",@"Green", nil];
    brushArray = [NSArray arrayWithObjects:@"Brush1",@"Brush2",@"Brush3",@"Brush4",@"Brush5", nil];
    NSMutableArray *colorIconArray = [[NSMutableArray alloc] init];
    NSMutableArray *brushIconArray = [[NSMutableArray alloc] init];
    for (NSString *colorName in colorArray) {
        UIImageView *colorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-200,kColorButtonSize, kColorButtonSize)];
        colorImgView.backgroundColor = [UIColor clearColor];
        [colorImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",colorName]]];
        [colorIconArray addObject:colorImgView];
        [colorImgView release]; colorImgView = nil;
    }
    
    for (NSString *brushName in brushArray) {
        UIImageView *brushImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kColorButtonSize - 20, self.view.frame.size.height-100, kColorButtonSize, kColorButtonSize)];
        brushImgView.backgroundColor = [UIColor clearColor];
        [brushImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",brushName]]];
        [brushIconArray addObject:brushImgView];
        [brushImgView release]; brushImgView = nil;
    }
    
    isAnimate = NO;
    
    UIButton *drawButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    drawButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 45);
    [drawButton setImage:[UIImage imageNamed:@"Brush1_Blue.png"] forState:UIControlStateNormal];
    [drawButton addTarget:self action:@selector(springMenuAnimate) forControlEvents:UIControlEventTouchUpInside];
    drawButton.tag = kDRAW_BUTTON_TAG;
    [self.view addSubview:drawButton];
    
    UIButton *eraseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    eraseButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 120);
    [eraseButton setImage:[UIImage imageNamed:@"Eraser.png"] forState:UIControlStateNormal];
    [eraseButton addTarget:self action:@selector(setEraseMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eraseButton];
    
    
    JMSpringMenuView *colorMenu= [[JMSpringMenuView alloc] initWithViews:colorIconArray];
    colorMenu.frame = CGRectMake(20,self.view.frame.size.height - 40, kColorButtonSize, kColorButtonSize * 8);
    colorMenu.animateInterval = 0.5;
    colorMenu.animateDirect = Animate_Drop_To_Top;
    colorMenu.viewsInterval = 10;
    colorMenu.tag = kCOLOR_VIEW_TAG;
    colorMenu.delegate = self;
    [self.view addSubview:colorMenu];
    
    JMSpringMenuView *brushMenu= [[JMSpringMenuView alloc] initWithViews:brushIconArray];
    brushMenu.frame = CGRectMake(self.view.frame.size.width - kColorButtonSize - 20,self.view.frame.size.height - 40, kColorButtonSize, kColorButtonSize * 6);
    brushMenu.animateInterval = 0.5;
    brushMenu.animateDirect = Animate_Drop_To_Top;
    brushMenu.viewsInterval = 10;
    brushMenu.tag = kBRUSH_VIEW_TAG;
    brushMenu.delegate = self;
    [self.view addSubview:brushMenu];
    

    [colorIconArray release];
    [brushIconArray release];
    [drawButton release];
    [eraseButton release];
    [colorMenu release];
    [brushMenu release];

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

- (void)dealloc
{
    [_srcImage release];
    _srcImage = nil;
    [_drawColor release];
    _drawColor = nil;
    [super dealloc];
}

#pragma mark - Spring menu Delegate 

- (void)springMenuAnimate
{
    [self setWritingMode:nil];
    JMSpringMenuView *colorMenu = (JMSpringMenuView *)[self.view viewWithTag:kCOLOR_VIEW_TAG];
    JMSpringMenuView *brushMenu = (JMSpringMenuView *)[self.view viewWithTag:kBRUSH_VIEW_TAG];
    if (!isAnimate) {
        [colorMenu popOut];
        [brushMenu popOut];
    } else {
        [colorMenu dismiss];
        [brushMenu dismiss];
    }
    isAnimate = !isAnimate;
}

- (void)springMenu:(JMSpringMenuView *)menu didSelectAtIndex:(NSInteger)index
{
    NSLog(@"Select index : %d", index);
    
    if (menu.tag == kCOLOR_VIEW_TAG) {
        [self setUpColorWithIndex:index];
        [self springMenuAnimate];
        colorIndex = index;
    } else if (menu.tag == kBRUSH_VIEW_TAG) {
        [self setUpBrushWithIndex:index];
        [self springMenuAnimate];
        brushIndex = index;
    }
    
}

- (void)setUpBrushWithIndex:(NSInteger)index
{
    switch (index) {
        case PaintingBrush1:
        {
            brushWidth = 5.0f;
        }
            break;
        case PaintingBrush2:
        {
            brushWidth = 10.0f;
        }
            break;
        case PaintingBrush3:
        {
            brushWidth = 15.0f;
        }
            break;
        case PaintingBrush4:
        {
            brushWidth = 20.0f;
        }
            break;
        case PaintingBrush5:
        {
            brushWidth = 25.0f;
        }
            break;
            
        default:
            break;
    }
}

- (void)setUpColorWithIndex:(NSInteger)index
{
    [_drawColor release], _drawColor = nil;
    
    switch (index) {
        case PaintingColorBlue:
        {
            red = 51.0f;
            green = 85.0f;
            blue = 134.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorGray:
        {
            red = 68.0f;
            green = 68.0f;
            blue = 68.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorOrange:
        {
            red = 224.0f;
            green = 152.0f;
            blue = 2.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorCyne:
        {
            red = 88.0f;
            green = 189.0f;
            blue = 234.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorGreen:
        {
            red = 113.0f;
            green = 193.0f;
            blue = 7.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorYellow:
        {
            red = 225.0f;
            green = 214.0f;
            blue = 4.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
        case PaintingColorRed:
        {
            red = 191.0f;
            green = 27.0f;
            blue = 11.0f;
            opacity = 1.0f;
            _drawColor = [RGBA(red, green, blue, opacity) retain];
        }
            break;
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
    BOOL isSaveToAlbum = [[NSUserDefaults standardUserDefaults] boolForKey:kSaveAlbumKey];
    if (isSaveToAlbum) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImage:imgView.image toAlbum:kPhotoAlbumName withCompletionBlock:^(NSError *error) {
            if (error!= nil) {
                NSLog(@"Big error : %@",[error description]);
            }
            [library release];
        }];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *imageName = [NSString stringWithFormat:@"Sticker%@.png",[dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    
    NSString *stickerPath = [[[FileControl mainPath] documentPath] stringByAppendingPathComponent:kFileStoreDirectory];
    NSData *imageData = UIImagePNGRepresentation(imgView.image);
    [imageData writeToFile:[stickerPath stringByAppendingPathComponent:imageName] atomically:YES];

    [[SettingVariable sharedInstance] addImagetoImageDataArray:imageName];
    
    if (isGoogleSearchNavController) {
        [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
//    [imgView release];
    imgView = nil;
    tempDrawImage = nil;
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
