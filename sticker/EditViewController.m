//
//  EditViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/2/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "EditViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/UIImage+WebP.h"

@interface EditViewController ()
{
    NSURL *contentsURL;
}

@end

@implementation EditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        contentsURL = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //To avoid clear background
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *whiteView = [[UIView alloc] initWithFrame:self.view.bounds];
    whiteView.backgroundColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:0.3];
    [self.view addSubview:whiteView];
    [whiteView release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 200, 400)];
    
    if (contentsURL != nil) {
        [imageView setImageWithURL:contentsURL];
    } else {
        imageView.image = _originImage;
    }
    
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    imageView.layer.borderWidth = 2.0f;
    imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView release];
    
    //set completion image
    
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(10, 440, 100, 40)];
    save.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
    [save setTitle:@"save" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:save];
    [save release];
    
}

- (void)saveAction
{
    //resize image method
    CGRect rect = CGRectZero;
    float width = _originImage.size.width;
    float height = _originImage.size.height;
    float ratio = width/height;
    if (width > height) {
        rect.size = CGSizeMake(200, 200 / ratio);
    } else {
        rect.size = CGSizeMake(200 * ratio, 200);
    }
    
    UIGraphicsBeginImageContext( rect.size );
    [_originImage drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    
    _completionImage = img;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
