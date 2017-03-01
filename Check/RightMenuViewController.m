//
//  RightMenuViewController.m
//  Checkme Mobile
//
//  Created by Lq on 14-12-11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "RightMenuViewController.h"
#import "User.h"
#import "Xuser.h"
#import "UserList.h"
#import "UserItem.h"
#import "NavigationViewController.h"
#import "DailyCheckViewController.h"
#import "PedViewController.h"
#import "Colors.h"
#import "RightMenuCell.h"
#import "MobClick.h"

#import "SettingsViewController.h"
#import "ShareAlert.h"

@interface RightMenuViewController ()
{
    NSString* lastCheckmeName;
    NSMutableArray *_lxuserList;
}
@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) Xuser *curXuser;

@property (nonatomic, strong) NSMutableArray *userDataArr;

@property (nonatomic) BOOL isSpc;
@end

@implementation RightMenuViewController
static int curUserIndex = 0;
static int curXuserIndex = 0;

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"RightPage"];
    
    _lxuserList = [NSMutableArray array];
    if ([UserList instance].isSpotCheck)
        _isSpc = YES;
    else
        _isSpc = NO;
    
    [self loadUsers];

    [self.tableView reloadData];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"RightPage"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"进入右侧栏！");
    [self loadPreference];
    self.tableView.separatorColor = Colol_cellbg;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = DEFAULT_BLUE;
    [self initHeader];    
}

- (void)loadUsers
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    NSString *curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName:lastCheckmeName;
    
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:Home_USER_LIST_FILE_NAME];

    [_lxuserList addObjectsFromArray:[UserList instance].arrUserList];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
        
        NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
        NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
        dlcListArr = [unArch decodeObjectForKey:fileName];
        
    }
    
    _lxuserList = [NSMutableArray arrayWithArray:dlcListArr];
    
//    NSMutableArray *array = [NSMutableArray array];
//    [array addObjectsFromArray:[UserList instance].arrUserList];
//    
//    for (UserItem *localItem in dlcListArr) {
//        for (UserItem *user in [UserList instance].arrUserList) {
//            
//            if ([user.medical_id isEqualToString:localItem.medical_id]) {
//                //存在相同的
//                [array removeObject:user];
//            }
//        }
//    }
//    
//    NSMutableArray *totalUsers = [NSMutableArray array];
//    for (User *user in array) {
//        UserItem *userItem = [[UserItem alloc] init];
//        userItem.ID = user.ID;
//        userItem.ICO_ID = user.ICO_ID;
//        userItem.dtcBirthday = user.dtcBirthday;
//        userItem.headIcon = user.headIcon;
//        userItem.weight = user.weight;
//        userItem.height = user.height;
//        userItem.name = user.name;
//        userItem.age = user.age;
//        userItem.gender = user.gender;
//        userItem.ID = user.ID;
//        userItem.medical_id = user.medical_id;
//        [totalUsers addObject:userItem];
//    }
//    [totalUsers addObjectsFromArray:dlcListArr];


}

- (void)loadPreference
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[ud integerForKey:@"LastUser"];
    curXuserIndex = (int)[ud integerForKey:@"LastXuser"];
}

- (void)initHeader
{
    self.tableView.tableHeaderView = ({
        double viewWidth = self.view.bounds.size.width;
        double viewHeight = 20;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        view.backgroundColor = DEFAULT_BLUE;
        view;
    });
}

