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
#import "PhotoEditedViewController.h"
#import "GoogleSearchViewController.h"
// For popout setting menus
#import "External/REMenu/REMenu.h"
#import "External/RATreeView/RADataObject.h"
#import "External/RATreeView/RATreeView.h"

typedef NS_ENUM(NSInteger, kAdd_Photo_From) {
    kAdd_Photo_From_Camera,
    kAdd_Photo_From_Album,
    kAdd_Photo_From_Search
};

@interface IndexViewController ()<UICollectionViewDataSource_Draggable, UICollectionViewDataSource,UICollectionViewDelegate,JMDropMenuViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, RATreeViewDataSource, RATreeViewDelegate>
{
    DraggableCollectionViewFlowLayout *flowLayout;
    JMDropMenuView *dropMenu;
    REMenu *settingMenu;
    UICollectionView *imageCollectionView;
    NSMutableArray *imageDataArray;
    NSArray *optionData;
    NSString *documentPath;
    UIImagePickerController *imagePicker;
    BOOL isAddMode;
    BOOL isSettingOpen;
    BOOL isAnimate;
    BOOL isDeleteMode;
}

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageDataArray = [NSMutableArray new];
    isAddMode = NO;
    isAnimate = NO;
    isDeleteMode = NO;
    
    // Configure Setting icon
    // Customise TreeView
    RADataObject *appLINE = [RADataObject dataObjectWithName:@"LINE" children:nil];
    RADataObject *appWhatsApp = [RADataObject dataObjectWithName:@"WhatsApp" children:nil];
    RADataObject *appWeChat = [RADataObject dataObjectWithName:@"WeChat" children:nil];
    RADataObject *defaultIM = [RADataObject dataObjectWithName:NSLocalizedString(@"Default IM", nil) children:@[appLINE, appWhatsApp, appWeChat]];
    
    RADataObject *destinationObj = [RADataObject dataObjectWithName:@"Save to Group Album" children:nil];
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:RATreeViewStylePlain];
    [treeView setBackgroundColor:[UIColor clearColor]];
    [treeView setSeparatorColor:[UIColor clearColor]];
    treeView.delegate = self;
    treeView.dataSource = self;
    
    // Compose the MenuItem
    REMenuItem *settingItem = [[REMenuItem alloc] initWithCustomView:treeView];
    optionData = @[defaultIM, destinationObj]; [optionData retain];
    [treeView reloadData];
    
    settingMenu = [[REMenu alloc] initWithItems:@[settingItem]];
    [settingMenu.backgroundView setBackgroundColor:[UIColor clearColor]];
    [settingMenu setBorderColor:[UIColor clearColor]];
    [settingMenu setBackgroundColor:[UIColor clearColor]];
    settingMenu.itemHeight = self.view.frame.size.height;
    
    isSettingOpen = NO;
    
    //Create navigation bar & items
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:self
                                                             action:@selector(displayAddMenu)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(changeDeleteMode)];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropmenu_pressed.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pushToSettingView)];
    settingButton.tintColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = addButton;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton,deleteButton, nil];
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
    SettingVariable *settingVariable = [SettingVariable sharedInstance];
    [settingVariable.variableDictionary setObject:imageDataArray forKey:kImageDataArrayKey];

    
    
    //Create CollectionView
    flowLayout = [[DraggableCollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(90,90)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 10, self.view.frame.size.width-10, self.view.frame.size.height) collectionViewLayout:flowLayout];
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
    dropMenu.animateInterval = 0.3;
    dropMenu.delegate = self;
    dropMenu.userInteractionEnabled = NO;
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
    [dropMenu release];
    [settingMenu release];
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
    if (isSettingOpen) {
        [settingMenu close];
        for (UIBarButtonItem *btn in self.navigationItem.rightBarButtonItems) {
            btn.enabled = YES;
        }
        imageCollectionView.userInteractionEnabled = YES;
    } else {
        if (isAddMode) {
            [dropMenu dismiss];
            isAddMode = NO;
        }
        for (UIBarButtonItem *btn in self.navigationItem.rightBarButtonItems) {
            btn.enabled = NO;
        }
        imageCollectionView.userInteractionEnabled = NO;
        [settingMenu showFromNavigationController:self.navigationController];
    }
    isSettingOpen = !isSettingOpen;
}

- (void)changeDeleteMode
{
    isDeleteMode = !isDeleteMode;
    [imageCollectionView reloadData];
}

#pragma mark - Drop menu Delegate for add photo

- (void)didFinishedPopOutWithDropMenu:(JMDropMenuView *)menu
{
    dropMenu.userInteractionEnabled = YES;
    isAnimate = NO;
}

- (void)didFinishedDismissWithDropMenu:(JMDropMenuView *)menu
{
    dropMenu.userInteractionEnabled = NO;
    imageCollectionView.userInteractionEnabled = YES;
    isAnimate = NO;
}

