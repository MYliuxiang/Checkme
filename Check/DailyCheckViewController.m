//
//  DailyCheckViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-4.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "DailyCheckViewController.h"
#import "DailyCheckDetailViewController.h"
#import "UserList.h"
#import "AppDelegate.h"
#import "PublicMethods.h"
#import "FileParser.h"
#import "DailyCheckCell.h"
#import "LoadingViewUtils.h"
#import "NoInfoViewUtils.h"
#import "SVProgressHUD.h"
#import "ChartWave.h"
#import "SIAlertView.h"

#import "UIImage+compress.h"
#import "FileUtils.h"
#import "NSDate+Additional.h"
#import "MobClick.h"
#import "CBAutoScrollLabel.h"

#import "SpotCheckCell.h"
#import "BTCommunication.h"

@interface DailyCheckViewController() <UIAlertViewDelegate, BTCommunicationDelegate,DownManagerDelegate,LXAlertDelege>

@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) UIView* chartBaseView;//趋势图，各按钮的容器
@property (nonatomic,retain) ChartWave* hrWave,*spo2Wave,*bpWave, *piWave;
@property (nonatomic,retain) UIButton* hrBn,*spo2Bn,*bpBn, *piBn;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@property (nonatomic, strong) NSMutableArray *localDLCListArr;
@property (nonatomic, strong) NSMutableArray *localSPCListArr;
@end

@implementation DailyCheckViewController
{
    NSString *lastCheckmeName;
    NSString *curDirName;
    UIScrollView *sc;
    CBAutoScrollLabel* sl;
    BOOL isSpc;
    
    BOOL isUser;
    BOOL isday;
    BOOL isweek;
    BOOL ismonth;
    BOOL isyear;
    
    
    
}
static int curUserIndex = 0;
static int curXuserIndex = 0;

#pragma mark - Main UI methods

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"DLCPage"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"DLCPage"];
    
    isSpc = [UserList instance].isSpotCheck ? YES : NO;
    
    //刷新录音图标 改变其颜色
    [self.tableView reloadData];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

//右侧的按钮(显示右侧按钮)
- (void) unHideRightButton
{
    //显示右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:NO];
        }
        if ([obj isKindOfClass:[UILabel class]]) {
            [obj removeFromSuperview];
        }
    }
}

- (void)dealloc
{
    //删除滚动label
    if (sl) {
        [sl removeFromSuperview];//移除sl标签
        sl = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self unHideRightButton];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![AppDelegate GetAppDelegate].isOffline) { //离线状态
        
        if (![[UserDefaults objectForKey:@"fileVer"] isEqualToString:@"1.0"]) {
            
            
            NavigationViewController *navigationController = (NavigationViewController *)self.mm_drawerController.centerViewController;
            AboutCheckmeViewController* aboutCheckmeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutCheckmeViewController"];
            [navigationController pushViewController:aboutCheckmeViewController animated:YES];
            
            
            return;
        }
    }
    
    DLog(@"进入到DailyCheck!!!");
    [self loadBasicalData];
    
    
}

- (void) loadBasicalData
{
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    isSpc = [UserList instance].isSpotCheck ? YES : NO;
    [self addRightBtn];//添加右侧按钮
    [self createDirectoryInDocuments];
    [self loadPreference];
    [self switchUser:curUserIndex andCurXuserIndex:curXuserIndex];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = DTLocalizedString(@"Back", nil);
    self.navigationItem.backBarButtonItem = backItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickUserListNtf:) name:NtfName_ClickUserList object:nil];
}

//添加右侧按钮
- (void) addRightBtn
{
    UIImage *image = [UIImage imageNamed:@"me.png"];
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(self.view.bounds.size.width - 33 - 10,  5, 30, 30);
    [_rightBtn setBackgroundImage:image forState:UIControlStateNormal];
    _rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [_rightBtn addTarget:self action:@selector(showRightMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_rightBtn];
}

- (void)showRightMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)onClickUserListNtf:(NSNotification *)ntf
{
    [self removeAllSubView];
    if (isSpc) {
        curXuserIndex = (int)[ntf.object integerValue];
    }else {
        curUserIndex = (int)[ntf.object integerValue];
    }
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex andCurXuserIndex:curXuserIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)removeAllSubView
{
    for (id obj in self.view.subviews) {
        [obj removeFromSuperview];
    }
}

-(void)configNaviBar
{
    //导航栏头像
    UIImage* img = nil;
    if (isSpc) {
        if (_curXuser.sex == 1) {
            img = [UIImage imageNamed:@"me.png"];
        } else if (_curXuser.sex == 0) {
            img = [UIImage imageNamed:@"me.png"];
        }else {
            img = [UIImage imageNamed:@"me.png"];
        }
    } else {
        //        img = [UIImage imageNamed:[NSString stringWithFormat:@"b%@",INT_TO_STRING(_curUser.ICO_ID)]];
        img = [UIImage imageNamed:[NSString stringWithFormat:@"me"]];
        
    }
    [_rightBtn setImage:img forState:UIControlStateNormal];
    
    /**添加滚动label*/
    if (sl) {
        [sl removeFromSuperview];
        sl = nil;
    }
    self.navigationItem.title = nil;
    
    
    NSString *title = isSpc ? DTLocalizedString(@"Spot Check - %@", nil) : DTLocalizedString(@"Daily Check - %@", nil);
    NSString *titleStr = [NSString stringWithFormat:title, (isSpc ? _curXuser.patient_ID : _curUser.name)];
    sl = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(-10, 0, 150, 40)];
    sl.text = titleStr;
    sl.pauseInterval = 1.0f;
    sl.font = [UIFont boldSystemFontOfSize:17];
    sl.textColor = [UIColor blackColor];
    sl.textAlignment = NSTextAlignmentCenter;
    sl.fadeLength = 3.0f;
    [sl observeApplicationNotifications];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    //    [view addSubview:sl];
    //    self.navigationItem.titleView = view;
    //    view.center = CGPointMake(view.superview.center.x, view.center.y);
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    
    CGRect frame;
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
    
    frame = view.frame;
    frame.size.width = 200 - maxWidth * 2;
    view.frame = frame;
    
    [view addSubview:sl];
    self.navigationItem.titleView = view;
}

