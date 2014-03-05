//
//  ViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/2/18.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "IndexViewController.h"
#import "SourceViewController.h"
#import "PhotoViewCell.h"
#import "DraggableCollectionViewFlowLayout.h"
#import "UICollectionView+Draggable.h"
#import "UICollectionViewDataSource_Draggable.h"
#import "SHLineKit.h"


@interface IndexViewController ()<UICollectionViewDataSource_Draggable, UICollectionViewDataSource,UICollectionViewDelegate>
{
    DraggableCollectionViewFlowLayout *flowLayout;
    UICollectionView *imageCollectionView;
    NSMutableArray *imageDataArray;
}

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:0.3];
    
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
    flowLayout = [[DraggableCollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(85, 110)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 80, self.view.frame.size.width - 20, self.view.frame.size.height - 80) collectionViewLayout:flowLayout];
    [imageCollectionView setDelegate:self];
    [imageCollectionView setDataSource:self];
    [imageCollectionView setDraggable:YES];
    [imageCollectionView setBackgroundColor:[UIColor clearColor]];
    [imageCollectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    
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
    PhotoViewCell *cell = (PhotoViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    [cell.imgView setImage:[imageDataArray objectAtIndex:indexPath.item]];
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        SourceViewController *sourceVC = [[SourceViewController alloc] init];
        [self.navigationController pushViewController:sourceVC animated:YES];
    }
    else {
        [SHLineKit shareLineWithImage:[imageDataArray objectAtIndex:indexPath.item]];
    }
}

#pragma mark - Draggable delegate

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *index = [imageDataArray objectAtIndex:fromIndexPath.item];
    [imageDataArray removeObjectAtIndex:fromIndexPath.item];
    [imageDataArray insertObject:index atIndex:toIndexPath.item];
}


@end