- (void)displayAddMenu
{
    if (isAnimate) {
        return;
    }
    isAnimate = YES;
    dropMenu.userInteractionEnabled = NO;
    if (isAddMode) {
        [dropMenu dismiss];
    } else {
        imageCollectionView.userInteractionEnabled = NO;
        [dropMenu popOut];
    }
    isAddMode = !isAddMode;
}

- (void)dropMenu:(JMDropMenuView *)menu didSelectAtIndex:(NSInteger)index;
{
//    [dropMenu dismiss];
    [dropMenu resetPosition];
    isAddMode = NO;
    imageCollectionView.userInteractionEnabled = YES;
    switch (index) {
        case kAdd_Photo_From_Album:{
            [self getLocalPhoto];
        }
            break;
        case kAdd_Photo_From_Camera:{
            [self cameraAction];
        }
            break;
        case kAdd_Photo_From_Search:{
            [self googleSearchAction];
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
    
            NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
            NSString *imagePath = [stickerPath stringByAppendingPathComponent:[imageDataArray objectAtIndex:indexPath.item]];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:imageData];
            if (isDeleteMode) {
                cell.deleteImgView.hidden = NO;
            } else {
                cell.deleteImgView.hidden = YES;
            }

            [cell.imgView setImage:image];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleteMode) {
        [self deletePhoto:indexPath.item];
    } else {
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
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *index = [imageDataArray objectAtIndex:fromIndexPath.item];
    [imageDataArray removeObjectAtIndex:fromIndexPath.item];
    [imageDataArray insertObject:index atIndex:toIndexPath.item];
}

- (void)deletePhoto:(NSInteger)item
{
    
    NSString *stickerPath = [documentPath stringByAppendingPathComponent:kFileStoreDirectory];
    NSString *deletePath = [NSString stringWithFormat:@"%@/%@",stickerPath,imageDataArray[item]];
    BOOL isRemove = [[FileControl mainPath] removeFileAtPath:deletePath];
    NSLog(@" Remove : %@",isRemove ? @"Success" : @"Failed");
    [imageDataArray removeObjectAtIndex:item];
    isDeleteMode = NO;
    [imageCollectionView reloadData];

}

#pragma mark - Method to get Image

- (void)cameraAction
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)getLocalPhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)googleSearchAction
{
    GoogleSearchViewController *searchVC = [[GoogleSearchViewController alloc] init];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:searchVC] autorelease];
    
    [self presentViewController:navigationController animated:YES completion:nil];
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
    PhotoEditedViewController *editViewController = [[PhotoEditedViewController alloc] init];
    editViewController.sourceImage = image;
    editViewController.previewImage = image;
    //    editViewController.checkBounds = YES;
    [editViewController reset:NO];
    
    [self.navigationController pushViewController:editViewController animated:NO];
    [editViewController release];
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    cell.textLabel.text = ((RADataObject *)item).name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (treeNodeInfo.treeDepthLevel == 0) {
        
        cell.textLabel.textColor = [UIColor blackColor];
        UISwitch *switchBtn = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
        
        switch (treeNodeInfo.positionInSiblings) {
            case 0:
            {
                [switchBtn addTarget:self action:@selector(switchDefaultIMSetting:) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case 1:
            {
                
            }
                break;
        }
        
        cell.accessoryView = switchBtn;
        
        NSLog(@"item %d", treeNodeInfo.positionInSiblings);
        
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [optionData count];
    }
    
    RADataObject *_data = item;
    return [_data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *_data = item;
    if (item == nil) {
        return [optionData objectAtIndex:index];
    }
    
    return [_data.children objectAtIndex:index];
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 55;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return NO;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    return NO;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.treeDepthLevel == 0) {
        cell.backgroundColor = UIColorFromRGB(0xF7F7F7);
    } else if (treeNodeInfo.treeDepthLevel == 1) {
        cell.backgroundColor = UIColorFromRGB(0xD1EEFC);
    }
}

- (BOOL)treeViewShouldBeSelectable:(RATreeView *)treeView
{
    return NO;
}

#pragma mark - Method to UserSetting

- (void)switchDefaultIMSetting:(id)sender
{
    UISwitch *obj = (UISwitch *)sender;
    RATreeView *treeView = (RATreeView *)[(REMenuItem *)[settingMenu.items objectAtIndex:0] customView];
    if (obj.isOn) {
        [treeView expandRowForItem:optionData[0] withRowAnimation:RATreeViewRowAnimationBottom];
    } else {
        [treeView collapseRowForItem:optionData[0] withRowAnimation:RATreeViewRowAnimationTop];
    }
    // Save setting to userinfo
}

- (void)switchAlbumSetting:(id)sender
{
    UISwitch *obj = (UISwitch *)sender;
    // Save setting to userinfo
}

@end
