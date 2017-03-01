//
//  SwitchModeViewController.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/31.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SwitchModeViewController.h"
#import "Colors.h"
#import "FileUtils.h"
#import "BTUtils.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "FileParser.h"
#import "SVProgressHUD.h"
#import "NSDate+Additional.h"

//** HealthKit 健康值*/
#import "HKUpdateUtils.h"

@interface SwitchModeViewController ()
@property (nonatomic, strong) NSMutableArray* deviceArr;
@property (nonatomic, strong) NSMutableArray* userArr;
@end

@implementation SwitchModeViewController
{
    NSString *curDirName;
    BOOL isSpc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParameters];
    [self getCurDIRName];
    [self getDeviceName];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initParameters
{
    isSpc = [UserList instance].isSpotCheck;
    _userArr = [NSMutableArray array];
    _deviceArr = [NSMutableArray array];
    
    if (isSpc == NO) {
        NSMutableArray *arr = [[UserList instance].arrUserList mutableCopy];
        //删除Guest用户
        if (arr.count >0) {
            [arr removeObjectAtIndex:0];
        }
        for (User *user in arr) {
            [_userArr addObject:user.name];
        }
    }
}

- (void)getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
//#warning 清除记录 hjz
//    //清除记录
//    [UserDefaults removeObjectForKey:lastCheckmeName];
//    [UserDefaults synchronize];
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >9999999999");
}

-(void) getDeviceName   //切换设备时用到
{
    self.deviceArr = [NSMutableArray array];
    
    if (_isSwitchDevice== YES) {   //如果是切换设备跳转过来的
        _deviceArr = [[FileUtils readAllFileNamesInDocumentsWithPrefix:@"BM-88" inDirectory:nil] mutableCopy];   //获取所有以BM-88开头的文件夹名称
    }
}

- (void) initTableView
{        
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // 隐藏空白cell
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 30)];
    headerView.backgroundColor = RGB(239, 239, 244);
    _tableView.tableHeaderView = headerView;
    
    _tableView.backgroundColor = RGB(239, 239, 244);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_tableView];

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSwitchDevice == YES)    return self.deviceArr.count;
    
    else if(_isSwitchUser == YES)      return _userArr.count;
    
    else return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    int index2 = 0;
    for (int i = 0; i < _deviceArr.count; i ++) {
        if ([_deviceArr[i] isEqualToString:curDirName]) {
            index2 = i;
        }
    }
    
    NSString *HKUserName = [ud objectForKey:@"HKUserName"];
    int index3 = -1;
    for (int i = 0; i < _userArr.count; i ++) {
        if ([_userArr[i] isEqualToString:HKUserName]) {
            index3 = i;
        }
    }
    
    static NSString *i = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
    }
    if (_isSwitchDevice == YES) {    //如果是切换设备
        //加标记
        if (indexPath.row == index2) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = _deviceArr[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        
    }
    else if (_isSwitchUser == YES) {  //如果是切换用户
        //加标记
        if (indexPath.row == index3) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        cell.textLabel.text = _userArr[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_isSwitchDevice == YES) {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self switchDeviceWith:cell];
    }
    else if (_isSwitchUser == YES && isSpc == NO) {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self switchUserWithCell:cell];
    }
}


#pragma switchDevice
- (void) switchDeviceWith:(UITableViewCell *)cell
{
    //切换设备
    // 新改动
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:cell.textLabel.text forKey:@"OfflineDirName"];
    [ud synchronize];
    NSString *lastCKName = cell.textLabel.text;
    NSString *measureMode = [ud objectForKey:lastCKName];
    if (!measureMode) {  //兼容以前版本
        isSpc = NO;
    }
    else if ([measureMode isEqualToString:@"mode_home"]) {
        isSpc = NO;
    }
    else if ([measureMode isEqualToString:@"mode_hospital"]) {
        isSpc = YES;
    }
    
    [self requestUserListWithCheckmeName:cell.textLabel.text];
    [self getCurDIRName];
    
    [self.tableView reloadData];
}

