//
//  SettingViewController.m
//  sticker
//
//  Created by 李健銘 on 2014/3/26.
//  Copyright (c) 2014年 TakoBear. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingVariable.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UISwitch *cameraRollSwitch;
    UISwitch *stickerAlbumSwitch;
}

@end

@implementation SettingViewController

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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1];
    
    //Create switch
    cameraRollSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    cameraRollSwitch.on = YES;
    [cameraRollSwitch addTarget:self action:@selector(cameraRollSwitchPressed:) forControlEvents:UIControlEventTouchUpInside];
    stickerAlbumSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    stickerAlbumSwitch.on = YES;
    [stickerAlbumSwitch addTarget:self action:@selector(stickerAlbumSwitchPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Create tableview
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:settingTableView];

}

- (void)dealloc
{
    [cameraRollSwitch release];
    [stickerAlbumSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Switch Action

- (void)cameraRollSwitchPressed:(id)sender
{
    UISwitch *rollSwitch = (UISwitch*)sender;
    if (rollSwitch.on) {
        
    } else {
        
    }
}

- (void)stickerAlbumSwitchPressed:(id)sender
{
    UISwitch *stickerSwitch = (UISwitch*)sender;
    if (stickerSwitch.on) {
        
    } else {
        
    }
}


#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Stick Destination", @"");
    } else if (section == 1) {
        return NSLocalizedString(@"Store position", @"");
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    switch (indexPath.section) {
        case 0:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Line", @"");
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"WhatsAPP", @"");
            }
        }
            break;
            
        case 1:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Camera Roll", @"");
                cell.accessoryView = cameraRollSwitch;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Sticker Album", @"");
                cell.accessoryView = stickerAlbumSwitch;
            }
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case ChatAppType_Line:
            {
                [[SettingVariable sharedInstance].variableDictionary setValue:[NSNumber numberWithInt:ChatAppType_Line] forKey:kChooseChatAppTypeKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ChatAppType_Line] forKey:kChooseChatAppTypeKey];
            }
                break;
            case ChatAppType_WhatsApp:
            {
                [[SettingVariable sharedInstance].variableDictionary setValue:[NSNumber numberWithInt:ChatAppType_WhatsApp] forKey:kChooseChatAppTypeKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ChatAppType_WhatsApp] forKey:kChooseChatAppTypeKey];
            }
                break;
                
            default:
                break;
        }
    }
}
    

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
