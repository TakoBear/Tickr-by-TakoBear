//
//  PhotoEditedViewController.m
//  sticker
//
//  Created by shouian on 2014/3/15.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "PhotoEditedViewController.h"
#import "PaintingImageViewController.h"
#import "ASIHTTPRequest.h"
#import "Categories/UIImage+ResizeImage.h"

@interface PhotoEditedViewController()
{
    NSURL *_url;
}

@end

@implementation PhotoEditedViewController

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        // Put a Default Image Here
        self.sourceImage = [UIImage imageNamed:@"1.PNG"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up To next UI
    UIBarButtonItem *nextBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = nextBtn;
    
    // Set up ToolBar
    UIBarButtonItem *squareBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Square" style:UIBarButtonItemStyleBordered target:self action:@selector(setSquareAction:)] autorelease];
    UIBarButtonItem *landscapeBtn = [[[UIBarButtonItem alloc] initWithTitle:@"LandScape" style:UIBarButtonItemStyleBordered target:self action:@selector(setLandscapeAction:)] autorelease];
    UIBarButtonItem *lportraitBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Portrait" style:UIBarButtonItemStyleBordered target:self action:@selector(setLPortraitAction:)] autorelease];
    
    NSArray *btnItems = @[squareBtn, landscapeBtn, lportraitBtn];
    self.toolbarItems = btnItems;
    
    if (_url != nil) {
        // Send Request to background 
        __block ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:_url];
        [request setRequestMethod:@"GET"];
        [request setTimeOutSeconds:10.0f];
        [request setDelegate:self];
        [request setDownloadProgressDelegate:self];
        [request setCompletionBlock:^{
            if ((request.responseStatusCode == 200) || (request.responseStatusCode == 201) ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *reqImg = [UIImage imageWithData:request.responseData];
                    reqImg = [UIImage resizeImageWithSize:reqImg resize:reqImg.size];
                    self.sourceImage = reqImg;
                    self.previewImage = self.sourceImage;
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                    [self reset:NO];
                    [self viewWillAppear:NO];
                });
            }
        }];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [request startAsynchronous];
    }
    
    // Original Setting
    self.cropRect = CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width);
    self.maximumScale = 10;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self.navigationController setToolbarHidden:NO];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // If 
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            [view setHidden:NO];
        }
    }
}

#pragma mark - Button Action
- (void)setSquareAction:(id)sender
{
    self.cropRect = CGRectMake((frameView.frame.size.width - 320)/2.0f, (frameView.frame.size.height - 320)/2.0f, 320, 320);
    [self reset:YES];
}

- (void)setLandscapeAction:(id)sender
{
    self.cropRect = CGRectMake((frameView.frame.size.width - 320)/2.0f, (frameView.frame.size.height-240)/2.0f, 320, 240);
    [self reset:YES];
}


- (void)setLPortraitAction:(id)sender
{
    self.cropRect = CGRectMake((frameView.frame.size.width-240)/2.0f, (frameView.frame.size.height - 320)/2.0f, 240, 320);
    [self reset:YES];
}

#pragma mark - Parent UIAction
- (void)finishTransformingImage:(UIImage *)img
{
    PaintingImageViewController *paintViewController = [[PaintingImageViewController alloc] initWithImage:img];
    [self.navigationController pushViewController:paintViewController animated:YES];
    [paintViewController release];
}

@end
