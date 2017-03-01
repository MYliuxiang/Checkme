//
//  TempViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "TempViewController.h"
#import "BTCommunication.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "TempCell.h"
#import "LoadingViewUtils.h"
#import "NoInfoViewUtils.h"
#import "FileUtils.h"
#import "FileParser.h"

#import "MobClick.h"
@interface TempViewController () <BTCommunicationDelegate>

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) NSMutableArray* arrForDisplay;
@property (nonatomic,retain) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, strong) NSMutableArray *localTempItems;
@end

@implementation TempViewController
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
    [MobClick beginLogPageView:@"TempPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"TempPage"];
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
    [self addRightBtn];//添加右侧按钮

    [self getCurDIRName];
    [self loadPreference];
    [self switchUser:curUserIndex];
//    [self loadLocalTempList];
    [self loadTempList];
    
//    //隐藏右侧栏按钮
//    for (id obj in self.navigationController.navigationBar.subviews) {
//        if ([obj isMemberOfClass:[UIButton class]]) {
//            UIButton *btn = obj;
//            [btn setHidden:YES];
//        }
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickUserListNtf:) name:NtfName_ClickUserList object:nil];

}

-(void)loadPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
}

- (void) getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;


}

- (void)onClickUserListNtf:(NSNotification *)ntf
{
    curUserIndex = (int)[ntf.object integerValue];
    [self removeAllSubView];
    self.indicatorView = [LoadingViewUtils initLoadingView:self];
    [self switchUser:curUserIndex];
    [self loadTempList];
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
        [self loadLocalTempList];
        
    }else{
        
        isUser = YES;
        
        _curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        [_curUser.arrRelaxMe removeAllObjects];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:curUserIndex forKey:@"LastUser"];
        [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
        
        [self loadLocalTempList];
    }
}

-(void)removeAllSubView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
}


- (void) loadLocalTempList
{
       [_curUser.arrTemp removeAllObjects];
    
    if (_localTempItems) {
        
        [_localTempItems removeAllObjects];
        
    }else {
        
        _localTempItems = [NSMutableArray array];
        
    }
    
    NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@TEMP_Data-", _curUser.medical_id] inDirectory:curDirName];
   
    if (fileArr) {
        
        for (NSString *fileName in fileArr) {
            
            if ([UserDefaults objectForKey:fileName] == nil) {
                
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                TempInfoItem *localTempItem = [unAch decodeObjectForKey:fileName];
                [_localTempItems addObject:localTempItem];    //////////
            }else{
            
                NSData *itemData = [FileUtils readFile:fileName inDirectory:curDirName];
                NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
                TempInfoItem *localTempItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
                [_localTempItems addObject:localTempItem];    //////////
            
            }
           
        }
    }
}

