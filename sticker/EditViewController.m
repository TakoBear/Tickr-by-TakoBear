//
//  EditViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/2/27.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
    imageView.image = _originImage;
    [self.view addSubview:imageView];
    [imageView release];
    
    //set completion image
    _completionImage = _originImage;
    
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(10, 440, 100, 40)];
    save.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
    [save setTitle:@"save" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:save];
    [save release];
}

- (void)saveAction
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
