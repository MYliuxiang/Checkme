//
//  SettingsViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingCell.h"
#import "Colors.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "MobClick.h"
#import "FileUtils.h"
#import "RightMenuViewController.h"
#import "SVProgressHUD.h"
#import "BTDefines.h"
#import "UserList.h"
#import "HKUpdateUtils.h"

#import "SwitchModeViewController.h"
#import "DeviceVersionUtils.h"
#import "NoInfoViewUtils.h"

#import "SettingHeader.h"
#import "HeaderOne.h"


@interface SettingsViewController () <UIAlertViewDelegate,SettingHeaderDelege,HeaderOneDelege>
@property (nonatomic, copy) User *selectedHKUser;

//@property(nonatomic,strong)NSString *HKUserName;
//@property(nonatomic,strong)NSString *hkCheckmeName;

@end

@implementation SettingsViewController
{
    NSTimer *timer;
    NSString *curDirName;
    NSMutableArray *deviceArr;
    BOOL isConfigurateHealthKit;
    BOOL isSpc;
    NSString *DeviceStr;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"SettingPage"];
    
    [self getCurDIRName];
    [self.tableView reloadData];
    
    
    
    isSpc = [UserList instance].isSpotCheck;
    if (isSpc) {
        //获取设备型号
        DeviceStr = @"iPad";
    } else {
        //获取设备型号
        DeviceStr = [DeviceVersionUtils getDeviceVersion];
    }
    
    DLog(@"刷新设置页面!!!");
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"SettingPage"];


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sn = @"SN:";
    [self getCurDIRName];
    [self initTableView];
    isSpc = [UserList instance].isSpotCheck;
    [BTCommunication sharedInstance].delegate = self;//设置代理
    [self getCheckmeInfo];

    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
    
}

//通过蓝牙获取设备信息
-(void)getCheckmeInfo
{
    //如果离线模式，直接返回
    
    DLog(@"输出app的状态，isOffline = %c", [AppDelegate GetAppDelegate].isOffline);
    
    if ([AppDelegate GetAppDelegate].isOffline) {   //离线模式---外设蓝牙关闭状态
        
        return;
    }
    
    if(![[BTCommunication sharedInstance] bLoadingFileNow]){   //当前无文件正在下载
        DLog(@"开始获取设备信息");
        [[BTCommunication sharedInstance] BeginGetInfo];
    }else{  //如果正在下载别的文件，   //YES   有文件正在下载
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:3];//提示性文字的持续时间  duration 设置  (使用第三方的 SVProgressHUD  还有一个第三方的是 MBProgressHUD)
    }
}

//获取设备信息成功的回调
- (void)getInfoSuccessWithData:(NSData *)data
{
    [BTCommunication sharedInstance].delegate = nil;
    _checkmeInfo = [[CheckmeInfo alloc] initWithJSONStr:data];
    self.sn = [NSString stringWithFormat:@"SN:%@",_checkmeInfo.sn];

    NSLog(@"%@",[NSString stringWithFormat:@"SN:%@",_checkmeInfo.sn]);
    [_tableView reloadData];
}

//取设备信息失败
- (void)getInfoFailed
{
    [BTCommunication sharedInstance].delegate = nil;
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Get Checkme information failed", nil) duration:2];
}



- (IBAction)showLeftMenu:(id)sender;
{
    [self.view endEditing:YES];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)initTableView
{
    self.automaticallyAdjustsScrollViewInsets = YES;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    // 隐藏空白cell
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor = RGB(239, 239, 244);
    
    //列表头添加一条分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 19.5, CUR_SCREEN_W, 0.5)];
    [line setImage:[UIImage imageNamed:@"table_header_line.png"]];
    //headerView
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    BOOL IS = [[userDefault objectForKey:ISLOGIN] boolValue];
    if (IS) {
        
        HeaderOne *hea = [[HeaderOne alloc] init];
        hea.size = CGSizeMake(kScreenWidth, 305);
        hea.delegate = self;
        [_tableView beginUpdates];
        [_tableView setTableHeaderView:hea];// 关键是这句话
        [_tableView endUpdates];
        
    }else{
        
        SettingHeader *header = [[SettingHeader alloc] init];
        header.frame = CGRectMake(0, 0, kScreenWidth, 310);
        header.delegate = self;
        [_tableView beginUpdates];
        [_tableView setTableHeaderView:header];// 关键是这句话
        [_tableView endUpdates];
        
    }
    
    //    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 20)];
    //    headerView.backgroundColor = RGB(239, 239, 244);
    //    [headerView addSubview:line];
    //    _tableView.tableHeaderView = headerView;
    
    [_tableView reloadData];
}

