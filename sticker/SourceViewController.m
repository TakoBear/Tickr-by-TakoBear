//
//  SourceViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/2/23.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "SourceViewController.h"
#import "EditViewController.h"
#import "ASIHTTPRequest.h"
#import "GoogleSearchViewController.h"

@interface SourceViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
}
@end

@implementation SourceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(50, 80, 150, 100)];
    camera.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
    [camera setTitle:@"camera" forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:camera];
    [camera release];
    
    UIButton *localPhoto = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 150, 100)];
    localPhoto.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
    [localPhoto setTitle:@"localPhoto" forState:UIControlStateNormal];
    [localPhoto addTarget:self action:@selector(getLocalPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localPhoto];
    [localPhoto release];
    
    UIButton *googleSearch = [[UIButton alloc] initWithFrame:CGRectMake(50, 320, 150, 100)];
    googleSearch.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
    [googleSearch setTitle:@"googleSearch" forState:UIControlStateNormal];
    [googleSearch addTarget:self action:@selector(googleSearchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:googleSearch];
    [googleSearch release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cameraAction
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Method to get Image

- (void)getLocalPhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)googleSearchAction
{
    GoogleSearchViewController *searchVC = [[GoogleSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
    [searchVC release];
}

#pragma mark - UIimagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [imagePicker release];
    [self sendImageToEditViewControllWith:pickImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImageToEditViewControllWith:(UIImage *)image
{
    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.originImage = image;
    [self.navigationController pushViewController:editViewController animated:NO];
    [editViewController release];
}

@end