- (void) createDirectoryInDocuments
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    //[userDefaults setObject:lastCheckmeName forKey:@"LastCheckmeName"]; //实现存储操作
    if (lastCheckmeName) {
        if (![FileUtils isDirectoryExistInDocumentsWithName:lastCheckmeName]) { //如果本地不存在文件夹 就创建
            [FileUtils createDirectoryInDocumentsWithName:lastCheckmeName];
        }
        //#warning 清除记录 hjz
        //        //清除记录
        //        [UserDefaults removeObjectForKey:lastCheckmeName];
        //        [UserDefaults synchronize];//立即同步执行
        //        DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >3333333333");
    }
    
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
    
}

//******************************
//打开存档，查看上次使用的用户
-(void)loadPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
    curXuserIndex = (int)[userDefaults integerForKey:@"LastXuser"];
    [userDefaults synchronize];
}

-(void)switchUser:(int)userIndex andCurXuserIndex:(int)xUserIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (isSpc == YES) {    //是spotCheck
        if (xUserIndex >= [UserList instance].arrXuserList.count) {
            xUserIndex = 0;
            curXuserIndex = xUserIndex;
        }
        [userDefaults setInteger:curXuserIndex forKey:@"LastXuser"];
        _curXuser = [[UserList instance].arrXuserList objectAtIndex:xUserIndex];
        [_curXuser.arrSpotCheck removeAllObjects];
        
        [userDefaults setInteger:_curUser.ID forKey:@"curXuserID"];
        
        [self loadLocalSpotCheckList];
        
    } else if (isSpc == NO) {    //是DailyCheck
        //如果已经主机删除了用户
        if (userIndex >=[[UserList instance].arrUserList count]) {
        
//            userIndex = 0;
            isUser = NO;
            curUserIndex = userIndex;
            
            //从本地拿数据UserList
            NSMutableArray *dlcListArr = [NSMutableArray array];
            NSString *fileName = [NSString stringWithFormat:Home_USER_LIST_FILE_NAME];
            //  读取本地文件
            if ([FileUtils isFileExist:fileName inDirectory:lastCheckmeName]) {
                
                NSData *dlcListData = [FileUtils readFile:fileName inDirectory:lastCheckmeName];
                NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
                dlcListArr = [unArch decodeObjectForKey:fileName];
            }
            
            
            UserItem *ietm = dlcListArr[userIndex];
            _curUser = [[User alloc] init];
            _curUser.ID = ietm.ID;
            _curUser.ICO_ID = ietm.ICO_ID;
            _curUser.dtcBirthday = ietm.dtcBirthday;
            _curUser.headIcon = ietm.headIcon;
            _curUser.weight = ietm.weight;
            _curUser.height = ietm.height;
            _curUser.name = ietm.name;
            _curUser.age = ietm.age;
            _curUser.gender = ietm.gender;
            _curUser.ID = ietm.ID;
            _curUser.medical_id = ietm.medical_id;
            
//          u = dlcListArr[userIndex];
            [_curUser.arrDlc removeAllObjects];

            [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
            [self loadLocalDLCList];

        }else{
           
            isUser = YES;
        [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
        
        _curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        [_curUser.arrDlc removeAllObjects];
        
        [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
        
        // 加载本地数据
        [self loadLocalDLCList];
            
        }
    }
}



- (void) loadLocalSpotCheckList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_localSPCListArr) {
            [_localSPCListArr removeAllObjects];
        }else {
            _localSPCListArr = [NSMutableArray array];
        }
        NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%d_SPC_Data-", _curXuser.userID] inDirectory:curDirName];
        if (fileArr) {
            for (NSString *fileName in fileArr) {
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                SpotCheckItem *localSPCItem = [unAch decodeObjectForKey:fileName];
                [_localSPCListArr addObject:localSPCItem];    //////////
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadSpotCheck];
        });
    });
}
- (void) loadSpotCheck
{
    if(self.curXuser.arrSpotCheck.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果当前用户的arrSpotCheck数据并未初始化过
        if ([AppDelegate GetAppDelegate].isOffline) { //离线状态
            if (self.localSPCListArr.count != 0) {
                [self.curXuser.arrSpotCheck addObjectsFromArray:self.localSPCListArr];
            }
            [self refreshView];
        }else {  //非离线状态
            
            [BTCommunication sharedInstance].delegate = self;
            [_curXuser.arrSpotCheck removeAllObjects];
            
            NSString *fileName = [NSString stringWithFormat:SPC_LIST_FILE_NAME, _curXuser.userID];
            [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SpotCheckList];
            
            
        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             self.curXuser.arrSpotCheck.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_SpotCheckList)){//如果正在下载别的用户数据
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
    }else{//已有数据
        DLog(@"有数据！");
        [self refreshView];
    }
}