- (void)sugress
{
    HeaderOne *hea = [[HeaderOne alloc] init];
    hea.size = CGSizeMake(kScreenWidth, 305);
    hea.delegate = self;
    [_tableView beginUpdates];
    [_tableView setTableHeaderView:hea];// 关键是这句话
    [_tableView endUpdates];
    
}

- (void)signOut
{
    SettingHeader *header = [[SettingHeader alloc] init];
    header.frame = CGRectMake(0, 0, kScreenWidth, 310);
    header.delegate =self;
    [_tableView beginUpdates];
    [_tableView setTableHeaderView:header];// 关键是这句话
    [_tableView endUpdates];
    
}

- (void) getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *hkCheckmeName = [ud objectForKey:@"HKCheckmeName"];
    NSString *HKUserName = [ud objectForKey:@"HKUserName"];  //连接到的用户名(HelathKit)
    
    UIView *view;
    
    //这里是 开启 HealthKit 功能
        if (section == ([DeviceStr hasPrefix:@"iPad"]? 5 : 2)) {
//    if (section == 1) {
//        DLog(@"..............................?????%d",section);
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
        SettingCell *cell = (SettingCell *)[tableView cellForRowAtIndexPath:path];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 40)];
        view.backgroundColor = RGB(239, 239, 244);
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CUR_SCREEN_W - 30, 50)];
        label.backgroundColor = [UIColor clearColor];
//        DLog(<#s, ...#>)
    
//        NSString *str = [NSString stringWithFormat:DTLocalizedString(@"%@User%@ is locked. If you want to change user, please delete this user and then select another user", nil),hkCheckmeName, HKUserName];
//        label.text = isConfigurateHealthKit ? (cell.detailTextLabel.text == nil ? (DTLocalizedString(@"Please select a user for data sharing to HealthKit, \n Note: The user cannot be changed after selection", nil)) : str) : DTLocalizedString(@"Touch to enable HealthKit function", nil);
         

        NSString *str = [NSString stringWithFormat:DTLocalizedString(@"Delete  phone  data  which  is  from  \"%@\" ", nil),curDirName];
        label.textColor = [UIColor redColor];
        label.text = str;
        
        
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.numberOfLines = 0;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:15];
        [view addSubview:label];
    }
    if (section == ([DeviceStr hasPrefix:@"iPad"]? 2 : 3)){
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 20)];
        view.backgroundColor = RGB(239, 239, 244);

        snlabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, CUR_SCREEN_W - 30, 20)];
        snlabel.backgroundColor = [UIColor clearColor];
        snlabel.textAlignment = NSTextAlignmentLeft;
        snlabel.lineBreakMode = NSLineBreakByCharWrapping;
        snlabel.numberOfLines = 0;
        snlabel.text = self.sn;
        snlabel.textColor = [UIColor lightGrayColor];
        snlabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:snlabel];
        
    }
    
    return view;
}

//这里原来设置了四个section分区   0 ~ 3 有四个
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if([DeviceStr hasPrefix:@"iPad"]){
    
        if (section == 0 || section == 1) {
            
            return 10;
        }else{
        
            return 30;
        }
    
    }else{
    
        if (section == 0 || section == 1) {
            
            return 10;
        }else if(section == 2){
            
            return 50;
        }else{
        
            return 30;
        }

    }
    
    if (section == 2) {
        
        float height = [DeviceStr hasPrefix:@"iPad"] ?10 : 50;
        return height;
    }else if (section == [DeviceStr hasPrefix:@"iPad"] ?2 : 3){
    
        return 30;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .1;

}


#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
        return ([DeviceStr hasPrefix:@"iPad"]? 3 : 4);
//    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
        if (sectionIndex == 1)   return 2;
    
        else   return 1;
    
//    return 1;
}


#pragma mark - 第一个分区(切换设备这个分区..这个分区只有一行数据)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell ;
    
