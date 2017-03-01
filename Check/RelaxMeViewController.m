//
//  RelaxMeViewController.m
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "RelaxMeViewController.h"
#import "BTCommunication.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "RelaxMeCell.h"
#import "LoadingViewUtils.h"
#import "SLMDetailViewController.h"
#import "NoInfoViewUtils.h"
#import "SVProgressHUD.h"
#import "FileUtils.h"
#import "FileParser.h"

#import "MobClick.h"
#import "CBAutoScrollLabel.h"
#import "HDScrollview.h"
#import "ChartWave.h"
#import "Colors.h"
@interface RelaxMeViewController ()<BTCommunicationDelegate,UIScrollViewDelegate,HDScrollviewDelegate>

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, strong) NSMutableArray *localRelaxmeItem;
@property (nonatomic,retain) UIView* chartBaseView;//趋势图，各按钮的容器
@property (nonatomic,retain) HDScrollview *chartScrollView;
@property (nonatomic,retain) ChartWave* RelaxactionWave;
@end

@implementation RelaxMeViewController
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
    [MobClick beginLogPageView:@"RelaxMePage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"RelaxMePage"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBasicalData];
}

- (void)loadBasicalData
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

- (void)getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

}

- (void)loadLocalPedList
{
    if (_localRelaxmeItem) {
        [_localRelaxmeItem removeAllObjects];
    }else {
        _localRelaxmeItem = [NSMutableArray array];
    }
//    [_curUser.arrRelaxMe removeAllObjects];
    
    NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_RELAXME_Data-", _curUser.medical_id] inDirectory:curDirName];
    if (fileArr) {
        for (NSString *fileName in fileArr) {
            
            if ([UserDefaults objectForKey:fileName] == nil) {
                
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                RelaxMeItem *localRelaxMeItem = [unAch decodeObjectForKey:fileName];
                [_localRelaxmeItem addObject:localRelaxMeItem];    //////////
            }else{
                
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                RelaxMeItem *localRelaxMeItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                [_localRelaxmeItem addObject:localRelaxMeItem];    //////////
                
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
        
        //            u = dlcListArr[userIndex];
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
    if(_curUser.arrRelaxMe.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){//如果没有数据
        
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) {
            _curUser.arrRelaxMe = [_localRelaxmeItem mutableCopy];
            [self refreshView];
        } else {
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrRelaxMe removeAllObjects];
            NSString* fileName = [NSString stringWithFormat:RELAXME_FILE_NAME,_curUser.ID];
            [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SleepMonitorList];
            
            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                [BTCommunication sharedInstance].delegate = nil;
                [self refreshView];
                
            }else{
                
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SleepMonitorList];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
                
            }

        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrRelaxMe.count <= 0 &&
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
     *  if the data is Pedometer list data
     */
    if(fileData.fileType == FILE_Type_SleepMonitorList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }else{
            
            NSArray *arr = [FileParser parseRelaxMeList_WithFileData:fileData.fileData];
            [_curUser.arrRelaxMe setArray:arr];
            [self savePedListToLocalPlace];
            [self refreshView];
        }
    }
}

- (void) savePedListToLocalPlace
{
    for (RelaxMeItem *Item in _curUser.arrRelaxMe) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:RELAXME_DATA_USER_TIME_FILE_SAVE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:Item.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:Item.dtcDate][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:Item forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_periphralName];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        NSLog(@"%@",curUser.name);
        NSLog(@"%d",curUser.ID);
        NSLog(@"%f",curUser.weight);
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,Item.dtcDate.year,(long)Item.dtcDate.month,Item.dtcDate.day,Item.dtcDate.hour,Item.dtcDate.minute,Item.dtcDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",Item.dtcDate.year,(long)Item.dtcDate.month,Item.dtcDate.day,Item.dtcDate.hour,Item.dtcDate.minute,Item.dtcMeasureTime.second];
        NSString *hrv =  INT_TO_STRING_WITHOUT_ERR_NUM(Item.hrv);

        NSString *jsonstr;
        
        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Relax me\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"vital-signs\",\"display\":\"Vital Signs\"}},\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160402\",\"display\":\"Relax me\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"N\",\"display\":\"Normal\"},\"text\":\"--\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-14\",\"display\":\"Relaxation index\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\": {\"coding\":{\"system\": \"https://cloud.viatomtech.com/fhir\",\"code\": \"170114-3\",\"display\": \"HRV(RMSSD)\"}},\"valueQuantity\": {\"value\": \"%@\",\"unit\": \"ms\",\"system\": \"http://unitsofmeasure.org\",\"code\": \"ms\"}},{\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160501-14\",\"display\":\"Duration\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"s\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"s\"}}]}",str1,time,INT_TO_STRING_WITHOUT_ERR_NUM(Item.Relaxation),hrv,INT_TO_STRING_WITHOUT_ERR_NUM(Item.timemiao)];
        
        CloudModel *model = [[CloudModel alloc] init];
        model.macID =_curUser.medical_id;
        model.sn = sn;
        model.weight = curUser.weight;
        model.name = curUser.name;
        if (curUser.gender == kGender_FeMale) {
            
            model.sex = 0;
            
        }else{
            
            model.sex = 1;
        }
        model.birthDate = [NSString stringWithFormat:@"%.2ld-%.2ld-%.2ld",curUser.dtcBirthday.year,curUser.dtcBirthday.month,curUser.dtcBirthday.day];
        model.height = curUser.height;
        model.ISUpload = @"0";
        model.time = time;
        model.jsonStr = jsonstr;
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,curDirName];
        
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            
            if(_curUser.ID != 1){
                [model save];
            }
        }
        [[CloudUpLodaManger sharedManager] noticeUpdata];
    }
}