//离线状态下解析本地列表
- (NSArray *)parseLocalSPCList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:SPC_LIST_FILE_NAME, _curXuser.userID];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
        
        NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
        NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
        dlcListArr = [unArch decodeObjectForKey:fileName];
    }
    return dlcListArr;
}



- (void)combineLocalSPCListWithCheckmeSPCList
{
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    if ([AppDelegate GetAppDelegate].isOffline) {  //离线时
        arr = [[self parseLocalSPCList] mutableCopy];
    } else { //非离线时
        
        NSString *fileName = [NSString stringWithFormat:SPC_LIST_FILE_NAME,_curXuser.userID];
        
        if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
            
            arr = [[self parseLocalSPCList] mutableCopy];
            
        }else{
            
            arr = [_curXuser.arrSpotCheck mutableCopy];  //checkme端的数据
            
        }
        
    }
    [self.curXuser.arrSpotCheck removeAllObjects];
    NSMutableArray *operateArr = [NSMutableArray array];
    [operateArr addObjectsFromArray:arr];
    //  跟从checkme获取的数据合并
    if (self.localSPCListArr.count == 0) {  //如果本地没有数据
        [self.curXuser.arrSpotCheck setArray:arr];
    } else if(self.localSPCListArr.count != 0){ //如果本地有数据
        for (SpotCheckItem *localItem in self.localSPCListArr) {
            for (SpotCheckItem *spcItem in arr) {
                NSString *localStr = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME ,_curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][1]];
                NSString *dateStr = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME ,_curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][1]];
                if ([localStr isEqualToString:dateStr]) {
                    [operateArr removeObject:spcItem];
                }
            }
        }
        if (operateArr.count != 0) {
            [self.curXuser.arrSpotCheck addObjectsFromArray:operateArr];
        }
        [self.curXuser.arrSpotCheck addObjectsFromArray:self.localSPCListArr];
    }
}


//拿到本地DLC数据
- (void) loadLocalDLCList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_localDLCListArr) {
            [_localDLCListArr removeAllObjects];
        }else {
            _localDLCListArr = [NSMutableArray array];
        }
        NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_DLC_Data-", _curUser.medical_id] inDirectory:curDirName];
        NSLog(@"%@",[NSString stringWithFormat:@"%@_DLC_Data-", _curUser.medical_id]);
        if (fileArr) {
            for (NSString *fileName in fileArr) {
            
                if ([UserDefaults objectForKey:fileName] == nil) {
                    
                    NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                    NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                    DailyCheckItem *localDLCItem = [unAch decodeObjectForKey:fileName];
                    [_localDLCListArr addObject:localDLCItem];
                    
                }else{
                
                    NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                    NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                    DailyCheckItem *localDLCItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                    [_localDLCListArr addObject:localDLCItem];

                }
                
                 //////////
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDlc];
        });
    });
}

//加载dlc列表
-(void)loadDlc
{
    if(_curUser.arrDlc.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果当前用户的arrDLC数据并未初始化过
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) { //离线状态
            [self loadTheBPCheck];
        }else {  //非离线状态
            
            //加载Checkme端的数据
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrDlc removeAllObjects];
            NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_NAME,_curUser.ID];
            
            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                [self refreshView];
                
            }else{
                
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_DailyCheckList];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
                
            }
        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrDlc.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_DailyCheckList)){//如果正在下载别的用户数据
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
    }else{//已有数据
        DLog(@"有数据！");
        [self loadTheBPCheck];
    }
    
}

//加载bpcheck
-(void)loadTheBPCheck
{
    [_curUser.arrBPCheck removeAllObjects];
    if ([AppDelegate GetAppDelegate].isOffline) {  //离线
        NSData *data = [FileUtils readFile:BPCheck_FILE_NAME inDirectory:curDirName];
        if (data) {
            _curUser.arrBPCheck = [[FileParser parseBPCheck_WithFileData:data] mutableCopy];
        }
        [self refreshView];
    }else {  //非离线
        
        [BTCommunication sharedInstance].delegate = self;
        [_curUser.arrBPCheck removeAllObjects];
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:BPCheck_FILE_NAME fileType:FILE_Type_BPCheckList];
    }
}


