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
#import "GmailLikeLoadingView.h"


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
        self.sourceImage = [UIImage imageNamed:@"white.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up To next UI
    UIBarButtonItem *nextBtn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = nextBtn;
    // Set up ToolBar
//    UIBarButtonItem *squareBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Square" style:UIBarButtonItemStyleBordered target:self action:@selector(setSquareAction:)] autorelease];
//    UIBarButtonItem *landscapeBtn = [[[UIBarButtonItem alloc] initWithTitle:@"LandScape" style:UIBarButtonItemStyleBordered target:self action:@selector(setLandscapeAction:)] autorelease];
//    UIBarButtonItem *lportraitBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Portrait" style:UIBarButtonItemStyleBordered target:self action:@selector(setLPortraitAction:)] autorelease];
    
//    NSArray *btnItems = @[squareBtn, landscapeBtn, lportraitBtn];
//    self.toolbarItems = btnItems;
    
    if (_url != nil) {
        GmailLikeLoadingView *gmailAnimateView = [[GmailLikeLoadingView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        gmailAnimateView.center = self.view.center;
        [self.view addSubview:gmailAnimateView];
        [gmailAnimateView startAnimating];
        
        // Send Request to background 
        __block ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:_url];
        [request setRequestMethod:@"GET"];
        [request setTimeOutSeconds:10.0f];
        [request setDelegate:self];
        [request setDownloadProgressDelegate:self];
        [request setCompletionBlock:^{
            [gmailAnimateView stopAnimating];
            [gmailAnimateView removeFromSuperview];
            [gmailAnimateView release];
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
            } else {
                UILabel *failLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
                failLabel.center = self.view.center;
                failLabel.text = NSLocalizedString(@"Fail to download", @"");
                [self.view addSubview:failLabel];
                [failLabel release];
            }
    
        }];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [request startAsynchronous];
    }
    
    self.navigationItem.title = NSLocalizedString(@"Crop", nil);
    
    // Original Setting
    self.cropRect = CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width);
    self.maximumScale = 10;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    [self.navigationController setToolbarHidden:YES];
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

- (void)dealloc
{
    self.sourceImage = nil;
    self.previewImage = nil;
    [super dealloc];
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
