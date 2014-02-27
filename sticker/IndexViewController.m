//
//  ViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/2/18.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "IndexViewController.h"
#import "SourceViewController.h"

@interface IndexViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    UICollectionView *imageCollectionView;
    NSMutableArray *imageDataArray;
}

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.7 blue:0.6 alpha:1];
    
    //Data source
    imageDataArray = [NSMutableArray new];
    UIImage *imageAdd = [UIImage imageNamed:@"addData.png"];
    [imageDataArray addObject:imageAdd];
    
    for (int number = 1 ; number <= 17; number++) {
        @autoreleasepool {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.PNG",number]];
            [imageDataArray addObject:[image copy]];
        }
    }
    
    //Create CollectionView
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(85, 110)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 80, self.view.frame.size.width - 20, self.view.frame.size.height - 80) collectionViewLayout:flowLayout];
    [imageCollectionView setDelegate:self];
    [imageCollectionView setDataSource:self];
    [imageCollectionView setBackgroundColor:[UIColor clearColor]];
    [imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    
    [self.view addSubview:imageCollectionView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc
{
    [flowLayout release];
    [imageCollectionView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView dataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[imageDataArray objectAtIndex:(int)indexPath.item]];
    [imageView setFrame:CGRectMake(0, 0, 85, 85)];
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        SourceViewController *sourceVC = [[SourceViewController alloc] init];
        [self.navigationController pushViewController:sourceVC animated:YES];
    }


}

@end