#pragma mark - BTCommunication Delagate
- (void)postCurrentReadProgress:(double)progress
{
    return;
}
- (void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    
    if (isSpc) {
        /**
         *  if the data is SpotCheck list data
         */
        if (fileData.fileType == FILE_Type_SpotCheckList) {
            if(fileData.enLoadResult == kFileLoadResult_TimeOut)
            {
                [self refreshView];
            }else {
                NSArray *arr = [FileParser paserSpotCheckList_WithFileData:fileData.fileData];
                [_curXuser.arrSpotCheck setArray:arr];
                
                [self saveNoHR_DataToLocalPlace];
                [self refreshView];
            }
        }
        
    }else {
        /**
         *  if the data is Daily Check list data
         */
        if(fileData.fileType == FILE_Type_DailyCheckList)
        {
            if(fileData.enLoadResult == kFileLoadResult_TimeOut)
            {
                [self refreshView];
            }else {
                // 解析
                NSArray *arr = [FileParser parseDlcList_WithFileData:fileData.fileData];
                [_curUser.arrDlc setArray:arr];
                [self saveDLCListToLocalPlace];
                
                if(_curUser.arrBPCheck.count ==0)
                    
                    [self performSelector:@selector(loadTheBPCheck) withObject:nil afterDelay:0.3];
                
                else
                    [self refreshView];
            }
        }
        /**
         *  if the data is BPCheck list data
         */
        else if(fileData.fileType == FILE_Type_BPCheckList)
        {
            if(fileData.enLoadResult == kFileLoadResult_TimeOut)
            {
                [self refreshView];
            }else {
                NSArray *arr = [FileParser parseBPCheck_WithFileData:fileData.fileData];
                [_curUser.arrBPCheck setArray:arr];
                
                // 存储到本地 bpcal.dat
                [FileUtils saveFile:BPCheck_FILE_NAME FileData:fileData.fileData withDirectoryName:curDirName];
                
                [self refreshView];
            }
        }
    }
}
//把未下载详情的dailyCheck列表保存到本地
- (void) saveDLCListToLocalPlace
{
    NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_SAVE_NAME, _curUser.medical_id];
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:_curUser.arrDlc forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:curDirName];
}
//如果不包含HR数据，则直接保存到本地
- (void) saveNoHR_DataToLocalPlace
{
    for (SpotCheckItem *item in _curXuser.arrSpotCheck) {
        if (item.isNoHR) {   //如果不包含HR数据
            //  归档存储数据
            NSString *itemStr = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:item.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:item.dtcDate][1]];;
            NSMutableData *itemData = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
            [archiver encodeObject:item forKey:itemStr];
            [archiver finishEncoding];
            [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];    //存到指定文件夹
        }
    }
}

-(void)refreshView
{
    [self removeAllSubView];
    if (isSpc) {
        if (![AppDelegate GetAppDelegate].isOffline) { //程序是非离线状态
            // 合并数据
            [self combineLocalSPCListWithCheckmeSPCList];
        }
        [self getArrForDisplay];
        [LoadingViewUtils stopLoadingView:_indicatorView];
        if (self.curXuser.arrSpotCheck.count != 0) {
            [self initTableView];
        } else {
            //显示无内容画面
            [NoInfoViewUtils showNoInfoView:self];
        }
        if (![AppDelegate GetAppDelegate].isOffline) { //程序是非离线状态
            if([[FirstDownManger sharedManager].downedArray containsObject:[NSString stringWithFormat:@"%d",_curXuser.userID]]){
                
            }else{
                
                DownManager *manger = [DownManager sharedManager];
                manger.mdelegate = self;
                [manger loadToal];
                [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%d",_curXuser.userID]];
            }
        }
        
    } else {
        //合并数据
        [self combineLocalDLCListWithCheckmeDLCList];
        [self getArrForDisplay];
        [LoadingViewUtils stopLoadingView:_indicatorView];
        if (_curUser.arrDlc.count!=0) {
            [self addChartBaseView];
            [self addSegmentedControl];
            [self addChartView];
            [self addChartSwitchBn];
            [self initTableView];
        }else{
            [NoInfoViewUtils showNoInfoView:self];
        }
        
        if (![AppDelegate GetAppDelegate].isOffline && isUser) { //程序是非离线状态
            if([[FirstDownManger sharedManager].downedArray containsObject:[NSString stringWithFormat:@"%d",_curUser.ID]]){
                
            }else{
                
                DownManager *manger = [DownManager sharedManager];
                manger.mdelegate = self;
                [manger loadToal];
                [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%@",_curUser.medical_id]];
                
            }
        }
    }
    
    [self configNaviBar];
}

- (void)count:(int)total
{
    
    [LoadingViewUtils stopLoadingView:_indicatorView];
    
    if (total == 0) {
        
        
    }else{
        
        //SIAlertView的另一些用法！！！
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"New records ready to download from device. ", nil)];
        
        //添加按钮的同时   在block中给按钮添加相应的点击点击事件
        //  点击update按钮  执行对应点击事件
        //取消按钮
        [alertView addButtonWithTitle:DTLocalizedString(@"Later", nil)
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                                  // 点击取消 什么都不做
                                  [[CloudUpLodaManger sharedManager] noticeUpdata];
                              }];
        
        
        [alertView addButtonWithTitle:DTLocalizedString(@"Download", nil) type: SIAlertViewButtonTypeCancel  handler:^(SIAlertView *alertView) {
            
            LXDownView *alert = [[LXDownView alloc] initWithTitle:DTLocalizedString(@"Downing", nil) Btntitle:DTLocalizedString(@"Cancel", nil) inview:self.view];
            //                LXDownView *alert = [[LXDownView alloc] init];
            alert.delegate = self;
            alert.totalCount = total;
            [alert show];
            
        }];
        
        [alertView show];
        
    }
    
}

- (void)countFail
{
    
    
}

- (void)dismisLoad
{
    [self refreshData];
    [self refreshView];
    
}

//排序
-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    
    if (isSpc) {
        for (SpotCheckItem *spcItem in self.curXuser.arrSpotCheck) {
            NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:spcItem.dtcDate];
            NSString *dateStr = [NSString stringWithFormat:@"%@", date];
            [dict setObject:spcItem forKey:dateStr];
            [dateStrArr addObject:dateStr];
        }
        //排序
        [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
        
        for (int i =0 ; i < dateStrArr.count; i ++) {
            NSString *dateStr = dateStrArr[i];
            SpotCheckItem *spcItem = [dict objectForKey:dateStr];
            [displayArr addObject:spcItem];
        }
        
    } else {
        for (DailyCheckItem *dlcItem in _curUser.arrDlc) {
            NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dlcItem.dtcDate];
            NSString *dateStr = [NSString stringWithFormat:@"%@", date];
            [dict setObject:dlcItem forKey:dateStr];
            [dateStrArr addObject:dateStr];
        }
        //排序
        [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
      
        for (int i =0 ; i < dateStrArr.count; i ++) {
            NSString *dateStr = dateStrArr[i];
            DailyCheckItem *dlcItem = [dict objectForKey:dateStr];
            [displayArr addObject:dlcItem];
        }
    }
    
    _arrForDisplay = displayArr;
    
}

