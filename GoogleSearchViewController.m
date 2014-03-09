//
//  GoogleSearchViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/3/8.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "GoogleSearchViewController.h"
#import "ASIHTTPRequest.h"
#import "PhotoViewCell.h"
#import "UIImageView+WebCache.h"
#import "EditViewController.h"


#define kGOOGLE_IMAGE_SEARCH_API @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="
#define kTEXT_FIELD_TAG 101

@interface GoogleSearchViewController ()<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *tbImageURLArray;
    NSMutableArray *originImageURLArray;
    UICollectionView *googleCollectionView;
    int searchCount;
    NSString *inputString;
    UITapGestureRecognizer *gestureTextField;
}

@end

@implementation GoogleSearchViewController

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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:0.2];
    
    tbImageURLArray = [NSMutableArray new];
    originImageURLArray = [NSMutableArray new];
    
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 85, 220, 50)];
    searchTextField.delegate = self;
    searchTextField.placeholder = @"google search";
    searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    searchTextField.tag = kTEXT_FIELD_TAG;
    [self.view addSubview:searchTextField];
    [searchTextField release];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(125,125)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    googleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 155, self.view.bounds.size.width-20, self.view.bounds.size.height-155) collectionViewLayout:flowLayout];
    googleCollectionView.delegate = self;
    googleCollectionView.dataSource = self;
    googleCollectionView.backgroundColor = [UIColor clearColor];
    [googleCollectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:@"googleImageCell"];
    
    [self.view addSubview:googleCollectionView];
    [googleCollectionView release];
    
    gestureTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboadOfTextField)];
}

- (void)dealloc
{
    [super dealloc];
    
    [tbImageURLArray removeAllObjects];
    [originImageURLArray removeAllObjects];
    
    [tbImageURLArray release];
    [originImageURLArray release];
    [inputString release];
    [gestureTextField release];
}

#pragma mark - TextField event 

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    [self.view addGestureRecognizer:gestureTextField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    [self.view removeGestureRecognizer:gestureTextField];
}

- (void)dismissKeyboadOfTextField
{
    [(UITextField *)[self.view viewWithTag:kTEXT_FIELD_TAG] resignFirstResponder];
    [self.view removeGestureRecognizer:gestureTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 0) {
        [tbImageURLArray removeAllObjects];
        [originImageURLArray removeAllObjects];
        inputString = [[textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
        //retain to avoid crash!
        NSString *searchString = [NSString stringWithFormat:@"%@%@&rsz=8",kGOOGLE_IMAGE_SEARCH_API,inputString];
        NSURL *searchURL = [NSURL URLWithString:searchString];
        searchCount = 8;
        [self googleSearchWithUrl:searchURL];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ASIHTTPRequest

- (void)googleSearchWithUrl:(NSURL *)searchURL
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:searchURL];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:2.0f];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishRequest:)];
    [request setDidFailSelector:@selector(didFailRequest:)];
    [request startAsynchronous];
    
    [request release];
    
}

- (void)didFinishRequest:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *responseDataDic = [json objectForKey:@"responseData"];
    if (responseDataDic == (NSDictionary *)[NSNull null]){
        return;
    }
    NSArray *resultsArray = [responseDataDic objectForKey:@"results"];
    NSEnumerator *enumerator = [resultsArray objectEnumerator];
    NSDictionary *result;
    int count = 0;
    while (result = [enumerator nextObject]) {
        result = [resultsArray objectAtIndex:count];
        if (result == (NSDictionary *)[NSNull null]){
            [self searchMoreImage];
            return;
        }
        [tbImageURLArray addObject:[result objectForKey:@"tbUrl"]];
        [originImageURLArray addObject:[result objectForKey:@"url"]];
        count ++;
    }
    if (searchCount < 64) {
        [self searchMoreImage];
    } else {
        [googleCollectionView reloadData];
        [googleCollectionView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)didFailRequest:(ASIHTTPRequest *)request
{
    NSError *error = request.error;
    searchCount -= 8;
    NSLog(@"error = %@",error);
}

- (void)searchMoreImage
{
    NSString *searchString = [NSString stringWithFormat:@"%@%@&start=%d&rsz=8",kGOOGLE_IMAGE_SEARCH_API,inputString,searchCount];
    NSURL *searchURL = [NSURL URLWithString:searchString];
    [self googleSearchWithUrl:searchURL];
    searchCount += 8;
}
#pragma mark - CollectionView dataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tbImageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoViewCell *cell = (PhotoViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"googleImageCell" forIndexPath:indexPath];
        NSURL *imageURL = [NSURL URLWithString:[tbImageURLArray objectAtIndex:indexPath.item]];
    
    [cell.imgView setImageWithURL:imageURL placeholderImage:nil];
        cell.userInteractionEnabled = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *imageURL = [NSURL URLWithString:[originImageURLArray objectAtIndex:indexPath.item]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.originImage = image;
    [self.navigationController pushViewController:editViewController animated:YES];
    [editViewController release];
}


@end
