//
//  SPO2ViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SPO2ViewController.h"
#import "BTCommunication.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "SPO2Cell.h"
#import "LoadingViewUtils.h"
#import "NoInfoViewUtils.h"
#import "FileUtils.h"
#import "FileParser.h"

#import "MobClick.h"
@interface SPO2ViewController () <BTCommunicationDelegate>

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, strong) NSMutableArray *localSpo2Items;
@end

@implementation SPO2ViewController
{
    NSString *curDirName;
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
    [MobClick beginLogPageView:@"spo2Page"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"spo2Page"];
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



- (void)showRightMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void) loadBasicalData
{
    _indicatorView = [LoadingViewUtils initLoadingView:self];
    [self addRightBtn];

    [self getCurDIRName];
    [self loadPreference];
    [self switchUser:curUserIndex];
    [self loadSPO2List];
//    //隐藏右侧栏按钮
//    for (id obj in self.navigationController.navigationBar.subviews) {
//        if ([obj isMemberOfClass:[UIButton class]]) {
//            UIButton *btn = obj;
//            [btn setHidden:YES];
//        }
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickUserListNtf:) name:NtfName_ClickUserList object:nil];

}

- (void) getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

}

- (void)onClickUserListNtf:(NSNotification *)ntf
{
    curUserIndex = (int)[ntf.object integerValue];
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex];
    [self loadSPO2List];
}


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
        [self loadLocalSpo2List];

    }else{
        
        isUser = YES;

    _curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
    [_curUser.arrRelaxMe removeAllObjects];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
    [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
    
    [self loadLocalSpo2List];
    }
}

-(void)loadPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
}

-(void)removeAllSubView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
}

// 拿到本地的spo2数据
- (void) loadLocalSpo2List
{
//    if ([UserList instance].isSpotCheck) {
//        _curUser = [[User alloc] init];
//    }else {
//        _curUser = [[UserList instance].arrUserList objectAtIndex:0];
//    }
    [_curUser.arrSPO2 removeAllObjects];
    
    if (_localSpo2Items) {
        [_localSpo2Items removeAllObjects];
    }else {
        _localSpo2Items = [NSMutableArray array];
    }
   
    NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@SPO2_Data-",_curUser.medical_id] inDirectory:curDirName];
    NSLog(@"%@",[NSString stringWithFormat:@"%@SPO2_Data-",_curUser.medical_id]);
    if (fileArr) {
        for (NSString *fileName in fileArr) {
            
            if ([UserDefaults objectForKey:fileName] == nil) {

            NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
            NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
            SPO2InfoItem *localSpo2Item = [unAch decodeObjectForKey:fileName];
            [_localSpo2Items addObject:localSpo2Item];    //////////
            }else{
            
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                SPO2InfoItem *localSpo2Item = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                [_localSpo2Items addObject:localSpo2Item];
            }
        }
    }
}


-(void)loadSPO2List
{
    if(_curUser.arrSPO2.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有数据
        
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) {
            _curUser.arrSPO2 = [_localSpo2Items mutableCopy];
            [self refreshView];
        } else {
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrSPO2 removeAllObjects];
            NSString *fileName = [NSString stringWithFormat:SPO2_FILE_NAME,_curUser.ID];

            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                _curUser.arrSPO2 = [_localSpo2Items mutableCopy];
                [self refreshView];
                
                
            }else{
            
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SPO2List];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
                
            }

        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrSPO2.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_SPO2List)){//如果正在下载别的用户数据
        //提示错误
    }else{//已有数据
        [self refreshView];  //刷新 重新加载 这个view视图
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

    /**
     *  if the data is spo2 list data
     */
    if(fileData.fileType == FILE_Type_SPO2List)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }
        else
        {
            NSArray *arr = [FileParser parseSPO2List_WithFileData:fileData.fileData];
            [_curUser.arrSPO2 setArray:arr];
            
            [self saveSpo2ListToLocalPlace];
            [self refreshView];
        }
    }
}