//离线状态下解析本地列表
- (NSArray *)parseLocalDLCList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_SAVE_NAME, _curUser.medical_id];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
        if ([UserDefaults objectForKey:fileName] == nil) {
            
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            dlcListArr = [unArch decodeObjectForKey:fileName];
        }else{
        
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            dlcListArr = [unArch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
        }
       
    }
    return dlcListArr;
}

//合并数据
- (void)combineLocalDLCListWithCheckmeDLCList
{
    NSMutableArray *arr;   //checkme端数据
    if ([AppDelegate GetAppDelegate].isOffline) {  //离线时
        arr = [[self parseLocalDLCList] mutableCopy];
    } else { //非离线时
        
        NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_NAME,_curUser.ID];
        
        if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
            
            arr = [[self parseLocalDLCList] mutableCopy];
            
        }else{
            
            arr = [_curUser.arrDlc mutableCopy];  //checkme端的数据
            
        }
    }
    [_curUser.arrDlc removeAllObjects];
    NSMutableArray *operateArr = [arr mutableCopy];
    //  跟从checkme获取的数据合并
    if (_localDLCListArr.count == 0) {  //如果本地没有数据
        [_curUser.arrDlc setArray:arr];
    } else if(_localDLCListArr.count != 0){ //如果本地有数据
        for (DailyCheckItem *localItem in _localDLCListArr) {
            for (DailyCheckItem *dlcItem in arr) {
                NSString *localStr = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][1]];
                NSString *dateStr = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][1]];
                if ([localStr isEqualToString:dateStr]) {
                    [operateArr removeObject:dlcItem];
                }
            }
        }
        if (operateArr.count != 0) {
            [_curUser.arrDlc addObjectsFromArray:operateArr];
        }
        [_curUser.arrDlc addObjectsFromArray:_localDLCListArr];
    }
}

#pragma mark - TableView
//初始化列表
-(void)initTableView
{
    if (_tableView) {
        [_tableView removeFromSuperview];
        _tableView = nil;
    }
    
    CGRect tableViewFrame;
    if (isSpc) {
        tableViewFrame = CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64);
    } else {
        tableViewFrame = CGRectMake(0, _chartBaseView.frame.origin.y+_chartBaseView.frame.size.height, CUR_SCREEN_W, CUR_SCREEN_H-(_chartBaseView.frame.origin.y+_chartBaseView.frame.size.height));
    }
    
    self.tableView = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:tableViewFrame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //列表头添加一条分割线
    UIImageView *tableViewHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 0.5)];
    [tableViewHeaderView setImage:[UIImage imageNamed:@"table_header_line.png"]];
    self.tableView.tableHeaderView = tableViewHeaderView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

/*************************当前图表相关***********************/
#pragma mark - ChartView
// 添加图表蓝色背景
-(void)addChartBaseView
{
    CGRect bound = CGRectMake(0, 64, CUR_SCREEN_W, 220+26);
    _chartBaseView = [[UIView alloc]initWithFrame:bound];
    [_chartBaseView setBackgroundColor:DEFAULT_BLUE];
    [self.view addSubview:_chartBaseView];
}

//添加趋势图
-(void)addChartView
{
    float chartOriginX = 3*2 + 30;//左边按钮的宽度
    CGRect bound=CGRectMake(0, 0, _chartBaseView.frame.size.width-chartOriginX, 220);
    
    //hr纵坐标为不定值（180或240)
#pragma mark - HR相关
    NSArray* hrChartList =[self getChartList:CHART_TYPE_HR];
    
    _hrWave = [[ChartWave alloc]initWithFrame:bound withChartList:hrChartList chartType:CHART_TYPE_HR];
    int hrMax,hrLines;
    hrMax = [self calHRWaveMaxVal:hrChartList originMax:210];
    hrLines = hrMax > 180 ? 8 : 6;
    [_hrWave initParams:hrMax min:30 lineNum:7 errNum:0];
    
#pragma mark - SPO2相关
    NSArray *spo2ChartList = [self getChartList:CHART_TYPE_SPO2];
    _spo2Wave = [[ChartWave alloc]initWithFrame:bound withChartList:spo2ChartList chartType:CHART_TYPE_SPO2];
    [_spo2Wave initParams:100 min:60 lineNum:5 errNum:0];
    
#pragma mark - BP相关
    _bpWave = [self makeBPWave:bound];
    
#pragma mark - RPP相关
    NSArray *piChartList = [self getChartList:CHART_TYPE_PI];
    _piWave = [[ChartWave alloc] initWithFrame:bound withChartList:piChartList chartType:CHART_TYPE_PI];
    [_piWave initParams:30000 min:3000 lineNum:10 errNum:0];
    
    
    NSMutableArray *chartArr = [NSMutableArray array];    //保存着三种视图(UIView *)
    if (_hrWave)
        [chartArr addObject:_hrWave];
    if(_spo2Wave)
        [chartArr addObject:_spo2Wave];
    if (_bpWave) {
        [chartArr addObject:_bpWave];
    }
    if (_piWave) {
        [chartArr addObject:_piWave];
    }
    //添加滚动视图
    [self setScrollview:chartArr];
}

