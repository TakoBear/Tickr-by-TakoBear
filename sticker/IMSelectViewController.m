//
//  IMSelectViewController.m
//  sticker
//
//  Created by shouian on 2014/4/3.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "IMSelectViewController.h"
#import "PhotoViewCell.h"
#import "UICollectionViewDataSource_Draggable.h"
#import "ChatManager/ChatManager.h"

#define CHATAPP @[@"line.png", @"whatsapp", @"wechat.png"]

static NSArray *chatApp;

@interface IMSelectViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *collectionView;
    NSData *_imgData;
}

@end

@implementation IMSelectViewController

- (id)initWithImageData:(NSData *)imgData
{
    self = [super init];
    if (self) {
        _imgData = [imgData copy];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    chatApp = [CHATAPP retain];
    
    self.view.backgroundColor = [UIColor clearColor];

    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    [flowLayout setItemSize:CGSizeMake(90, 90)];
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 20, self.view.frame.size.width-10, self.view.frame.size.height) collectionViewLayout:flowLayout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [collectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    
    [self.view addSubview:collectionView];
}

- (void)dealloc
{
    [collectionView release], collectionView = nil;
    [_imgData release], _imgData = nil;
    [super dealloc];
}

#pragma mark - CollectionView dataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return chatApp.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoViewCell *cell = (PhotoViewCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    [cell.imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    UIImage *image = [UIImage imageNamed:chatApp[indexPath.item]];
    
    [cell.imgView setImage:image];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IMViewController:didSelectAtIndex:)]) {
        [self.delegate IMViewController:self didSelectAtIndex:indexPath];
    }
    
    NSLog(@"index path %d", indexPath.item);
    
    ChatManager *chatManager = [ChatManager new];
    ChatApp *chat = [chatManager chatAppWithType:indexPath.item];
    if ([chat isUserInstalledApp]) {
        [chat shareWithImage:_imgData];
    }
}

@end
