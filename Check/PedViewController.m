//
//  PedViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "PedViewController.h"
#import "BTCommunication.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "PedCell.h"
#import "LoadingViewUtils.h"
#import "NoInfoViewUtils.h"
#import "Colors.h"
#import "FileParser.h"

#import "FileUtils.h"
#import "MobClick.h"
#import "CBAutoScrollLabel.h"

@interface PedViewController () <BTCommunicationDelegate>
@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, strong) NSMutableArray *localPedItems;
@end

@implementation PedViewController
{
    NSString *curDirName;
    CBAutoScrollLabel *sl;
    BOOL isUser;
}
static int curUserIndex = 0;

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
    [MobClick beginLogPageView:@"PedPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"PedPage"];
}
- (void) dealloc
{
    if (sl) {
        [sl removeFromSuperview];
        sl = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBasicalData];
}

- (void) loadBasicalData
{
    [self removeAllSubView];
    _indicatorView = [LoadingViewUtils initLoadingView:self];
     [self addRightBtn];
    [self getCurDIRName];
    [self loadPreference];
    [self switchUser:curUserIndex];
    [self loadPedList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickUserListNtf:) name:NtfName_ClickUserList object:nil];
    
    //删除原来显示右侧栏的按钮
//    for (id obj in self.navigationController.navigationBar.subviews) {
//        if ([obj isMemberOfClass:[UIButton class]]) {
//            UIButton *btn = obj;
//            [btn removeFromSuperview];
//        }
//    }
   
}

- (void) getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

}

- (void) loadLocalPedList
{
    if (_localPedItems) {
        [_localPedItems removeAllObjects];
    }else {
        _localPedItems = [NSMutableArray array];
    }
    NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_PED_Data-", _curUser.medical_id] inDirectory:curDirName];
    if (fileArr) {
        for (NSString *fileName in fileArr) {
            if ([UserDefaults objectForKey:fileName] == nil) {
                
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                PedInfoItem *localPedItem = [unAch decodeObjectForKey:fileName];
                [_localPedItems addObject:localPedItem];    //////////
            }else{
            
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                PedInfoItem *localPedItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                [_localPedItems addObject:localPedItem];
            
            }
           
        }
    }
}

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
    curUserIndex = (int)[ntf.object integerValue];
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex];
    [self loadPedList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
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
        if ([FileUtils isFileExist:fileName inDirectory:_periphralName]) {
            
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:_periphralName];
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
        
        [_curUser.arrDlc removeAllObjects];
        
        [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
        [self loadLocalPedList];
        
    }else{
        
        isUser = YES;
        
        _curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        [_curUser.arrRelaxMe removeAllObjects];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
        [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
        [self loadLocalPedList];
    }

}

-(void)loadPedList
{
    if(_curUser.arrPed.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){//如果没有数据
        
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) {
            _curUser.arrPed = [_localPedItems mutableCopy];
            [self refreshView];
        } else {
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrPed removeAllObjects];
            NSString* fileName = [NSString stringWithFormat:PED_FILE_NAME,_curUser.ID];
            [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_PedList];
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrPed removeAllObjects];
            
            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                _curUser.arrPed = [_localPedItems mutableCopy];
                [self refreshView];
                
            }else{
                
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_PedList];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
                
            }

        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrPed.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_PedList)){//如果正在下载别的用户数据
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
     *  if the data is Pedometer list data
     */
    if(fileData.fileType == FILE_Type_PedList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }
        else
        {
            NSArray *arr = [FileParser parsePedList_WithFileData:fileData.fileData];
            [_curUser.arrPed setArray:arr];
            
            [self savePedListToLocalPlace];
            [self refreshView];
        }
    }
}

- (void) savePedListToLocalPlace
{
    for (PedInfoItem *pedItem in _curUser.arrPed) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:PED_DATA_USER_TIME_FILE_SAVE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:pedItem.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:pedItem.dtcMeasureTime][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:pedItem forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_periphralName];
    }
}


-(void)configNaviBar
{
    //导航栏头像
   
    UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"ljico%@",INT_TO_STRING(_curUser.ICO_ID)]];
    img = [UIImage imageNamed:[NSString stringWithFormat:@"me.png"]];
    [_rightBtn setImage:img forState:UIControlStateNormal];
    
    /**添加滚动label*/
    if (sl) {
        [sl removeFromSuperview];
        sl = nil;
    }
    self.navigationItem.title = nil;
    NSString *titleStr = [NSString stringWithFormat:DTLocalizedString(@"Pedometer - %@", nil),_curUser.name];
    sl = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake((CUR_SCREEN_W - 150)*0.5, 0, 150, 40)];
    sl.text = titleStr;
    sl.pauseInterval = 0.0f;
    sl.font = [UIFont boldSystemFontOfSize:17];
    sl.textColor = [UIColor blackColor];
    sl.textAlignment = NSTextAlignmentCenter;
    sl.fadeLength = 3.0f;
    [sl observeApplicationNotifications];
    self.navigationItem.titleView = sl;
}

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

-(void)initTableView
{
    _pedTable = [[HVTableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64) expandOnlyOneCell:YES enableAutoScroll:YES];
    _pedTable.HVTableViewDelegate = self;
    _pedTable.HVTableViewDataSource = self;
    [_pedTable reloadData];
    [self.view addSubview:_pedTable];
}



-(void)refreshView
{
    if (![AppDelegate GetAppDelegate].isOffline) {
        // 再次拿到本地数据
        [_curUser.arrPed removeAllObjects];
        [self loadLocalPedList];
        _curUser.arrPed = [_localPedItems mutableCopy];
    }
    
    [LoadingViewUtils stopLoadingView:_indicatorView];
    if (_curUser.arrPed.count!=0) {
        [self getArrForDisplay];
        [self initTableView];
    }else{
        [NoInfoViewUtils showNoInfoView:self];
    }
    [self configNaviBar];
}

-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    for (PedInfoItem *pedItem in _curUser.arrPed) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:pedItem.dtcMeasureTime];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:pedItem forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        PedInfoItem *pedItem = [dict objectForKey:dateStr];
        [displayArr addObject:pedItem];
    }
    _arrForDisplay = displayArr;
}

//HVTableView protrocal
-(void)tableView:(UITableView *)tableView expandCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    [((PedCell*)cell) doOnExpanded];
    [UIView animateWithDuration:.5 animations:^{
        ((PedCell*)cell).imgDown.transform = CGAffineTransformMakeRotation(3.14);
    }];
}

-(void)tableView:(UITableView *)tableView collapseCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    [((PedCell*)cell) doOnCollapsed];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _curUser.arrPed.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isexpanded
{
    if (isexpanded)
        return 150;
    else
        return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded
{
    PedCell *cell = [tableView dequeueReusableCellWithIdentifier:[PedCell cellReuseId]];
    if(!cell){
        cell = [[PedCell alloc] init];
    }
    PedInfoItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
    [cell setPropertyWithUser:_curUser infoItem:item fatherViewController:self];
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PedInfoItem *pedItem = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:pedItem];
        [_curUser.arrPed removeObject:pedItem];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:PED_DATA_USER_TIME_FILE_SAVE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:pedItem.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:pedItem.dtcMeasureTime][1]];
        [FileUtils deleteFile:fileName inDirectory:curDirName];
        
        //重新加载视图
        [self refreshData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}
- (void)refreshData
{
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex];
    [self loadPedList];
}

-(void)removeAllSubView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
}

@end