//获取心率纵坐标的最大值
-(int)calHRWaveMaxVal:(NSArray*)inArr originMax:(int)originMax     //hrChartList
{
    double max=0,min=0;
    NSMutableArray *tempArr = [NSMutableArray array];
    for (ChartItem *item in inArr) {
        [tempArr addObject:@(item.val)];
    }
    [PublicMethods findMaxValWithoutErrVal:&max minVal:&min inArr:tempArr];
    if (max>originMax) {
        //如果列表中有超过180的心率，则坐标最大值为240
        return 240;
    }else{
        return originMax;
    }
}

//获取画图用的数据
-(NSArray*)getChartList:(int)chartType
{
    NSMutableArray* chartList = [[NSMutableArray alloc]init];
    for (int i=0; i<[_curUser arrDlc].count; i++) {
        ChartItem* chartItem = [[ChartItem alloc]init];    // Val, dtcDate
        DailyCheckItem* dlcItem = [[_curUser arrDlc] objectAtIndex:i];
        
        switch (chartType) {
            case CHART_TYPE_HR:
                [chartItem setVal:dlcItem.HR];
                break;
            case CHART_TYPE_SPO2:
                [chartItem setVal:dlcItem.SPO2];
                break;
            case CHART_TYPE_BP_RE:
                if (dlcItem.BP_Flag==0xFF || dlcItem.BP_Flag== 255 || dlcItem.BP_Flag== -1) {//如果是无效值,则插入0xFF
                    [chartItem setVal:0xFF];
                }else{
                    [chartItem setVal:dlcItem.BP];
                }
                break;
            case CHART_TYPE_BP_ABS:
                if (dlcItem.BP_Flag==0xFF || dlcItem.BP_Flag == 0 || dlcItem.BP_Flag== 255 || dlcItem.BP_Flag== -1) {//如果是无效值,则插入0xFF
                    [chartItem setVal:0];
                }else{
                    [chartItem setVal:dlcItem.BP];
                }
                break;
            case CHART_TYPE_PI:
                [chartItem setVal:dlcItem.RPP];
                break;
                
            default:
                break;
        }
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dlcItem.dtcDate];
        chartItem.dtcDate = date;
        [chartList addObject:chartItem];
    }
    return chartList;
}

-(ChartWave*)makeBPWave:(CGRect)bound
{
    ChartWave *bpWave;
    
    //确定chart类型
    for (BPCheckItem *item in _curUser.arrBPCheck) {
        if (item.userID == _curUser.ID) {//有校准(re或abs)
            if (item.rPresure==0||item.cPresure==0) {//re
                bpWave = [[ChartWave alloc]initWithFrame:bound withChartList:[self getChartList:CHART_TYPE_BP_RE]chartType:CHART_TYPE_BP_RE];
                [bpWave initParams:60 min:-60 lineNum:5 errNum:0xFF];
            }else{//abs
                bpWave = [[ChartWave alloc]initWithFrame:bound withChartList:[self getChartList:CHART_TYPE_BP_ABS]chartType:CHART_TYPE_BP_ABS];
                [bpWave initParams:200 min:60 lineNum:8 errNum:0];
            }
        }
    }
    if (bpWave==nil) {
        //空Bp也画(显示no data)
        bpWave = [[ChartWave alloc]initWithFrame:bound withChartList:nil chartType:CHART_TYPE_BP_NONE];
    }
    return bpWave;
}

//设置滚动视图
-(void)setScrollview:(NSMutableArray*)uiViewArr
{
    float chartOriginX = 3*2 + 30;//左边按钮的宽度
    
    CGRect bound=CGRectMake(chartOriginX, 26, _chartBaseView.frame.size.width-chartOriginX, 220);
    _chartScrollView = [[HDScrollview alloc]initWithFrame:bound withUIView:uiViewArr];
    DLog(@"scrollview is %p", _chartScrollView);
    _chartScrollView.delegate=self;
    _chartScrollView.HDdelegate=self;
    [_chartScrollView setAlpha:1];
    [_chartScrollView setOpaque:YES];
    [_chartScrollView setScrollEnabled:NO];//禁止滑动
    
    //添加滚动视图
    [_chartBaseView addSubview:_chartScrollView];
    _chartScrollView.pagecontrol.frame=CGRectMake(0, _chartScrollView.pagecontrol.frame.origin.y+_chartScrollView.frame.size.height+45, CUR_SCREEN_W, 10);
    _chartScrollView.pagecontrol.currentcolor=LIGHT_BLUE;
    _chartScrollView.pagecontrol.othercolor=LIGHT_GREY;
    _chartScrollView.pagecontrol.currentPage=0;
}

//顶部日月年切换
-(void)addSegmentedControl
{
    float segWith = 230;
    CGRect bound = CGRectMake(_chartBaseView.frame.size.width/2-segWith/2 + 4, 8, segWith, 26);
    NSArray* arr = [[NSArray alloc]initWithObjects:DTLocalizedString(@"Day", nil),DTLocalizedString(@"Week", nil),DTLocalizedString(@"Month", nil),DTLocalizedString(@"Year", nil), nil];
    UISegmentedControl* segment = [[UISegmentedControl alloc]initWithItems:arr];
    segment.selectedSegmentIndex = 1;
    [segment setFrame:bound];
    [segment setTintColor:[MyColor colorWithHexString:@"fd7c41"]];
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [_chartBaseView addSubview:segment];
}

