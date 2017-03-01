//
//  ECGViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ECGViewController.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "ECGCell.h"
#import "UserList.h"
#import "ECGDetailViewController.h"
#import "LoadingViewUtils.h"
#import "NoInfoViewUtils.h"
#import "SVProgressHUD.h"
#import "FileUtils.h"
#import "MobClick.h"
#import "CBAutoScrollLabel.h"
#import "BTCommunication.h"
#import "FileParser.h"

@interface ECGViewController () <BTCommunicationDelegate>
@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@property (nonatomic, strong) NSMutableArray *localECGListArr;
@end

@implementation ECGViewController
{
    NSString *curDirName;
    NSString *lastCheckmeName;
    
    BOOL isUser;


}

static int curUserIndex = 0;

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"ECGPage"];
    //刷新录音图标
    [_ecgTable reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"ECGPage"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self unHideRightButton];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBasicalData];
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

-(void)removeAllSubView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
}

- (void)loadBasicalData
{
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    
    [self getCurDIRName];
    //加载本地ECGList数据
    [self createDirectoryInDocuments];
    [self loadPreference];
//    [self loadLocalECGList];
    [self addRightBtn];//添加右侧按钮
    [self switchUser:curUserIndex];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = DTLocalizedString(@"Back", nil);//返回按钮(back)
    self.navigationItem.backBarButtonItem = backItem;//后退返回按钮
    
//    //隐藏右侧栏按钮
//    for (id obj in self.navigationController.navigationBar.subviews) {
//        if ([obj isMemberOfClass:[UIButton class]]) {
//            UIButton *btn = obj;
//            [btn setHidden:YES];
//        }
//    }
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickUserListNtf:) name:NtfName_ClickUserList object:nil];
}

- (void)showRightMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)onClickUserListNtf:(NSNotification *)ntf
{
    curUserIndex = (int)[ntf.object integerValue];
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex];
    [self loadECGList];
}

/**
 *  切换用户
 *
 *  @param userIndex 用户index
 */
-(void)switchUser:(int)userIndex
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    //如果已经主机删除了用户
    if (userIndex>=[[UserList instance].arrUserList count]) {

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
        
        //            u = dlcListArr[userIndex];
        [_curUser.arrDlc removeAllObjects];
        
        [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
        [self loadLocalECGList];

    }else{
        
        isUser = YES;

    _curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
    [_curUser.arrECG removeAllObjects];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
    [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
    [self loadLocalECGList];
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
    //    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >6666666666");
}

//打开存档，查看上次使用的用户
-(void)loadPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
    [userDefaults synchronize];
}

//离线状态下解析本地列表
- (NSArray *)parseLocalECGList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_SAVE_NAME, _curUser.medical_id];
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



// 拿到本地的ECG数据
- (void) loadLocalECGList
{
//    if ([UserList instance].isSpotCheck) {
//        _curUser = [[User alloc] init];
//    }else {
//        _curUser = [[UserList instance].arrUserList objectAtIndex:0];
//    }
    [_curUser.arrECG removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_localECGListArr) {
            [_localECGListArr removeAllObjects];
        } else {
            _localECGListArr = [NSMutableArray array];
        }
        
         NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@ECG_Data-", _curUser.medical_id] inDirectory:curDirName];
        
//        1409101062_2_ECG_Data-4:58:37 PM- 9-Feb-2016
//        NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:@"ECG_Data-" inDirectory:curDirName];
        if (fileArr) {
            for (NSString *fileName in fileArr) {
                
                if ([UserDefaults objectForKey:fileName] == nil) {

                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                ECGInfoItem *localECGItem = [unAch decodeObjectForKey:fileName];
                [_localECGListArr addObject:localECGItem];    //////////
                }else{
                
                    NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                    NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                    ECGInfoItem *localECGItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                    [_localECGListArr addObject:localECGItem];
                    
                
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadECGList];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Left menu
-(IBAction)showLeftMenu:(id)sender
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

//下载ECG列表
-(void)loadECGList
{
    if(_curUser.arrECG.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有数据
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) { //如果程序是离线状态
            if (_localECGListArr.count != 0) {
                [_curUser.arrECG addObjectsFromArray:_localECGListArr];
            }
            [self refreshView];
            
        } else { //程序是非离线状态
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrECG removeAllObjects];
            //蓝牙入口  通过蓝牙获取数据
            NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_NAME,_curUser.ID];
//            [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_EcgList];
            
            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                
                if (_localECGListArr.count != 0) {
                    
                    [_curUser.arrECG addObjectsFromArray:_localECGListArr];
                    
                }
                [self refreshView];
                
            }else{
                
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_EcgList];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
            }

        }
        
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrECG.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_EcgList)){
        //如果正在下载别的用户数据
        //提示错误
    }else{//已有数据
        DLog(@"//已有数据");
        [self refreshView];
    }
}

#pragma mark - BTCommunication Delagate
- (void)postCurrentReadProgress:(double)progress
{
    return;
}
- (void)readCompleteWithData:(FileToRead *)fileData
{
    
    
    NSLog(@"下载了ECG");
    [BTCommunication sharedInstance].delegate = nil;
    
    /**
     *  if the data is ECG list data
     */
    if(fileData.fileType == FILE_Type_EcgList)   // 0x03
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }
        else
        {
            //解析ECG数据
            NSArray *arr = [FileParser parseEcgList_WithFileData:fileData.fileData];
            [_curUser.arrECG setArray:arr];
            [self saveECGListToLocalPlace];

            [self refreshView];
        }
    }
}