// 第一个分区  设备切换(硬件蓝牙设备)
    if (indexPath.row == 0 && indexPath.section == 0) {   //切换设备
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] firstObject];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.text = DTLocalizedString(@"Switch Device", nil);
       cell.detailTextLabel.text = curDirName;
//        cell.detailTextLabel.text = @"222"; 测试
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
     else if (indexPath.section == 1){   // 单位
     cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
     if (cell == nil) {
     cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil][1];
     }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     if (indexPath.row == 0) {
     cell.theLabel.text = DTLocalizedString(@"Unit", nil);
     [cell.theSegCtr setTitle:DTLocalizedString(@"Metric", nil) forSegmentAtIndex:0];
     [cell.theSegCtr setTitle:DTLocalizedString(@"British", nil) forSegmentAtIndex:1];
     NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Unit"];
     if (!index) {
     index = 0;
     }
     [cell.theSegCtr setSelectedSegmentIndex:index];
     [cell.theSegCtr addTarget:self action:@selector(actionForUnit:) forControlEvents:UIControlEventValueChanged];
     } else if (indexPath.row == 1){
     cell.theLabel.text = DTLocalizedString(@"Thermometer", nil);
     [cell.theSegCtr setTitle:DTLocalizedString(@"℃", nil) forSegmentAtIndex:0];
     [cell.theSegCtr setTitle:DTLocalizedString(@"℉", nil) forSegmentAtIndex:1];
     NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Termometer"];
     if (!index) {
     index = 0;
     }
     [cell.theSegCtr setSelectedSegmentIndex:index];
     
     [cell.theSegCtr addTarget:self action:@selector(actionForTermometer:) forControlEvents:UIControlEventValueChanged];
     }
     }
    
    //开启 HealthKit  功能(分区为 2 row行为 0)
        else if (indexPath.section == ([DeviceStr hasPrefix:@"iPad"]? 5 : 2) && indexPath.row == 0) {    //切换用户 或开启HK功能
//    else if (indexPath.section == 2 && indexPath.row == 0){
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            BOOL isChooseUser = [ud boolForKey:@"isChooseHKUser"];
            NSString *hkUserName = [ud objectForKey:@"HKUserName"];
            NSString *hkCheckmeName = [ud objectForKey:@"HKCheckmeName"];
            isConfigurateHealthKit = [ud boolForKey:@"isConfigurateHealthKit"];
            NSMutableArray *userNameArr = [NSMutableArray array];
            for (User *user in [UserList instance].arrUserList) {
                [userNameArr addObject:user.name];
            }
            
            if (isConfigurateHealthKit) { //如果配置了HK
                
                if (isChooseUser == YES && hkUserName != nil && ![userNameArr containsObject:hkUserName] && [hkCheckmeName isEqualToString:curDirName]) {  //如果主机删除了用户
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
                    [ud setObject:nil forKey:@"HKUserName"];  //滞空
                    
                    if (!cell) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] firstObject];
                    }
                    cell.detailTextLabel.text = nil;
                }
                else if (isChooseUser == YES && hkUserName == nil) {  // 离线状态下开启HK功能时
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
                    if (!cell) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] firstObject];
                    }
                    cell.detailTextLabel.text = nil;
                }
                else if(isChooseUser == YES && hkUserName != nil) {  //正常选择状态下
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4"];
                    if (!cell) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] firstObject];
                    }
                    cell.detailTextLabel.text = hkUserName;
                    //                cell.userInteractionEnabled = NO;
                }
                
                cell.textLabel.text = DTLocalizedString(@"HealthKit user", nil);
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
                
            } else {  //如果没有配置HK
                cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3"];
                if (!cell) {
                    cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil][2];
                }
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:Ntf_HKSwitch_ON object:nil];
            }
    }
    //清除缓存 section 3 第四个分区  row为 0
    else if (indexPath.section == ([DeviceStr hasPrefix:@"iPad"]? 2 : 3) && indexPath.row == 0){    //清除缓存
#pragma mark - 清除缓存数据  Clear cache
//    else if (indexPath.section == 1 && indexPath.row == 0){
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *hkCheckmeName = [ud objectForKey:@"HKCheckmeName"];
        NSString *HKUserName = [ud objectForKey:@"HKUserName"];  //连接到的用户名(HelathKit)
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil][1];
        }
        cell.theLabel.hidden = YES;
        cell.theSegCtr.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