//添加趋势图种类切换button
-(void)addChartSwitchBn
{
    float marginX = 3.0;
    float originY = 26;//segment高度
    float chartViewH = _chartScrollView.frame.size.height;
    float bnSize = 30;
    CGRect bound = CGRectMake(marginX, chartViewH/4/2-bnSize/2+originY, bnSize, bnSize);
    _hrBn = [[UIButton alloc]initWithFrame:bound];
    [_hrBn setImage:[UIImage imageNamed:@"ljhr_l.png"] forState:UIControlStateNormal];
    [_hrBn setImage:[UIImage imageNamed:@"ljhr_l_press.png"] forState:UIControlStateSelected];
    [_hrBn addTarget:self action:@selector(hrBnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_hrBn setSelected:YES];//默认第一个选中
    [_chartBaseView addSubview:_hrBn];
    
    bound = CGRectMake(marginX, chartViewH/4+chartViewH/4/2-bnSize/2+originY, bnSize, bnSize);
    _spo2Bn = [[UIButton alloc]initWithFrame:bound];
    [_spo2Bn setImage:[UIImage imageNamed:@"ljspo2_l.png"] forState:UIControlStateNormal];
    [_spo2Bn setImage:[UIImage imageNamed:@"ljspo2_l_press.png"] forState:UIControlStateSelected];
    [_spo2Bn addTarget:self action:@selector(spo2BnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_chartBaseView addSubview:_spo2Bn];
    
    bound = CGRectMake(marginX, 2*chartViewH/4+chartViewH/4/2-bnSize/2+originY, bnSize, bnSize);
    _bpBn = [[UIButton alloc]initWithFrame:bound];
    [_bpBn setImage:[UIImage imageNamed:@"ljbp.png"] forState:UIControlStateNormal];
    [_bpBn setImage:[UIImage imageNamed:@"ljbp_press.png"] forState:UIControlStateSelected];
    [_bpBn addTarget:self action:@selector(bpBnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_chartBaseView addSubview:_bpBn];
    
    bound = CGRectMake(marginX, 3*chartViewH/4+chartViewH/4/2-bnSize/2+originY, bnSize, bnSize);
    _piBn = [[UIButton alloc]initWithFrame:bound];
    [_piBn setImage:[UIImage imageNamed:@"ljpi.png"] forState:UIControlStateNormal];
    [_piBn setImage:[UIImage imageNamed:@"ljpi_press.png"] forState:UIControlStateSelected];
    [_piBn addTarget:self action:@selector(piBnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_chartBaseView addSubview:_piBn];
}

/**************************************************************/




#pragma mark - IBAction Listener

//Left menu
- (IBAction)showLeftMenu:(id)sender
{
    if(![[BTCommunication sharedInstance] bLoadingFileNow])
    {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
    }
    
}



//点击segmentControl 的index
- (IBAction)segmentChanged:(id)sender
{
    //全部同步
    [_hrWave switchScale:[sender selectedSegmentIndex]];
    [_spo2Wave switchScale:[sender selectedSegmentIndex]];
    [_bpWave switchScale:[sender selectedSegmentIndex]];
    [_piWave switchScale:[sender selectedSegmentIndex]];
}

- (IBAction)hrBnClicked:(id)sender
{
    [_hrBn setSelected:YES];
    [_spo2Bn setSelected:NO];
    [_bpBn setSelected:NO];
    [_piBn setSelected:NO];
    [_chartScrollView setCurrentPageIndex:1];
    _chartScrollView.pagecontrol.currentPage=0;
    [_chartScrollView pageTurn:_chartScrollView.pagecontrol];
}

- (IBAction)spo2BnClicked:(id)sender
{
    [_hrBn setSelected:NO];
    [_spo2Bn setSelected:YES];
    [_bpBn setSelected:NO];
    [_piBn setSelected:NO];
    [_chartScrollView setCurrentPageIndex:2];
    _chartScrollView.pagecontrol.currentPage=1;
    [_chartScrollView pageTurn:_chartScrollView.pagecontrol];
}

- (IBAction)bpBnClicked:(id)sender
{
    [_hrBn setSelected:NO];
    [_spo2Bn setSelected:NO];
    [_bpBn setSelected:YES];
    [_piBn setSelected:NO];
    [_chartScrollView setCurrentPageIndex:3];
    _chartScrollView.pagecontrol.currentPage=2;
    [_chartScrollView pageTurn:_chartScrollView.pagecontrol];
}

- (void) piBnClicked:(id)sender
{
    [_hrBn setSelected:NO];
    [_spo2Bn setSelected:NO];
    [_bpBn setSelected:NO];
    [_piBn setSelected:YES];
    [_chartScrollView setCurrentPageIndex:4];
    _chartScrollView.pagecontrol.currentPage = 3;
    [_chartScrollView pageTurn:_chartScrollView.pagecontrol];
}




#pragma mark - TableViewDelegate&DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isSpc) {
        
        SpotCheckItem *spcItem = [_arrForDisplay objectAtIndex:indexPath.row];
        SpotCheckCell *spcCell = (SpotCheckCell *)[tableView cellForRowAtIndexPath:indexPath];
        //已经下载详情
        if (spcItem.innerData || spcItem.isNoHR) {   //如果没有测量心率 或者有心率且心率数据已下载
            DailyCheckDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"dailyCheckDetailViewController"];
            [detailVC setCurXuser:_curXuser andCurSpcItem:spcItem];
            [self.navigationController pushViewController:detailVC animated:YES];
        } else {  //未下载详情，先下载
            if ([AppDelegate GetAppDelegate].isOffline) {
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
            } else {
                if(![[BTCommunication sharedInstance] bLoadingFileNow])
                {
                    [spcCell downloadDetail];  //下载cell详情
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
                }
            }
        }
        
    }else {
        
        DailyCheckItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
        DailyCheckCell *cell = (DailyCheckCell*)[tableView cellForRowAtIndexPath:indexPath];
        //已经下载详情
        if(item.innerData){
            DailyCheckDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dailyCheckDetailViewController"];
            [detailViewController setCurUser:_curUser  andCurItem:item];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }else {  //未下载详情，先下载
            if ([AppDelegate GetAppDelegate].isOffline) {
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
            }else{
                if(![[BTCommunication sharedInstance] bLoadingFileNow])
                {
                    [cell downloadDetail];  //下载cell详情
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
                }
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSpc) {
        return self.curXuser.arrSpotCheck.count;
    }else {
        return _arrForDisplay.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSpc) {
        static NSString *Identifier = @"spcCell";
        SpotCheckCell *spctCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (!spctCell) {
            spctCell = [[SpotCheckCell alloc] init];
        }
        SpotCheckItem *spcItem = [self.arrForDisplay objectAtIndex:indexPath.row];
        [spctCell setPropertyWithUser:self.curXuser infoItem:spcItem fatherViewController:self];
        
        DLog(@"*****   %@",NSStringFromCGRect(spctCell.frame));
        
        
        return spctCell;
        
    }else {
        static NSString *identifier = @"cellReuseId_DailyCheckCell";
        DailyCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[DailyCheckCell alloc]init];
        }
        DailyCheckItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
        [cell setPropertyWithUser:_curUser infoItem:item fatherViewController:self];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (isSpc) {
            
            SpotCheckItem *spcItem = _arrForDisplay[indexPath.row];
            [_arrForDisplay removeObject:spcItem];
            [_curXuser.arrSpotCheck removeObject:spcItem];
            //删除本地已下载数据
            NSString *fileName = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][1]];
            [FileUtils deleteFile:fileName inDirectory:curDirName];
            
         
            
            
            //删除录音数据
            NSString *voiceName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:spcItem.dtcDate][1]];
            if ([FileUtils isFileExist:voiceName inDirectory:curDirName]) {
                [FileUtils deleteFile:voiceName inDirectory:curDirName];
            }
            //重新加载视图
            [self refreshData];
        } else {
            
            DailyCheckItem *dlcItem = _arrForDisplay[indexPath.row];
            [_arrForDisplay removeObject:dlcItem];
            [_curUser.arrDlc removeObject:dlcItem];
            //删除本地已下载数据
            NSString *fileName = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][1]];
            [FileUtils deleteFile:fileName inDirectory:curDirName];
            //删除本地%ddlc.dat列表中对应的数据
            [self deleteDlcListDataWith:dlcItem];
            //删除录音数据
            
            if([[FirstDownManger sharedManager].downedArray containsObject:[NSString stringWithFormat:@"%@%@",fileName,curDirName]]){
                [[FirstDownManger sharedManager].downedArray removeObject:[NSString stringWithFormat:@"%@%@",fileName,curDirName]];
            }
            
            NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where detedStr = '%@%@'",fileName,curDirName]];
            if (array.count == 0) {
                
            }else{
                
                for (CloudModel *model in array) {
                    [model deleteObject];
                }
                
            }
            NSString *voiceName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][1]];
            if ([FileUtils isFileExist:voiceName inDirectory:curDirName]) {
                [FileUtils deleteFile:voiceName inDirectory:curDirName];
            }
            //重新加载视图
            [self refreshData];
        }
    }
}