-(void)loadTempList
{
    if(_curUser.arrTemp.count <= 0 && ![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有数据
        
        if ([AppDelegate GetAppDelegate].isOffline || !isUser) {
            _curUser.arrTemp = [_localTempItems mutableCopy];
            [self refreshView];
        } else {
            
            [BTCommunication sharedInstance].delegate = self;
            [_curUser.arrTemp removeAllObjects];
            
            NSString *fileName = [NSString stringWithFormat:TEMP_FILE_NAME,_curUser.ID];
            
            if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
                
                _curUser.arrTemp = [_localTempItems mutableCopy];
                [self refreshView];
                
            }else{
                
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_TempList];
                [[FirstDownManger sharedManager].downedArray addObject:fileName];
                
            }

        }
        
    }else if([[BTCommunication sharedInstance] bLoadingFileNow] &&
             _curUser.arrTemp.count <= 0 &&
             ([BTCommunication sharedInstance].curReadFile.fileType != FILE_Type_TempList)){//如果正在下载别的用户数据
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
    [BTCommunication sharedInstance].delegate = nil;

    /**
     *  if the data is Thermometer list data
     */
    if(fileData.fileType == FILE_Type_TempList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self refreshView];
        }
        else
        {
            NSArray *arr = [FileParser parseTempList_WithFileData:fileData.fileData];
            [_curUser.arrTemp setArray:arr];
            [self saveTempListToLocalPlace];
            [self refreshView];
        }
    }
}
- (void) saveTempListToLocalPlace
{
    for (TempInfoItem *tempItem in _curUser.arrTemp) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:TEMP_DATA_USER_TIME_FILE_SAVE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:tempItem.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:tempItem.dtcMeasureTime][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:tempItem forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_periphralName];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
        NSLog(@"%@",curUser.name);
        NSLog(@"%d",curUser.ID);
        NSLog(@"%f",curUser.weight);
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,tempItem.dtcMeasureTime.year,(long)tempItem.dtcMeasureTime.month,tempItem.dtcMeasureTime.day,tempItem.dtcMeasureTime.hour,tempItem.dtcMeasureTime.minute,tempItem.dtcMeasureTime.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",tempItem.dtcMeasureTime.year,(long)tempItem.dtcMeasureTime.month,tempItem.dtcMeasureTime.day,tempItem.dtcMeasureTime.hour,tempItem.dtcMeasureTime.minute,tempItem.dtcMeasureTime.second];
        
        NSString *state;
        NSString *state1;
        if (tempItem.enPassKind == 0) {
            state = @"H";
            state1 = @"normal";
        }else{
            state = @"L";
            state1 = @"low";
        }
                
        double F = tempItem.PTT_Value *1.8 + 32 - 0.04;
        
        if (tempItem.PTT_Value == 0) {
            F = 0;
        }
        NSString *fstr = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(tempItem.PTT_Value);
        
        NSString *jsonstr;
        
        if (tempItem.measureMode == TEMP_MODE_HEAD) {
            
            jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Body temperature\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"vital-signs\",\"display\":\"Vital Signs\"}},\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8310-5\",\"display\":\"Body temperature\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"--\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8310-5\",\"display\":\"Body temperature\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"℃\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"deg C\"}}]}",str1,time,state,state1,fstr];
            
        }else if (tempItem.measureMode == TEMP_MODE_THING) {
            
            jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Object temperature\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"vital-signs\",\"display\":\"Vital Signs\"}},\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160502-9\",\"display\":\"Object temperature\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"--\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160502-9\",\"display\":\"Object temperature\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"℃\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"deg C\"}}]}",str1,time,state,state1,fstr];
        }
        

        
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
            }
        }
        
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
    _tempTable = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(0, 64, CUR_SCREEN_W, CUR_SCREEN_H-64)];
    _tempTable.dataSource = self;
    _tempTable.delegate = self;
    [self.view addSubview:_tempTable];
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
    if (![AppDelegate GetAppDelegate].isOffline) {
        [_curUser.arrTemp removeAllObjects];
        // 再次拿本地数据
        [self loadLocalTempList];
        _curUser.arrTemp = [_localTempItems mutableCopy];
    }
    
    [LoadingViewUtils stopLoadingView:_indicatorView];
    if (_curUser.arrTemp.count!=0) {
        [self initTableView];
        _tempTable.hidden = NO;
        [self getArrForDisplay];
        [_tempTable reloadData];
    }else{
        _tempTable.hidden = YES;
        [NoInfoViewUtils showNoInfoView:self];
    }
}

-(void)getArrForDisplay
{
    NSMutableArray *displayArr = [NSMutableArray array];  //分组后的item
    NSMutableArray *dateStrArr = [NSMutableArray array];  //item对应的时间
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];  // 装 item和它所对应的时间 组成的字典
    for (TempInfoItem *tempItem in _curUser.arrTemp) {
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:tempItem.dtcMeasureTime];
        NSString *dateStr = [NSString stringWithFormat:@"%@", date];
        [dict setObject:tempItem forKey:dateStr];
        [dateStrArr addObject:dateStr];
    }
    //排序
    [dateStrArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (int i =0 ; i < dateStrArr.count; i ++) {
        NSString *dateStr = dateStrArr[i];
        TempInfoItem *tempItem = [dict objectForKey:dateStr];
        [displayArr addObject:tempItem];
    }
    _arrForDisplay = displayArr;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _curUser.arrTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TempCell *cell = [tableView dequeueReusableCellWithIdentifier:[TempCell cellReuseId]];
    if(!cell){
        cell = [[TempCell alloc] init];
    }
    TempInfoItem *item = [_arrForDisplay objectAtIndex:indexPath.row];
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
        TempInfoItem *tempItem = _arrForDisplay[indexPath.row];
        [_arrForDisplay removeObject:tempItem];
        [_curUser.arrTemp removeObject:tempItem];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //删除本地数据
        NSString *fileName = [NSString stringWithFormat:TEMP_DATA_USER_TIME_FILE_SAVE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:tempItem.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:tempItem.dtcMeasureTime][1]];
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
    
    //加载本地ECGList数据
    [self loadLocalTempList];
    [self loadTempList];
}

- (void) removeAllSubviews
{
    for (id obj in self.view.subviews) {
        [obj removeFromSuperview];
    }
}
@end