#pragma mark - 这里这个 Clear cache  是清除当前手机下载的数据,如果当前手机上下载了硬件设备传过来的数据,则点击Clear cache 就可以清除缓存数据...如果当前手机并没有下载硬件设备上的数据则不会有任务的清除效果 (清除手机缓存数据)
//        cell.textLabel.text = DTLocalizedString(@"Clear cache", nil);
          cell.textLabel.text = DTLocalizedString(@"Delete Data", nil);

        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor blackColor];
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        //一进入到Settings  设置页面就启动了这里
        DLog(@"删除删除删除删除删除删除删除删除删除删除删除删除删除删除删除删除删除");
    }
    return cell;
}

#pragma mark - notification for HealthKit
- (void)refreshData
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self selectUser];
}

- (void) selectUser
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (isSpc) {
        [ud setBool:YES forKey:@"isChooseHKUser"];
        [ud setObject:nil forKey:@"HKUserName"];
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Not applicable for Hospital mode", nil) duration:1.5];
        [self.tableView reloadData];
    } else {
        [self chooseUserToHealthKit];
    }
}

- (void) chooseUserToHealthKit
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *hkCheckmeName = [ud objectForKey:@"HKCheckmeName"];
    
    BOOL isChooseUser = [ud boolForKey:@"isChooseHKUser"];
    NSString *hkUserName = [ud objectForKey:@"HKUserName"];
    NSArray *list = [UserList instance].arrUserList;
    NSMutableArray *nameList = [NSMutableArray array];
    
    for (User *theUser in list) {
        [nameList addObject:theUser.name];
    }
    
    if (isChooseUser == NO ) {  //如果没有选择过用户
        [self addSIAlertViewWithList:list];
        
        [ud setObject:curDirName forKey:@"HKCheckmeName"];
    } else if (isChooseUser == YES && hkUserName != nil && ![nameList containsObject:hkUserName] && [hkCheckmeName isEqualToString:curDirName]) {  //已经选择过用户  但最新用户组中不包含之前选择过的用户  即主机删除了该用户  则重新选择用户
        NSArray *arr = [NSArray array];
        [ud setObject:arr forKey:@"hkIdentifiers"];    //清空arr
        
        [self addSIAlertViewWithList:list];
    } else {
        return;
    }
}
- (void) addSIAlertViewWithList:(NSArray *)list
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    SIAlertView *siAlert = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Please select a user for data sharing to HealthKit, \n Note: The user cannot be changed after selection", nil)
                            ];
    for (int i = 1; i < list.count; i ++) {  //list第一个用户为Guest  过滤掉
        User *user = list[i];
        [siAlert addButtonWithTitle:user.name type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [ud setBool:YES forKey:@"isChooseHKUser"];
            [ud setObject:user.name forKey:@"HKUserName"];   //存储当前选择的用户的名字
            _selectedHKUser = user;
            
            // 点击之后，如果是在线状态，则请求该用户DailyCheck 及 Pedometer的所有数据到HealthKit   即：一次性同步
            
            if (![AppDelegate GetAppDelegate].isOffline) {  //非离线状态，因为必须在在线状态下从Checkme获取最新数据
                
                [[HKUpdateUtils sharedInstance] updateAllDataToHealthKitWithUser:_selectedHKUser];
                [self.tableView reloadData];
                
            } else {  //  离线状态时
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Data is unable to be synchronized when offline", nil) duration:1.2];
                [ud setBool:YES forKey:@"isChooseHKUser"];
                [ud setObject:nil forKey:@"HKUserName"];
                [self.tableView reloadData];
            }
        }];
    }
    
    
    if (list.count <= 1) { //只有Guest用户
        [ud setBool:YES forKey:@"isChooseHKUser"];
        [ud setObject:nil forKey:@"HKUserName"];
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please create a user first", nil) duration:1.5];
        [self.tableView reloadData];
    } else {
        [siAlert show];
    }
}