//删除本地%ddlc.dat列表中对应的数据
- (void) deleteDlcListDataWith:(DailyCheckItem *)dlcItem
{
    //获取要删除的item的时间数据
    NSDate *deleteDate = [[NSCalendar currentCalendar] dateFromComponents:dlcItem.dtcDate];
    NSString *deleteDateStr = [NSString stringWithFormat:@"%@", deleteDate];
    //拿到上一次保存的dlcList列表
    NSMutableArray *originalDlcListArr = [[self parseLocalDLCList] mutableCopy];
    NSMutableArray *newDlcListArr = [originalDlcListArr mutableCopy];
    for (DailyCheckItem *originalItem in originalDlcListArr) {
        //获取列表中item的时间数据
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:originalItem.dtcDate];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        if ([dateStr isEqualToString:deleteDateStr]) {  //删除此项
            [newDlcListArr removeObject:originalItem];
        }
    }
    
    //把经过删除处理后的dlcList列表以相同名称再次保存到本地  以覆盖之前的数据
    NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_SAVE_NAME, _curUser.medical_id];
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:newDlcListArr forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:curDirName];
}

- (void)refreshData
{
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex andCurXuserIndex:curXuserIndex];
}

#pragma mark - HDviewScroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    [_chartScrollView HDscrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    [_chartScrollView HDscrollViewDidEndDecelerating];
}
-(void)TapView:(int)index
{
    
}
@end
