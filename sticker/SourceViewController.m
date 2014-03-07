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

@interface SourceViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
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
    
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 320, 220, 100)];
    searchTextField.delegate = self;
    searchTextField.placeholder = @"google search";
    searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:searchTextField];
    [searchTextField release];
    
//    UIButton *googleSearch = [[UIButton alloc] initWithFrame:CGRectMake(50, 440, 150, 100)];
//    googleSearch.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:0.7];
//    [googleSearch setTitle:@"googleSearch" forState:UIControlStateNormal];
//    [googleSearch addTarget:self action:@selector(googleSearchAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:googleSearch];
//    [googleSearch release];

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

- (void)googleSearchActionWithText:(NSString *)text
{
    NSString *textUTF8 = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@",textUTF8];

    NSURL *searchURL = [NSURL URLWithString:searchString];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:searchURL];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:1.0f];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishRequest:)];
    [request setDidFailSelector:@selector(didFailRequest:)];
    [request startAsynchronous];
//    NSURLRequest *request = [NSURLRequest requestWithURL:searchURL];
//
//    NSHTTPURLResponse *response = nil;
//    NSError *error = nil;
//    
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    
//    
//    NSString *responseString = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
//    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    }

- (void)didFinishRequest:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSString *responseString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *responseDataDic =  [json objectForKey:@"responseData"];
    NSArray *resultsArray = [responseDataDic objectForKey:@"results"];
    NSLog(@"responseString = %@",responseString);
    NSLog(@"json = %@",json);

}


- (void)didFailRequest:(ASIHTTPRequest *)request
{
    NSError *error = request.error;
    NSLog(@"error = %@",error);
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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 0) {
        [self googleSearchActionWithText:textField.text];
        return YES;
    } else {
        return NO;
    }
}
@end
