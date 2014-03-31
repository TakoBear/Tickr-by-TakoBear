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
#import "FileControl.h"
#import "SettingViewController.h"
#import "ChatManager.h"
#import "SettingVariable.h"
#import "JMDropMenuView.h"

typedef NS_ENUM(NSInteger, kAdd_Photo_From) {
    kAdd_Photo_From_Camera,
    kAdd_Photo_From_Album,
    kAdd_Photo_From_Search
};

@interface IndexViewController ()<UICollectionViewDataSource_Draggable, UICollectionViewDataSource,UICollectionViewDelegate,JMDropMenuViewDelegate>
{
    DraggableCollectionViewFlowLayout *flowLayout;
    UICollectionView *imageCollectionView;
    NSMutableArray *imageDataArray;
    NSString *documentPath;
//    NSOperationQueue *cellQueue;
    BOOL isAddMode;
    JMDropMenuView *dropMenu;
}

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    imageDataArray = [NSMutableArray new];

//    cellQueue = [[NSOperationQueue alloc] init];
//    cellQueue.maxConcurrentOperationCount = 1;
    isAddMode = NO;
    //Create navigation bar & items
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:self
                                                             action:@selector(displayAddMenu)];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropmenu_pressed.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pushToSettingView)];
    settingButton.tintColor = [UIColor orangeColor];

    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = settingButton;
    
    
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
    SettingVariable *settingVariable = [SettingVariable sharedInstance];
    [settingVariable.variableDictionary setObject:imageDataArray forKey:kImageDataArrayKey];

    
    
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
    
    //Create drop menu
    UIImageView *cameraDrop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddMenuIconSize, kAddMenuIconSize)];
    cameraDrop.backgroundColor = [UIColor clearColor];
    [cameraDrop setImage:[UIImage imageNamed:@"camera.png"]];
    [self.view addSubview:cameraDrop];
    
    UIImageView *albumDrop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddMenuIconSize, kAddMenuIconSize)];
    albumDrop.backgroundColor = [UIColor clearColor];
    [albumDrop setImage:[UIImage imageNamed:@"album.png"]];
    [self.view addSubview:albumDrop];
    
    UIImageView *searchDrop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddMenuIconSize, kAddMenuIconSize)];
    searchDrop.backgroundColor = [UIColor clearColor];
    [searchDrop setImage:[UIImage imageNamed:@"search.png"]];
    [self.view addSubview:searchDrop];
    
    dropMenu= [[JMDropMenuView alloc] initWithViews:@[cameraDrop, albumDrop, searchDrop]];
    dropMenu.frame = CGRectMake(self.view.bounds.size.width - kAddMenuIconSize, 70, kAddMenuIconSize, kAddMenuIconSize *3);
    dropMenu.delegate = self;
    [self.view addSubview:dropMenu];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    if (imageCollectionView) {
        imageDataArray = [[SettingVariable sharedInstance].variableDictionary objectForKey:kImageDataArrayKey];
        [imageCollectionView reloadData];
    }
}

- (void)dealloc
{
    [flowLayout release];
    [imageCollectionView release];
    [imageDataArray release];
    [documentPath release];
//    [cellQueue release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pushToSettingView
{
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
    [settingVC release];
}

#pragma mark - Drop menu Delegate for add photo

- (void)displayAddMenu
{
    if (isAddMode) {
        [dropMenu dismiss];
    } else {
        [dropMenu popOut];
    }
    isAddMode = !isAddMode;
}

- (void)dropMenu:(JMDropMenuView *)menu didSelectAtIndex:(NSInteger)index;
{
    switch (index) {
        case kAdd_Photo_From_Album:{
            
        }
            break;
        case kAdd_Photo_From_Camera:{
            
        }
            break;
        case kAdd_Photo_From_Search:{
            
        }
            break;
            
        default:
            break;
    }
    
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
    
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image;
        if (indexPath.item == 0) {
            image = [imageDataArray objectAtIndex:0];
            cell.deleteImgView.hidden = YES;
        } else {
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *imagePath = [stickerPath stringByAppendingPathComponent:[imageDataArray objectAtIndex:indexPath.item]];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            image = [UIImage imageWithData:imageData];
            
        }
            [cell.imgView setImage:image];
//        });
//        
//    }];
//    
//    operation.queuePriority = (indexPath.item == 0) ? NSOperationQueuePriorityVeryHigh :NSOperationQueuePriorityLow;
//    [cellQueue addOperation:operation];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        SourceViewController *sourceVC = [[SourceViewController alloc] init];
        
        [self.navigationController pushViewController:sourceVC animated:YES];
    }
    else {
        
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *imagePath = [stickerPath stringByAppendingPathComponent:[imageDataArray objectAtIndex:indexPath.item]];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            ChatManager *chatManager = [ChatManager new];
            ChatApp *chat = [chatManager currentChatAppWithType];
            if ([chat isUserInstalledApp]) {
                [chat shareWithImage:imageData];
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