- (void)saveECGListToLocalPlace
{
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_SAVE_NAME,_curUser.medical_id];
    NSMutableData *ecglistData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:ecglistData];
    [archiver encodeObject:_curUser.arrECG forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:ecglistData withDirectoryName:curDirName];
    
}



//初始化TableView
-(void)initTableView
{
    _ecgTable = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64)];
    _ecgTable.dataSource = self;
    _ecgTable.delegate = self;
    [self.view addSubview:_ecgTable];
}

//刷新界面
//无论下载列表成功失败都调用
-(void)refreshView
{
    if (![AppDelegate GetAppDelegate].isOffline ) { //程序是非离线状态
        // 合并数据
        [self combineLocalECGListWithCeeckmeECGList];
    }
    [self combineLocalECGListWithCeeckmeECGList];

    //活动指示器
    [LoadingViewUtils stopLoadingView:_indicatorView];
    
    if(_curUser.arrECG.count!=0){ //如果有数据
        [self initTableView];
        _ecgTable.hidden = NO;
        [self getArrForDisplay];
        [_ecgTable reloadData];
        
    }else{
        _ecgTable.hidden = YES;
        
        //显示无内容画面
        [NoInfoViewUtils showNoInfoView:self];
    }
}
- (void)combineLocalECGListWithCeeckmeECGList
{
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据

    if ([AppDelegate GetAppDelegate].isOffline || !isUser) {  //离线时
        arr = [[self parseLocalECGList] mutableCopy];
    } else { //非离线时
        
        NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_NAME,_curUser.ID];

        if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
            
            arr = [[self parseLocalECGList] mutableCopy];
            
        }else{
            
            arr = [_curUser.arrECG mutableCopy];  //checkme端的数据
            
        }
    }
    
    [_curUser.arrECG removeAllObjects];
    NSMutableArray *checkmeEcgs = [NSMutableArray array];
    [checkmeEcgs addObjectsFromArray:arr];
    //  跟从checkme获取的数据合并
    if (_localECGListArr.count == 0) {  //如果本地没有数据
        [_curUser.arrECG setArray:arr];
    } else if(_localECGListArr.count != 0){ //如果本地有数据
        for (ECGInfoItem *localItem in _localECGListArr) {
            for (ECGInfoItem *ecgItem in arr) {
                NSString *localStr = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcDate][1]];
                NSString *dateStr = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][1]];
                if ([localStr isEqualToString:dateStr]) {
                    [checkmeEcgs removeObject:ecgItem];
                }
            }
        }
        if (checkmeEcgs.count != 0) {
            [_curUser.arrECG addObjectsFromArray:checkmeEcgs];
        }
        [_curUser.arrECG addObjectsFromArray:_localECGListArr];
    }
}

//获取时间倒序列表，用于显示
-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    for (ECGInfoItem *ecgItem in _curUser.arrECG) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:ecgItem.dtcDate];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:ecgItem forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        ECGInfoItem *ecgItem = [dict objectForKey:dateStr];
        [displayArr addObject:ecgItem];
    }
    _arrForDisplay = displayArr;
    
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECGCell *cell = (ECGCell*)[tableView cellForRowAtIndexPath:indexPath];
    ECGInfoItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
    //已经下载详情
    if(item.innerData){
        ECGDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ecgDetailViewController"];
        [detailViewController setCurUser:_curUser  andCurItem:item];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    //未下载详情，先下载
    else{
        if ([AppDelegate GetAppDelegate].isOffline) {
            [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
        }else{
            if(![[BTCommunication sharedInstance] bLoadingFileNow])
            {
                [cell downloadDetail];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
            }
            
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrForDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECGCell *cell = [tableView dequeueReusableCellWithIdentifier:[ECGCell cellReuseId]];
    if(!cell){
        cell = [[ECGCell alloc] init];
    }
    ECGInfoItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
    [cell setPropertyWithUser:_curUser infoItem:item fatherViewController:self];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ECGInfoItem *ecgItem = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:ecgItem];
        [_curUser.arrECG removeObject:ecgItem];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][1]];
        [FileUtils deleteFile:fileName inDirectory:curDirName];
        
        [self deleteECGListDataWith:ecgItem];

        
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
        
        //删除录音数据
        NSString *voiceName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id,[NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][1]];
        if ([FileUtils isFileExist:voiceName inDirectory:curDirName]) {
            [FileUtils deleteFile:voiceName inDirectory:curDirName];
        }
        
        //刷新列表
        [self refreshData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

//删除本地%ddlc.dat列表中对应的数据
- (void) deleteECGListDataWith:(ECGInfoItem *)ecgItem
{
    //获取要删除的item的时间数据
    NSDate *deleteDate = [[NSCalendar currentCalendar] dateFromComponents:ecgItem.dtcDate];
    NSString *deleteDateStr = [NSString stringWithFormat:@"%@", deleteDate];
    //拿到上一次保存的dlcList列表
    NSMutableArray *originalDlcListArr = [[self parseLocalECGList] mutableCopy];
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
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_SAVE_NAME, _curUser.medical_id];
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:newDlcListArr forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:curDirName];
}

- (void)refreshData
{
    [self removeAllSubviews];
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    
    [self switchUser:curUserIndex];

    //加载本地ECGList数据
//    [self loadLocalECGList];
}

- (void) removeAllSubviews
{
    for (id obj in self.view.subviews) {
        [obj removeFromSuperview];
    }
}

@end