- (void) saveSpo2ListToLocalPlace
{
    for (SPO2InfoItem *spo2Item in _curUser.arrSPO2) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:SPO2_DATA_USER_TIME_FILE_SAVE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:spo2Item forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_periphralName];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        NSLog(@"%@",curUser.name);
        NSLog(@"%d",curUser.ID);
        NSLog(@"%f",curUser.weight);
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,spo2Item.dtcMeasureTime.year,(long)spo2Item.dtcMeasureTime.month,spo2Item.dtcMeasureTime.day,spo2Item.dtcMeasureTime.hour,spo2Item.dtcMeasureTime.minute,spo2Item.dtcMeasureTime.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",spo2Item.dtcMeasureTime.year,(long)spo2Item.dtcMeasureTime.month,spo2Item.dtcMeasureTime.day,spo2Item.dtcMeasureTime.hour,spo2Item.dtcMeasureTime.minute,spo2Item.dtcMeasureTime.second];
        
        NSString *state;
        NSString *state1;
        if (spo2Item.enPassKind == 0) {
            state = @"H";
            state1 = @"normal";
        }else{
            state = @"L";
            state1 = @"low";
        }
        
        int spoValue = [[NSString stringWithFormat:@"%d",spo2Item.SPO2_Value] intValue];
        NSString *spo2StrResult;
        if (spoValue == 0) {
            spo2StrResult = DTLocalizedString(@"Unable to Analyze", nil);
        }
        
        else if( 0 < spoValue && spoValue < 60)
        {
            spo2StrResult = DTLocalizedString(@"Unable to Analyze", nil);
            
        }
        else if( 60 <= spoValue && spoValue <= 93)
        {
            spo2StrResult = @"Blood oxygen: Out of range";
            
        }
        else {
            
            spo2StrResult = @"Blood oxygen: Within range";
        }
        
        
        NSString *jsonstr;
        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"SpO2\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"vital-signs\",\"display\":\"Vital Signs\"}},\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"20564-1\",\"display\":\"Oxygen saturation in Blood\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"%@\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"20564-1\",\"display\":\"Oxygen saturation in Blood\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8889-8\",\"display\":\"Heart rate by Pulse oximetry\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"/min\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"/min\"}}]}",str1,time,state,state1,spo2StrResult,INT_TO_STRING_WITHOUT_ERR_NUM(spo2Item.SPO2_Value),INT_TO_STRING_WITHOUT_ERR_NUM(spo2Item.PR)];
        
        CloudModel *model = [[CloudModel alloc] init];
        model.macID = curUser.medical_id;
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
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,_periphralName];
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            if(_curUser.ID != 1){
                [model save];
            }        }
        [[CloudUpLodaManger sharedManager] noticeUpdata];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    _spo2Table = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64)];
    _spo2Table.dataSource = self;
    _spo2Table.delegate = self;
    [self.view addSubview:_spo2Table];
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


-(void)refreshView
{
    if (![AppDelegate GetAppDelegate].isOffline) {  //非离线状态时
        [_curUser.arrSPO2 removeAllObjects];
        // 再次拿本地数据
        [self loadLocalSpo2List];
        _curUser.arrSPO2 = [_localSpo2Items mutableCopy];
    }
    [LoadingViewUtils stopLoadingView:_indicatorView];
    
    
    if (_curUser.arrSPO2.count!=0) {
        [self initTableView];
        _spo2Table.hidden = NO;
        [self getArrForDisplay];
        [_spo2Table reloadData];
    }else{
        _spo2Table.hidden = YES;
        [NoInfoViewUtils showNoInfoView:self];
    }
}

-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    for (SPO2InfoItem *spo2Item in _curUser.arrSPO2) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:spo2Item.dtcMeasureTime];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:spo2Item forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        SPO2InfoItem *spo2Item = [dict objectForKey:dateStr];
        [displayArr addObject:spo2Item];
    }
    _arrForDisplay = displayArr;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _curUser.arrSPO2.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPO2Cell *cell = [tableView dequeueReusableCellWithIdentifier:[SPO2Cell cellReuseId]];
    if(!cell){
        cell = [[SPO2Cell alloc] init];
    }
    SPO2InfoItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
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
        SPO2InfoItem *spo2Item = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:spo2Item];
        [_curUser.arrSPO2 removeObject:spo2Item];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:SPO2_DATA_USER_TIME_FILE_SAVE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][1]];
        [FileUtils deleteFile:fileName inDirectory:curDirName];
        
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where detedStr = '%@%@'",fileName,curDirName]];
        if (array.count == 0) {
            
        }else{
            
            for (CloudModel *model in array) {
                [model deleteObject];
            }
            
        }
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
    
    //加载本地spo2List数据
    [self loadLocalSpo2List];    
    [self loadSPO2List];
}

- (void) removeAllSubviews
{
    for (id obj in self.view.subviews) {
        [obj removeFromSuperview];
    }
}
@end
