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
#import "StickerAppConstants.h"
#import "FileControl.h"

@interface IndexViewController ()<UICollectionViewDataSource_Draggable, UICollectionViewDataSource,UICollectionViewDelegate>
{
    DraggableCollectionViewFlowLayout *flowLayout;
    UICollectionView *imageCollectionView;
    NSMutableArray *imageDataArray;
    NSString *documentPath;
    NSOperationQueue *cellQueue;
    BOOL isDeleteMode;
}

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:0.3];
    
    imageDataArray = [NSMutableArray new];
    cellQueue = [[NSOperationQueue alloc] init];
    cellQueue.maxConcurrentOperationCount = 1;
    isDeleteMode = NO;
    //Create navigation bar & items
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                             target:self
                                                             action:@selector(changeDeleteMode)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    //Create a StickerDocument folder in path : var/.../Document/
    NSArray *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [[docDirectory objectAtIndex:0] retain];
    NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:stickerPath]) {
        [fileManager createDirectoryAtPath:stickerPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    //Get only "image name" from  path : var/.../Document/StickerDocument/* and sort ascending by name
    NSArray *fileArray = [[NSArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:stickerPath error:&error]] retain];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(compare:)];
    fileArray = [fileArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    imageDataArray = [[NSMutableArray arrayWithArray:fileArray] retain];
    UIImage *addDataImage = [UIImage imageNamed:@"addData.png"];
    [imageDataArray insertObject:addDataImage atIndex:0];
    
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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    if (imageCollectionView) {
        [imageCollectionView reloadData];
    }
}

- (void)dealloc
{
    [flowLayout release];
    [imageCollectionView release];
    [imageDataArray release];
    [documentPath release];
    [cellQueue release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeDeleteMode
{
    isDeleteMode = !isDeleteMode;
    [imageCollectionView reloadData];
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
    [cell.imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image;
        if (indexPath.item == 0) {
            image = [imageDataArray objectAtIndex:0];
            cell.deleteImgView.hidden = YES;
        } else {
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *imagePath = [stickerPath stringByAppendingPathComponent:[imageDataArray objectAtIndex:indexPath.item]];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            image = [UIImage imageWithData:imageData];
            if (isDeleteMode) {
                cell.deleteImgView.hidden = NO;
            } else {
                cell.deleteImgView.hidden = YES;
            }
        }
            [cell.imgView setImage:image];
        });
        
    }];
    
    operation.queuePriority = (indexPath.item == 0) ? NSOperationQueuePriorityVeryHigh :NSOperationQueuePriorityLow;
    [cellQueue addOperation:operation];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        SourceViewController *sourceVC = [[SourceViewController alloc] init];
        if (isDeleteMode) {
            [self changeDeleteMode];
        }
        [self.navigationController pushViewController:sourceVC animated:YES];
    }
    else {
        
        if (isDeleteMode) {
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *deletePath = [NSString stringWithFormat:@"%@/%@",stickerPath,imageDataArray[indexPath.item]];
            BOOL isRemove = [[FileControl mainPath] removeFileAtPath:deletePath];
            NSLog(@" Remove : %@",isRemove ? @"Success" : @"Failed");
            [imageDataArray removeObjectAtIndex:indexPath.item];
            [imageCollectionView reloadData];
        } else {
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *imagePath = [stickerPath stringByAppendingPathComponent:[imageDataArray objectAtIndex:indexPath.item]];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            [SHLineKit shareLineWithImage:[UIImage imageWithData:imageData]];
        }
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

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (indexPath.item == 0 || toIndexPath.item == 0) {
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