-(void)configNaviBar
{
    //导航栏头像
    UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"me"]];
    
    [_rightBtn setBackgroundImage:img forState:UIControlStateNormal];
    /**添加滚动label*/
    if (sl) {
        [sl removeFromSuperview];
        sl = nil;
    }
    self.navigationItem.title = nil;
    NSString *titleStr = [NSString stringWithFormat:DTLocalizedString(@"Relax Me - %@", nil),_curUser.name];
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
    CGRect tableViewFrame = CGRectMake(0, _chartBaseView.frame.origin.y+_chartBaseView.frame.size.height, CUR_SCREEN_W, CUR_SCREEN_H-(_chartBaseView.frame.origin.y+_chartBaseView.frame.size.height));
    
    _relaxmeTable = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:tableViewFrame];
    _relaxmeTable.dataSource = self;
    _relaxmeTable.delegate = self;
    [self.view addSubview:_relaxmeTable];
    
    //列表头添加一条分割线
    UIImageView *tableViewHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CUR_SCREEN_W, 0.5)];
    [tableViewHeaderView setImage:[UIImage imageNamed:@"table_header_line.png"]];
    _relaxmeTable.tableHeaderView = tableViewHeaderView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_relaxmeTable reloadData];
}



-(void)refreshView
{
    if (![AppDelegate GetAppDelegate].isOffline) {
        // 再次拿到本地数据
        [_curUser.arrRelaxMe removeAllObjects];
        [self loadLocalPedList];
        _curUser.arrRelaxMe = [_localRelaxmeItem mutableCopy];
    }
    
    [LoadingViewUtils stopLoadingView:_indicatorView];
    if (_curUser.arrRelaxMe.count!=0) {
       
        [self getArrForDisplay];
        [self addChartBaseView];
        [self addSegmentedControl];
        [self addChartView];
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
    for (RelaxMeItem *relaxmeItem in _curUser.arrRelaxMe) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:relaxmeItem.dtcDate];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:relaxmeItem forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        RelaxMeItem *relaxmeItem = [dict objectForKey:dateStr];
        [displayArr addObject:relaxmeItem];
    }
    _arrForDisplay = displayArr;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _curUser.arrRelaxMe.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RelaxMeCell *cell = [tableView dequeueReusableCellWithIdentifier:[RelaxMeCell cellReuseId]];
    if(!cell){
        cell = [[RelaxMeCell alloc] init];
    }
    RelaxMeItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
    [cell setPropertyWithUser:_curUser infoItem:item fatherViewController:self];
    return cell;


}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        RelaxMeItem *relaxmeItem = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:relaxmeItem];
        [_curUser.arrRelaxMe removeObject:relaxmeItem];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:RELAXME_DATA_USER_TIME_FILE_SAVE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:relaxmeItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:relaxmeItem.dtcDate][1]];
        [FileUtils deleteFile:fileName inDirectory:curDirName];
        
        
//        3_RELAXME_Data-2:17:17 PM- 1-Jan-2016
//        3_RELAXME_Data-9:58:01 AM- 7-Jan-2016
//        3_RELAXME_Data-9:58:01 AM- 7-Jan-2016
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where detedStr = '%@%@'",fileName,curDirName]];
        if (array.count == 0) {
            
        }else{
            
            for (CloudModel *model in array) {
                [model deleteObject];
            }
            
        }

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
    float chartOriginX = 3*2 ;
    CGRect bound=CGRectMake(0, 0, _chartBaseView.frame.size.width-chartOriginX, 220);
    
    //hr纵坐标为不定值（100)
#pragma mark - Relaxaction
    NSArray* RelaxactionList =[self getChartList:CHART_TYPE_Relaxaction];
    
    _RelaxactionWave = [[ChartWave alloc]initWithFrame:bound withChartList:RelaxactionList chartType:CHART_TYPE_Relaxaction];

    [_RelaxactionWave initParams:100 min:0 lineNum:6 errNum:0];
    

    NSMutableArray *chartArr = [NSMutableArray array];    //保存着三种视图(UIView *)
    
    [chartArr addObject:_RelaxactionWave];
    
    //添加滚动视图
    [self setScrollview:chartArr];
}

//获取画图用的数据
-(NSArray*)getChartList:(int)chartType
{
    NSMutableArray* chartList = [[NSMutableArray alloc]init];
    for (int i=0; i<[_curUser arrRelaxMe].count; i++) {
        ChartItem* chartItem = [[ChartItem alloc]init];    // Val, dtcDate
        RelaxMeItem* dlcItem = [[_curUser arrRelaxMe] objectAtIndex:i];
        
        switch (chartType) {
            case CHART_TYPE_Relaxaction:
//                if (dlcItem.Relaxation < 0 || dlcItem.Relaxation > 100 ) {//如果是无效值,则插入0xFF
//                    [chartItem setVal:0xFF];
//                }else{
//                    [chartItem setVal:dlcItem.Relaxation];
//                }
                    [chartItem setVal:dlcItem.Relaxation];
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

//设置滚动视图
-(void)setScrollview:(NSMutableArray*)uiViewArr
{
    float chartOriginX = 3*2;//左边按钮的宽度
    
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
//点击segmentControl 的index
- (void)segmentChanged:(id)sender
{
    //全部同步
    [_RelaxactionWave switchScale:[sender selectedSegmentIndex]];
   
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