//警告处理..
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//设置行高...
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = Colol_lableft;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSpc) {
        return [UserList instance].arrXuserList.count;
    }else {
        
        return _lxuserList.count;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";//注册单元格 定义唯一标识符
    RightMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (_isSpc) {
            Xuser *xUser = [[UserList instance].arrXuserList objectAtIndex:indexPath.row];
            NSString *userName = xUser.patient_ID;
            UIImage *image = nil;
            if (xUser.sex == 1) {
                image = [UIImage imageNamed:@"b4.png"];
            } else if (xUser.sex == 0) {
                image = [UIImage imageNamed:@"b9.png"];
            }else {
                image = [UIImage imageNamed:@"b1.png"];
            }
            
            cell = [[RightMenuCell alloc] initWithImage:image andTitle:userName];
            if (indexPath.row == curXuserIndex) {
                cell.Name.textColor = Colol_xiantiao;
            }
            
        }else {
//            User *user = [[UserList instance].arrUserList objectAtIndex:indexPath.row];
            UserItem *item = _lxuserList[indexPath.row];
            NSString *userName = item.name;
            UIImage *userIcon = [UIImage imageNamed:[NSString stringWithFormat:@"ljico%@.png",INT_TO_STRING(item.ICO_ID)]];
            cell = [[RightMenuCell alloc] initWithImage:userIcon andTitle:userName];
            if (indexPath.row == curUserIndex) {
                cell.Name.textColor = Colol_xiantiao;
            }
            if(item.medical_id.length >8){
                NSString *str = [item.medical_id substringFromIndex:item.medical_id.length - 4];
                cell.idLabel.text = [NSString stringWithFormat:@"****%@",str];
                
                
            }else{
            
                cell.idLabel.text = item.medical_id;
                
            }

        }
    }
    
    cell.btn.tag = indexPath.row;
    cell.btn.hidden = YES;
    [cell.btn addTarget:self action:@selector(buttonAC:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (void)buttonAC:(UIButton *)sender
{
    
    if(![UserDefault boolForKey:ISLOGIN]){
        
        NavigationViewController *navi = (NavigationViewController *)self.mm_drawerController.centerViewController;
        
        SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
        navi.viewControllers = @[settingsViewController];
        [self.mm_drawerController setCenterViewController:navi withCloseAnimation:YES completion:nil];
        
        return;
    }
    
    self.index = sender.tag;
    ShareAlert *alert = [[ShareAlert alloc] init];
    alert.delegate = self;
    [alert show];
    
}

- (void)shareText:(NSString *)text
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    NSString *curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
    NSString *sn = [userDefaults objectForKey:[NSString stringWithFormat:@"#%@",curDirName]];
    NSLog(@"%@",sn);
    
    if (_isSpc) {
        
//        Xuser *xUser = [[UserList instance].arrXuserList objectAtIndex:self.index];
//        
//        if(xUser.userID == 0){
//            
//            [WXDataService postPatianIDUrl:@"https://cloud.viatomtech.com/patient" params:@{@"resourceType":@"Patient",@"identifier":@{@"system":@"http://www.viatomtech.com.cn",@"value": [NSString stringWithFormat:@"%@%d",sn,xUser.userID],@"medicalId": [NSString stringWithFormat:@"%@%d",sn,xUser.userID]},@"active": @"1",@"name": @"Guest",@"gender": @"male",@"birthDate":@"1980-12-31",@"height":[NSString stringWithFormat:@"%d'%d''",(int) (175 / 2.54) / 12,(int)(175 / 2.54) % 12 ],@"weight": [NSString stringWithFormat:@"%.flb",132],@"stepSize":@"--"} cacheKey:[NSString stringWithFormat:@"%@%d",sn,xUser.userID] finishBlock:^(id result) {
//                NSDictionary *dic = result;
//                NSString *patinID = dic[@"patient_id"];
//                
//                [self shareEmail:text patientID:patinID];
//                
//            } errorBlock:^(NSError *error) {
//                
//            }];
//            
        
//        }
        
    }else {
        
        User *user = [[UserList instance].arrUserList objectAtIndex:self.index];
//        if (user.ID != 1) {
        
 
//            int h = round((float)user.height/2.54);

            [WXDataService postPatianIDUrl:@"https://cloud.bodimetrics.com/fhir/patient" params:@{@"resourceType":@"Patient",@"identifier":@{@"system":@"http://www.viatomtech.com.cn",@"value": sn,@"medicalId": user.medical_id},@"active": @"1",@"name": user.name,@"gender":user.gender == kGender_FeMale ? @"male":@"female",@"birthDate":[NSString stringWithFormat:@"%.2ld-%.2ld-%.2ld",user.dtcBirthday.year,user.dtcBirthday.month,user.dtcBirthday.day],@"height":[NSString stringWithFormat:@"%.fcm",user.height],@"weight": [NSString stringWithFormat:@"%.fkg",user.weight],@"stepSize":@"--"} cacheKey:[NSString stringWithFormat:@"%@%d",sn,user.ID] finishBlock:^(id result) {
                NSDictionary *dic = result;
                NSString *patinID = dic[@"patient_id"];
                [self shareEmail:text patientID:patinID];
            } errorBlock:^(NSError *error) {
                
            }];
    }
    
}

- (void)shareEmail:(NSString *)email patientID:(NSString *)patinID
{
    
    NSDictionary *dic = @{ @"patientId": patinID,@"toEmail":email};
    [WXDataService postUrl:@"https://cloud.bodimetrics.com/fhir/shareto" params:dic finishBlock:^(id result) {
        
        if ([result[@"status"] isEqualToString:@"error"]) {
            [SVProgressHUD showErrorWithStatus:@""];

        }else{
            
        [SVProgressHUD showSuccessWithStatus:@""];
            
        }
        
        
    } errorBlock:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@""];
        
    }];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NavigationViewController *navi = (NavigationViewController *)self.mm_drawerController.centerViewController;
    DailyCheckViewController *dailyCheckViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dailyCheckViewController"];
    PedViewController *pedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pedViewController"];
    
    // 在这里做一些事情kk
    //[self switchUserIndex:indexPath.row andXuserIndex:indexPath.row];
    [self switchUserIndex:(int)indexPath.row andXuserIndex:(int)indexPath.row];
    [self loadPreference];
    [tableView reloadData];
    
    
    if (navi.visibleViewController == dailyCheckViewController) {
        navi.viewControllers = @[dailyCheckViewController];
    }else if (navi.visibleViewController == pedViewController) {
        navi.viewControllers = @[pedViewController];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_ClickUserList object:@(indexPath.row)];
    [self.mm_drawerController setCenterViewController:navi withCloseAnimation:YES completion:nil];
}

- (void)switchUserIndex:(int)userIndex andXuserIndex:(int)xUserIndex
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (_isSpc) {
        [ud setInteger:xUserIndex forKey:@"LastXuser"];
    }else {
        [ud setInteger:userIndex forKey:@"LastUser"];
    }
    
}

@end