#pragma mark - action For SecmentControl
- (void)actionForUnit:(UISegmentedControl *)seg
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (seg.selectedSegmentIndex == 0) {
        [ud setInteger:0 forKey:@"Unit"];
    }else {
        [ud setInteger:1 forKey:@"Unit"];
    }
    [ud synchronize];
    
    [self.tableView reloadData];
}
- (void)actionForTermometer:(UISegmentedControl *)seg
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (seg.selectedSegmentIndex == 0) {
        [ud setInteger:0 forKey:@"Termometer"];
    }else {
        [ud setInteger:1 forKey:@"Termometer"];
    }
    [ud synchronize];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && indexPath.section == 0) {   //切换设备
        [self switchDevice];
    }else if (indexPath.row == 0 && indexPath.section == ([DeviceStr hasPrefix:@"iPad"]? 4 : 1) && isConfigurateHealthKit) {  //切换用户
//    else if (indexPath.row == 0 && indexPath.section == 2 && isConfigurateHealthKit) {
        SettingCell *cell = (SettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell.userInteractionEnabled == YES) {
            [self switchUserWith:cell];
        }
    }
    else if (indexPath.row == 0 && indexPath.section == ([DeviceStr hasPrefix:@"iPad"]? 2 : 3)) {  //清除缓存
//    else if (indexPath.row == 0 && indexPath.section == 1) {
        [self clearCashes];
    }
}


/*****switch Device*****/
- (void) switchDevice
{
    if ([AppDelegate GetAppDelegate].isOffline) {   //离线状态
        
        SwitchModeViewController *switchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"switchModeViewController"];
        switchVC.isSwitchDevice = YES;
        switchVC.isSwitchUser = NO;
        [self.navigationController pushViewController:switchVC animated:YES];
    } else {  //在线
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not change device when you connecting a Checkme", nil) duration:1.5];
    }
}

/*****switch User*****/
- (void)switchUserWith:(SettingCell *)cell
{
    if (isSpc) {  //Hospital模式
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Not applicable for Hospital mode", nil) duration:1.5];
    } else {
        NSMutableArray *userList = [[UserList instance].arrUserList mutableCopy];
        if (userList.count > 0) {
            [userList removeObjectAtIndex:0];  //删除Guest用户
        }
        
        if ([AppDelegate GetAppDelegate].isOffline) {
            [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"User cannot be selected when offline", nil) duration:1.5];
        }else {
            if (userList.count == 0) {
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please create a user first", nil) duration:1.5];
            } else {
                SwitchModeViewController *switchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"switchModeViewController"];
                switchVC.isSwitchDevice = NO;
                switchVC.isSwitchUser = YES;
                [self.navigationController pushViewController:switchVC animated:YES];
            }
        }
        
    }
    
}

#pragma mark - 清除缓存数据
/*****clear cash*****/
- (void)clearCashes
{
    SIAlertView *alertView1 = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil) andMessage:DTLocalizedString(@"Really want to erase all data ?", nil)];
    [alertView1 addButtonWithTitle:DTLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        // 清除缓存
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkFiles) userInfo:nil repeats:YES];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        //删除 非当前连入的checkme文件夹
        NSArray *dirNames = [fm contentsOfDirectoryAtPath:documentsURL.path error:nil];
        for (NSString *dirName in dirNames) {
            if (![dirName isEqualToString:curDirName]) {
                NSURL *dirURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
                [fm removeItemAtPath:dirURL.path error:nil];
            }
        }
        
        //删除当前连入的checkme文件夹下的 非usr.dat文件
        NSURL *curDirURL = [documentsURL URLByAppendingPathComponent:curDirName isDirectory:YES];
        //拿到当前文件夹下的全部文件
        NSArray *fileNames = [fm contentsOfDirectoryAtPath:curDirURL.path error:nil];
        for (NSString *fileName in fileNames) {
            if (![fileName isEqualToString:@"usr.dat"] && ![fileName isEqualToString:@"xusr.dat"]) {
                NSURL *fileURL = [curDirURL URLByAppendingPathComponent:fileName];
                [fm removeItemAtPath:fileURL.path error:nil];
            }
        }
        
        [CloudModel clearTable];

    }];
    
    [alertView1 addButtonWithTitle:DTLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
    }];
    [alertView1 show];
}

- (void) checkFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *data = [[NSData alloc] initWithContentsOfFile:documentsURL.path];
    if (data.length == 0) {
        [timer invalidate];
        [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Delete Data successed", nil) duration:1.5];
    }
}


@end