- (void) requestUserListWithCheckmeName:(NSString *)ckName
{
    if (isSpc == YES) {
        NSData *data = [FileUtils readFile:Hospital_Home_USER_LIST_FILE_NAME inDirectory:ckName];
        if (data) { //本地有数据
            NSArray *list = [FileParser paserXusrList_WithFileData:data];
            [[UserList instance].arrXuserList setArray:list];
            [UserList instance].isSpotCheck = YES;
        }
    } else if (isSpc == NO) {
        
        
        NSString *oldfileName = @"usr.dat";
        if ([FileUtils isFileExist:oldfileName inDirectory:ckName]) {
            
            NSData *data =  [FileUtils readFile:oldfileName inDirectory:ckName];
            NSArray *olduserListArr = [self parseOldUserList_WithFileData:data];
            
            if (olduserListArr.count != 0) { //本地有数据
                
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < olduserListArr.count; i++) {
                    
                    User *user  = olduserListArr[i];
                    UserItem *userItem = [[UserItem alloc] init];
                    userItem.ID = user.ID;
                    userItem.ICO_ID = user.ICO_ID;
                    userItem.dtcBirthday = user.dtcBirthday;
                    userItem.headIcon = user.headIcon;
                    userItem.weight = user.weight;
                    userItem.height = user.height;
                    userItem.name = user.name;
                    userItem.age = user.age;
                    userItem.gender = user.gender;
                    userItem.medical_id = [NSString stringWithFormat:@"%@%d",ckName,user.ID];
                    [array addObject:userItem];
                    
                }
                
                [self saveUserList:array withDirectoryName:ckName];
                [FileUtils deleteFile:@"usr.dat" inDirectory:ckName];
                
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSLog(@"documentsDirectory%@",documentsDirectory);
                NSFileManager *fileManage = [NSFileManager defaultManager];
                NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:ckName];
                NSDirectoryEnumerator *enumerator = [fileManage enumeratorAtPath:myDirectory];
                for (NSString *fileName in enumerator)
                {
                    NSLog(@"%@",fileName);
                    if ([fileName isEqualToString:@"*usr.dat"] || [fileName isEqualToString:@"usr.dat"]) {
                        
                    }else{
                        
                        if([fileName rangeOfString:@"*"].location ==NSNotFound)//_roaldSearchText
                        {
                            
                            if([fileName rangeOfString:@"ECG"].location !=NSNotFound || [fileName rangeOfString:@"SPO2"].location !=NSNotFound || [fileName rangeOfString:@"TEMP"].location !=NSNotFound){
                                
                                NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",ckName,fileName]];
                                NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@1%@*",ckName,ckName,fileName]];
                                [fileManage moveItemAtPath:old toPath:new error:nil];
                                [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@1%@*",ckName,fileName]];
                                [UserDefaults synchronize];
                                
                            }
                            
                            
                            NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",ckName,fileName]];
                            NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@*",ckName,ckName,fileName]];
                            [fileManage moveItemAtPath:old toPath:new error:nil];
                            [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@%@*",ckName,fileName]];
                            [UserDefaults synchronize];
                            
                        }
                        
                    }
                    
                }
            }
            
        }

        
        
        
        
        
        NSArray *userListArr;
        //  读取本地文件
        if ([FileUtils isFileExist:Home_USER_LIST_FILE_NAME inDirectory:ckName]) {
            
            NSData *dlcListData = [FileUtils readFile:Home_USER_LIST_FILE_NAME inDirectory:ckName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            userListArr = [unArch decodeObjectForKey:Home_USER_LIST_FILE_NAME];
        }
        
        
        if (userListArr.count != 0) { //本地有数据
           
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < userListArr.count; i++) {
                    
                    UserItem *userItem = userListArr[i];
                    User *user = [[User alloc] init];
                    user.ID = userItem.ID;
                    user.ICO_ID = userItem.ICO_ID;
                    user.dtcBirthday = userItem.dtcBirthday;
                    user.headIcon = userItem.headIcon;
                    user.weight = userItem.weight;
                    user.height = userItem.height;
                    user.name = userItem.name;
                    user.age = userItem.age;
                    user.gender = userItem.gender;
                    user.ID = userItem.ID;
                    user.medical_id = userItem.medical_id;
                    [array addObject:user];
                    
                }
                
                
                [[UserList instance].arrUserList setArray:array];
                [UserList instance].isSpotCheck = NO;
            }

        
        
        
//        NSData *data = [FileUtils readFile:Home_USER_LIST_FILE_NAME inDirectory:ckName];
//        if (data) { //本地有数据
//            NSArray *list = [FileParser parseUserList_WithFileData:data];
//            [[UserList instance].arrUserList setArray:list];
//            [UserList instance].isSpotCheck = NO;
//        }
    }
}

#pragma mark -------旧版本解析userList
- (NSArray *)parseOldUserList_WithFileData:(NSData *)data
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = data.length;   // 27*i
    
    for(int left = dataLen; left >= 27; left -= 27){  //一个用户占27个字节
        unsigned char *p = bytes + dataLen - left;
        
        User *aUser = [[User alloc] init];
        aUser.ID = p[0];
        
        char nameBuff[17] = {0x00};
        int i = 0 ;
        for(i=0;((char *)(p+1))[i] != '\0' && i < 16; ++i)
        {
            nameBuff[i] = ((char *)(p+1))[i];
        }
        nameBuff[i] = '\0';
        aUser.name = [NSString stringWithUTF8String:nameBuff];  //[NSString stringWithCString:(char *)(p+1) length:16];
        aUser.ICO_ID = p[17];
        aUser.gender = (p[18] == 0 ? kGender_FeMale:kGender_Male);
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[19], dtc.year);
        dtc.month = p[21];
        dtc.day = p[22];
        aUser.dtcBirthday = dtc;
        
        U16 w = 0,h=0;
        P2U16(&p[23], w);
        P2U16(&p[25], h);
        aUser.weight = (double)w / 10;
        aUser.height = (double)h;
        
        [arr addObject:aUser];
    }
    DLog(@"  解析完毕！！！");
    return arr;
    
}



- (void)saveUserList:(NSArray *)users withDirectoryName:(NSString *)dirname
{
    NSString *fileName = Home_USER_LIST_FILE_NAME;
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:users forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:dirname];
    
}

#pragma switchUser
- (void)switchUserWithCell:(UITableViewCell *)cell
{
    if ([AppDelegate GetAppDelegate].isOffline) {  //离线
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"User cannot be selected when offline", nil) duration:1.5];
    }else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:cell.textLabel.text forKey:@"HKUserName"];   //存储当前选择的用户的名字
        [ud setObject:curDirName forKey:@"HKCheckmeName"];   //存储选择用户的Checkme名称
        //为何这里没有设置    立即同步到  沙箱路径中呢？
//        [ud synchronize];
        //*************************  hjz **********************************//
        
        NSArray *userArr = [UserList instance].arrUserList;
        for (User *user in userArr) {
            NSString *userName = user.name;
            if ([cell.textLabel.text isEqualToString:userName]) {
                [[HKUpdateUtils sharedInstance] updateAllDataToHealthKitWithUser:user];
            }
        }
        
        //*************************** hjz  ********************************//
    }
    
    [self.tableView reloadData];
}

@end
