//
//  SLMViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SLMViewController.h"
#import "BTCommunication.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "SLMCell.h"
#import "LoadingViewUtils.h"
#import "SLMDetailViewController.h"
#import "NoInfoViewUtils.h"
#import "SVProgressHUD.h"
#import "FileUtils.h"
#import "FileParser.h"

#import "MobClick.h"
@interface SLMViewController () <BTCommunicationDelegate>

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;

@property (nonatomic, strong) NSMutableArray *localSLMListArr;

@end

@implementation SLMViewController
{
    NSString *curDirName;
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
    [MobClick beginLogPageView:@"SLMPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"SLMPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBasicalData];
}

- (void) loadBasicalData
{
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    
    [self getCurDIRName];
    //加载本地slmList数据
    [self loadLocalSLMList];
        
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = DTLocalizedString(@"Back", nil);
    self.navigationItem.backBarButtonItem = backItem;
    
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
}

- (void) getCurDIRName
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
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >8888888888");
}

// 拿到本地的SLM数据
- (void) loadLocalSLMList
{
    if ([UserList instance].isSpotCheck) {
        _curUser = [[User alloc] init];
    }else {
        _curUser = [[UserList instance].arrUserList objectAtIndex:0];
    }
    [_curUser.arrSLM removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_localSLMListArr) {
            [_localSLMListArr removeAllObjects];
        }else {
            _localSLMListArr = [NSMutableArray array];
        }
        NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:@"SLM_Data-" inDirectory:curDirName];
        if (fileArr) {
            for (NSString *fileName in fileArr) {
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                SLMItem *localECGItem = [unAch decodeObjectForKey:fileName];
                [_localSLMListArr addObject:localECGItem];    //////////
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadSLMList];
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    _slmTable = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64)];
    _slmTable.dataSource = self;
    _slmTable.delegate = self;
    [self.view addSubview:_slmTable];
}

-(void)loadSLMList
{
    if(_curUser.arrSLM.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有数据
        
        if ([AppDelegate GetAppDelegate].isOffline) {
            if (_localSLMListArr.count != 0) {
                [_curUser.arrSLM addObjectsFromArray:_localSLMListArr];
            }
            [self refreshView];
        } else {
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrSLM removeAllObjects];
            [[BTCommunication sharedInstance] BeginReadFileWithFileName:SLM_LIST_FILE_NAME fileType:FILE_Type_SleepMonitorList];
        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrSLM.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_SleepMonitorList)){//如果正在下载别的用户数据
        //提示错误
    }else{//已有数据
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
    /**
     *  if the data is Sleep Monitor list data
     */
    if(fileData.fileType == FILE_Type_SleepMonitorList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }
        else
        {
            NSArray *arr = [FileParser parseSLMList_WithFileData:fileData.fileData];
            [_curUser.arrSLM setArray:arr];
            [self refreshView];
        }
        
    }
}


-(void)refreshView
{
    if (![AppDelegate GetAppDelegate].isOffline) { //程序是非离线状态
        // 合并数据
        [self combineLocalSLMListWithCeeckmeSLMList];
    }
    
    [LoadingViewUtils stopLoadingView:_indicatorView];
    if (_curUser.arrSLM.count!=0) {
        [self initTableView];
        _slmTable.hidden = NO;
        [self getArrForDisplay];
        [_slmTable reloadData];
    }else{
        _slmTable.hidden = YES;
        [NoInfoViewUtils showNoInfoView:self];
    }
}

- (void)combineLocalSLMListWithCeeckmeSLMList
{
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    [arr addObjectsFromArray:_curUser.arrSLM];
    [_curUser.arrSLM removeAllObjects];
    NSMutableArray *operateArr = [NSMutableArray array];
    [operateArr addObjectsFromArray:arr];
    //  跟从checkme获取的数据合并
    if (_localSLMListArr.count == 0) {  //如果本地没有数据
        [_curUser.arrSLM setArray:arr];
    } else if(_localSLMListArr.count != 0){ //如果本地有数据
        for (SLMItem *localItem in _localSLMListArr) {
            for (SLMItem *checkmeItem in arr) {
                NSString *localStr = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:localItem.dtcStartDate][1]];
                NSString *dateStr = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:checkmeItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:checkmeItem.dtcStartDate][1]];
                if ([localStr isEqualToString:dateStr]) {
                    [operateArr removeObject:checkmeItem];
                }
            }
        }
        [_curUser.arrSLM setArray:_localSLMListArr];
        if (operateArr.count != 0) {
            [_curUser.arrSLM addObjectsFromArray:operateArr];
        }
    }
}

-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    for (SLMItem *slmItem in _curUser.arrSLM) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:slmItem.dtcStartDate];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:slmItem forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        SLMItem *slmItem = [dict objectForKey:dateStr];
        [displayArr addObject:slmItem];
    }
    _arrForDisplay = displayArr;
}


//Left menu
- (IBAction)showLeftMenu:(id)sender;
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

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SLMItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
    SLMCell *cell = (SLMCell*)[tableView cellForRowAtIndexPath:indexPath];
    //已经下载详情
    if(item.innerData){
        SLMDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"slmDetailViewController"];
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
    return _curUser.arrSLM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLMCell *cell = [tableView dequeueReusableCellWithIdentifier:[SLMCell cellReuseId]];
    if(!cell){
        cell = [[SLMCell alloc] init];
    }
    SLMItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
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
        SLMItem *slmItem = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:slmItem];
        [_curUser.arrSLM removeObject:slmItem];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:slmItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:slmItem.dtcStartDate][1]];
        [FileUtils deleteFile:fileName inDirectory:curDirName];
        //刷新列表
        [self refreshData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}
- (void)refreshData
{
    [self removeAllSubviews];
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    
    //加载本地ECGList数据
    [self loadLocalSLMList];
}

- (void) removeAllSubviews
{
    for (id obj in self.view.subviews) {
        [obj removeFromSuperview];
    }
}

@end
