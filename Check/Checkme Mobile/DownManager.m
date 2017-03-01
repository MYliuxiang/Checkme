//
//  DownView.m
//  Checkme Mobile
//
//  Created by Viatom on 16/7/29.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "DownManager.h"

@implementation DownManager

+ (DownManager *)sharedManager
{
    static DownManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        sharedAccountManagerInstance = [[self alloc] init];
        
    });
    
    return sharedAccountManagerInstance;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isSpc = [UserList instance].isSpotCheck ? YES : NO;
        self.uIndex = 0;
        [self getCurDIRName];
    }
    return self;
}

- (void)getCurDIRName
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
}


- (void)loadToal
{
    [self totalCount];

}

- (void)totalCount
{
    //获取ecg需要下载的个数
    dlcint = 0;
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"];
//        self.userCount = [UserList instance].arrUserList.count;
    if([UserList instance].arrUserList.count - 1 < self.uIndex){
       
        self.uIndex = 0;
        [self endClout];
        return;
    }
        self.userList = [UserList instance];
        _curUser = nil;
        _curUser = [self.userList.arrUserList objectAtIndex:self.uIndex];
        
        if ([AppDelegate GetAppDelegate].isOffline) { //如果程序是离线状态
            
            
        }else{
            
            [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%d",_curUser.ID]];
            //加载check
            [self loadCheck];
            
        }

}


- (void)loadSpot
{
    [BTCommunication sharedInstance].delegate = self;
    [_curXuser.arrSpotCheck removeAllObjects];
    
    NSString *fileName = [NSString stringWithFormat:SPC_LIST_FILE_NAME, _curXuser.userID];
    
    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        
        [self spotCount];
        
    }else{
        
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SpotCheckList];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
        
    }
    
}

- (void)loadCheck
{
    
    //加载Checkme端的数据
    [BTCommunication sharedInstance].delegate = self;
    [_curUser.arrDlc removeAllObjects];
    NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_NAME,_curUser.ID];
    
    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        
        [self dlcCount];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_DailyCheckList];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
        
    }

}

- (void)loadECG
{
    
    [BTCommunication sharedInstance].delegate = self;
    //蓝牙入口  通过蓝牙获取数据
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_NAME,_curUser.ID];

    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        
        [self ecgCount];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_EcgList];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
    }
}


- (void)loadSLM
{
    
    [BTCommunication sharedInstance].delegate = self;
    [_curUser.arrSLM removeAllObjects];
    
    if([[FirstDownManger sharedManager].downedArray containsObject:SLM_LIST_FILE_NAME]){
        
        [self slmCount];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:SLM_LIST_FILE_NAME fileType:FILE_Type_SleepMonitorList];
        [[FirstDownManger sharedManager].downedArray addObject:SLM_LIST_FILE_NAME];
        
    }

}

- (void)loadSpo2
{
    [BTCommunication sharedInstance].delegate = self;
    [_curUser.arrSPO2 removeAllObjects];
    
    NSString *fileName = [NSString stringWithFormat:SPO2_FILE_NAME,_curUser.ID];

    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        [self loadTemp];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SPO2List];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
    }
}

- (void)loadTemp
{
    [BTCommunication sharedInstance].delegate = self;
    [_curUser.arrTemp removeAllObjects];
    NSString *fileName = [NSString stringWithFormat:TEMP_FILE_NAME,_curUser.ID];

    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        
        [self loadRelax];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_TempList];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
        
    }

}

- (void)loadRelax
{

    [BTCommunication sharedInstance].delegate = self;
    [_curUser.arrRelaxMe removeAllObjects];
    NSString* fileName = [NSString stringWithFormat:RELAXME_FILE_NAME,_curUser.ID];
    
    if([[FirstDownManger sharedManager].downedArray containsObject:fileName]){
        
        self.uIndex++;
        [self totalCount];
        
    }else{
        
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_RealaxList];
        [[FirstDownManger sharedManager].downedArray addObject:fileName];
        
    }

}


- (void)spotCount
{
    
    //获取本地ecg.dat
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    arr = [[self parseLocalSPCList] mutableCopy];
    [_curXuser.arrSpotCheck removeAllObjects];
    [_curXuser.arrSpotCheck setArray:arr];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<_curXuser.arrSpotCheck.count; i++) {
        
        SpotCheckItem *spocItem = _curXuser.arrSpotCheck[i];
        //读取本地文件
        //  读取本地文件
        //读取本地文件
        NSString *fileName = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME ,_curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:spocItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:spocItem.dtcDate][1]];
        if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
            
            
            
        }else{
            
            [array addObject:spocItem];
            
        }
    }
    
    [_curXuser.arrSpotCheck removeAllObjects];
    [_curXuser.arrSpotCheck setArray:array];

    [self loadECG];

}

- (void)dlcCount
{
    
    //获取本地ecg.dat
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    arr = [[self parseLocalDLCList] mutableCopy];
    [_curUser.arrDlc removeAllObjects];
    [_curUser.arrDlc setArray:arr];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<_curUser.arrDlc.count; i++) {
        
        DailyCheckItem *dlcItem = _curUser.arrDlc[i];
        //读取本地文件
        //  读取本地文件
        NSString *fileName = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][1]];
        if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
            
            if (dlcItem.bHaveVoiceMemo) {
                
                NSString *fileName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:dlcItem.dtcDate][1]];
                NSData *fileData = [FileUtils readFile:fileName inDirectory:curDirName];
                dlcItem.dataVoice = [fileData mutableCopy];
                if(!dlcItem.dataVoice){
                
                    [array addObject:dlcItem];
                }
            }
        }else{
        
            [array addObject:dlcItem];

        }
    }
    
    [_curUser.arrDlc removeAllObjects];
    [_curUser.arrDlc setArray:array];
    [self loadECG];

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

//离线状态下解析本地列表
- (NSArray *)parseLocalDLCList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_SAVE_NAME, _curUser.medical_id];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
        
        if ([UserDefaults objectForKey:fileName]) {
            
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            dlcListArr = [unArch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
            
        }else{
            
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            dlcListArr = [unArch decodeObjectForKey:fileName];
        }
      
    }
    
    return dlcListArr;
}

- (void)ecgCount
{
    //获取本地ecg.dat
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    arr = [[self parseLocalECGList] mutableCopy];
  
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<arr.count; i++) {
 
        ECGInfoItem *ecgItem = arr[i];
        //读取本地文件
        NSString *fileName = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][1]];
        if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
            
            //下载过的
            if (ecgItem.bHaveVoiceMemo) {
                
                //打开本地文件
                NSString *fileName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:ecgItem.dtcDate][1]];
                NSData *fileData = [FileUtils readFile:fileName inDirectory:curDirName];
                ecgItem.dataVoice = [fileData mutableCopy];
                if(!ecgItem.dataVoice){
                    
                    [array addObject:ecgItem];
                }

            }
            
        }else{
        
            [array addObject:ecgItem];
        }
    }

    [_curUser.arrECG removeAllObjects];
    [_curUser.arrECG setArray:array];

    
    [self loadSpo2];
    
}

- (void)slmCount
{
    //获取本地ecg.dat
    NSMutableArray *arr = [NSMutableArray array];  //checkme端的数据
    arr = [[self parseLocalSLMList] mutableCopy];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<arr.count; i++) {
        
        SLMItem *slmItem = arr[i];
        //读取本地文件
        //读取本地文件
        NSString *fileName = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:slmItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:slmItem.dtcStartDate][1]];
              if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
            //下载过的
            
        }else{
            
            [array addObject:slmItem];
        }
    }
    
    self.slmArr = array;

    [self loadSpo2];
    
}

- (void)endClout
{
    
    int count = 0;
    for (int i = 0; i < self.userList.arrUserList.count; i++) {
        User *user = [self.userList.arrUserList objectAtIndex:i];
        count += user.arrECG.count;
        count += user.arrDlc.count;
        
    }
    
    [self.mdelegate count:count];


}

- (void)loadData
{
    
           //如果已经主机删除了用户
        
    if ([AppDelegate GetAppDelegate].isOffline) { //如果程序是离线状态
            
            
        }else{
            
            if([UserList instance].arrUserList.count - 1 < self.uIndex){
                //下载完成
                [self.mdelegate loadSugrecess];
                return;
            }
            
            self.userList = [UserList instance];
            _curUser = nil;
            _curUser = [self.userList.arrUserList objectAtIndex:self.uIndex];

            
            if (_curUser.arrDlc.count == 0) {
                //没有dlc数据
                if(_curUser.arrECG.count == 0){
                
                    self.uIndex++;
                    [self loadData];
                    
                }else{
                
                    self.downECG = _curUser.arrECG[0];
                    self.downECG.ecgDelegate = self;
                    [self.downECG beginDownloadDetail];

                }
                
            }else{
                
                
                self.downDAIL = _curUser.arrDlc[0];
                self.downDAIL.dlcDelegate = self;
                [self.downDAIL beginDownloadDetail];
                
            }
        }

}

- (void) onDlcDetailDataDownVoiceloadSuccess:(FileToRead *)fileData
{
    
    [self.downDAIL beginDownloadDetail];

}


//#pragma mark -------Spot Delegate-------------
//- (void)onSpcDetailDataDownloadSuccess:(FileToRead *)fileData
//{
//    if(fileData.fileType == FILE_Type_SpcDetailData){
//        self.downSPOT.innerData =  [FileParser paserSpcInnerData_WithFileData:fileData.fileData];
//        
//        //  归档存储数据
//        NSString *itemStr = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:self.downSPOT.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downSPOT.dtcDate][1]];;
//        NSMutableData *itemData = [NSMutableData data];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
//        [archiver encodeObject:self.downSPOT forKey:itemStr];
//        [archiver finishEncoding];
//        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];    //存到指定文件夹
//        [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%@%@",itemStr,curDirName]];
//        
//        if(self.downSPOT.bHaveVoiceMemo == YES){
//            self.isDetail = YES;
//            [self.downSPOT beginDownloadVoice];
//            
//        }else{
//            
//            self.downSPOT.spcDelegate = nil;
//            [self.mdelegate loadDatailOne];
//            [_curXuser.arrSpotCheck removeObjectAtIndex:0];
//            if (_curXuser.arrSpotCheck.count == 0) {
//                
//                if (self.ecgArr.count == 0) {
//                    
//                    if (self.slmArr.count == 0) {
//                        
//                        [self.mdelegate loadSugrecess];
//                        
//                    }else{
//                        
//                        self.downSLM = self.slmArr[0];
//                        self.downSLM.slmDelegate = self;
//                        [self.downSLM beginDownloadDetail];
//                    }
//                    
//                }else{
//                    
//                    self.downECG = self.ecgArr[0];
//                    self.downECG.ecgDelegate = self;
//                    [self.downECG beginDownloadDetail];
//                    
//                }
//                
//            }else{
//                
//                self.downSPOT = _curXuser.arrSpotCheck[0];
//                self.downSPOT.spcDelegate = self;
//                [self.downSPOT beginDownloadDetail];
//                
//            }
//            
//        }
//    }
//    
//    if (fileData.fileType == FILE_Type_SpcVoiceData) {
//        self.isDetail = NO;
//        NSString* fileName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:self.downSPOT.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downSPOT.dtcDate][1]];
//        // 把录音存储到本地
//        NSMutableData *data = fileData.fileData;
//        [FileUtils saveFile:fileName FileData:data withDirectoryName:curDirName];
//        self.downSPOT.spcDelegate = nil;
//        [_curXuser.arrSpotCheck removeObjectAtIndex:0];
//        [self.mdelegate loadDatailOne];
//        
//        if (_curXuser.arrSpotCheck.count == 0) {
//            
//            if (self.ecgArr.count == 0) {
//                
//                if (self.slmArr.count == 0) {
//                    
//                    [self.mdelegate loadSugrecess];
//                    
//                }else{
//                    
//                    self.downSLM = self.slmArr[0];
//                    self.downSLM.slmDelegate = self;
//                    [self.downSLM beginDownloadDetail];
//                }
//                
//            }else{
//                
//                self.downECG = self.ecgArr[0];
//                self.downECG.ecgDelegate = self;
//                [self.downECG beginDownloadDetail];
//                
//            }
//            
//        }else{
//            
//            self.downSPOT = _curXuser.arrSpotCheck[0];
//            self.downSPOT.spcDelegate = self;
//            [self.downSPOT beginDownloadDetail];
//        }
//        
//    }
//    
//}
//
//- (void)onSpcDetailDataDownloadTimeout
//{
//    [self.mdelegate countFail];
//
//}
//
//- (void)onSpcDetailDataDownloadProgress:(double)progress
//{
//    if(self.downSPOT.bHaveVoiceMemo == YES){
//        
//        if (self.isDetail) {
//            
//            [self.mdelegate progress:progress / 2 + 0.5];
//            
//        }else{
//            
//            [self.mdelegate progress:progress/2];
//            
//        }
//        
//    }else{
//        
//        [self.mdelegate progress:progress];
//        
//    }
//
//}

#pragma mark -------DLC Delegate-------------
- (void)onDlcDetailDataDownloadSuccess:(FileToRead *)fileData
{
    
    if(fileData.fileType == FILE_Type_EcgDetailData){
        
    self.downDAIL.innerData = [FileParser parseEcg_WithFileData:fileData.fileData];
    
        //  归档存储数据
        NSString *itemStr = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:self.downDAIL.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downDAIL.dtcDate][1]];;
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:self.downDAIL forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];    //存到指定文件夹
        [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%@%@",itemStr,curDirName]];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,self.downDAIL.dtcDate.year,(long)self.downDAIL.dtcDate.month,self.downDAIL.dtcDate.day,self.downDAIL.dtcDate.hour,self.downDAIL.dtcDate.minute,self.downDAIL.dtcDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",self.downDAIL.dtcDate.year,(long)self.downDAIL.dtcDate.month,self.downDAIL.dtcDate.day,self.downDAIL.dtcDate.hour,self.downDAIL.dtcDate.minute,self.downDAIL.dtcDate.second];
        
        NSString *description = ecgResultDescrib(self.downDAIL.innerData.ecgResultDescrib);
        if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
            NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
            description = [NSString stringWithFormat:@"%@\n%@", strArr[0],strArr[1]];
        } else { //只有一条描述
        }
        
        NSString *status;
        NSString *status1;
        
        if(self.downDAIL.innerData.enFilterKind == kFilterKind_Normal){
            
            status = @"N";
            status1 = @"Normal";
        }else{
            
            status = @"A";
            status1 = @"Abnormal";
        }
        
        
        NSArray *desarray =  [NSArray arrayWithObjects:@"Normal Blood Oxygen",@"Low Blood Oxygen", @"Unable to Analyze", nil];
        NSString *spo2des = [desarray objectAtIndex:self.downDAIL.SPO2_R];
        
        NSString *spo2 = INT_TO_STRING_WITHOUT_ERR_NUM( self.downDAIL.SPO2);
        //    NSString *pi = DOUBLE0_TO_STRING_WITHOUT_ERR_NUM( _curDLCItem.PI);
        
        NSString *qrs = INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.innerData.QRS);
        //    NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.HR);
        NSString *qtcStr = (self.downDAIL.innerData.QTc > 260 && self.downDAIL.innerData.QTc < 600) ? INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.innerData.QTc): @"--";
        //    NSString *qtStr = (_curDLCItem.innerData.QT > 200 && _curDLCItem.innerData.QT < 900) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QT): @"--";
        //
        //    NSString *BP = (_curDLCItem.BP > 0 && _curDLCItem.innerData.QT < 255) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QT): @"--";
        
        NSString *sbp = INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.BP);
        NSString *rpp = INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.RPP);
        
        NSString *strHr = [NSString stringWithFormat:@"%hu", self.downDAIL.HR];
        if ([strHr intValue] == 0) {
            strHr = @"--";
        } else {
            
        }
        
        NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.HR);
        int hrValue = [[NSString stringWithFormat:@"%d",self.downDAIL.HR] intValue];
        NSString *ecgStrResult;
        if (hrValue == 0) {
            ecgStrResult = DTLocalizedString(@"Unable to Analyze", nil);
        }
        else if( 0 < hrValue && hrValue < 50)
        {
            ecgStrResult = @"Heart rate: Low range";
            
        }
        else if( 50 <= hrValue && hrValue <= 100)
        {
            ecgStrResult = @"Heart rate: Medium range";
            
        }
        else if( 100 < hrValue && hrValue < 150)
        {
            ecgStrResult = @"Heart rate: High range";
            
        }
        else {
            
            ecgStrResult = @"Heart rate: Out of range";
        }
        
        int spoValue = [[NSString stringWithFormat:@"%d",self.downDAIL.SPO2] intValue];
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
        
        int rppValue = [[NSString stringWithFormat:@"%d",self.downDAIL.RPP] intValue];
        
        NSString *rppResult;
        
        if (rppValue == 0) {
            
            rppResult = @"";
        }
        else if( 0 < rppValue && rppValue < 3000)
        {
            rppResult = @"";
            
        }
        else if( 3000 <= rppValue && rppValue <= 5400) //Rate Pressure Product
        {
            rppResult = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Below range", nil):DTLocalizedString(@"RPP: Below range", nil) ;
            
        }
        else if( 5400 < rppValue && rppValue <= 12000)
        {
            rppResult = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Medium range", nil):DTLocalizedString(@"RPP: Medium range", nil) ;
            
        }
        else if( 12000 < rppValue && rppValue <= 20000)
        {
            rppResult = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: High range", nil) :DTLocalizedString(@"RPP: High range", nil) ;
            
        }
        else {
            
            rppResult = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Above  range", nil) :DTLocalizedString(@"RPP: Above  range", nil) ;
        }
        
        NSString *result = [NSString stringWithFormat:@"%@, %@, %@",ecgStrResult,spo2StrResult,rppResult];
        
        NSString *sbpUnit = @"";
        
        if(self.downDAIL.BP_Flag == 0)
        {
            sbp = [NSString stringWithFormat:@"%d",self.downDAIL.BP] ;
            sbpUnit = @"%";
            
        }
        else if(self.downDAIL.BP_Flag == -1 || self.downDAIL.BP_Flag == 255)
        {
            
            //确定chart类型
            for (BPCheckItem *item in _curUser.arrBPCheck) {
                if (item.userID == _curUser.ID) {//有校准(re或abs)
                    
                    if (item.rPresure==0||item.cPresure==0) {//re
                        sbpUnit = @"%";
                        
                    }
                    else{//abs
                        sbpUnit = @"mmHg";
                        
                    }
                }
            }
        }
        else
        {
            sbpUnit = @"mmHg";
            
        }
        if (_curUser.ID  == 1) {
            
            sbp = @"--";
            sbpUnit = @"";
        }
        NSString *rr = INT_TO_STRING_WITHOUT_ERR_NUM(self.downDAIL.RR);
        
        NSString *jsonstr;
        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Body Check\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160401\",\"display\":\"Body Check\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"%@\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8867-4\",\"display\":\"Heart rate\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"/min\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"/min\"}},{\"code\": {\"coding\":{\"system\": \"http://loinc.org\",\"code\": \"9304-7\",\"display\": \"Respiration rhythm\"}},\"valueQuantity\": {\"value\": \"%@\",\"unit\": \"/min\",\"system\": \"http://unitsofmeasure.org\",\"code\": \"/min\"}},{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"20564-1\",\"display\":\"Oxygen saturation in Blood\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://en.wikipedia.org/wiki/Rate_pressure_product\",\"code\":\"RPP\",\"display\":\"Rate Pressure Product\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"https://en.wikipedia.org/wiki/Rate_pressure_product\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8480-6\",\"display\":\"Systolic blood pressure\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%@\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"mm[Hg]\"}},{\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131329\",\"display\":\"MDC_ECG_ELEC_POTL_I\"}},\"valueString\":\"%@\"}]}",str1,time,status,status1,result,strHr,rr,spo2,rpp,sbp,sbpUnit,self.downDAIL.innerData.dataStr];
        
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
        model.birthDate = [NSString stringWithFormat:@"%.2ld-%.2ld-%.2ld",(long)curUser.dtcBirthday.year,curUser.dtcBirthday.month,curUser.dtcBirthday.day];
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
        
    if(self.downDAIL.bHaveVoiceMemo == YES){

        self.isDetail = YES;
        self.downDAIL.dlcDelegate = self;
        [self.downDAIL beginDownloadVoice];
        
        
    }else{
        
        self.downDAIL.dlcDelegate = nil;
        [self.mdelegate loadDatailOne];
        [_curUser.arrDlc removeObjectAtIndex:0];
        if (_curUser.arrDlc.count == 0) {
            
            if (_curUser.arrECG.count == 0) {
                
                self.uIndex++;
                [self loadData];
              
                
            }else{
                
                self.downECG = _curUser.arrECG[0];
                self.downECG.ecgDelegate = self;
                [self.downECG beginDownloadDetail];
                
            }
            
        }else{

            self.downDAIL = _curUser.arrDlc[0];
            self.downDAIL.dlcDelegate = self;
            [self.downDAIL beginDownloadDetail];
            
        }
       
    }
        
    }
    
    if (fileData.fileType == FILE_Type_ECGVoiceData) {
        self.isDetail = NO;

        NSString* fileName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:self.downDAIL.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downDAIL.dtcDate][1]];
        // 存储到本地
        NSMutableData *data = fileData.fileData;
        [FileUtils saveFile:fileName FileData:data withDirectoryName:curDirName];
        self.downDAIL.dlcDelegate = nil;
        [_curUser.arrDlc removeObjectAtIndex:0];
        [self.mdelegate loadDatailOne];

        if (_curUser.arrDlc.count == 0) {
            
            if (_curUser.arrECG.count == 0) {
                
                self.uIndex++;
                [self loadData];

                
            }else{
            
            self.downECG = _curUser.arrECG[0];
            self.downECG.ecgDelegate = self;
            [self.downECG beginDownloadDetail];
                
            }
            
        }else{
        
            self.downDAIL = _curUser.arrDlc[0];
            self.downDAIL.dlcDelegate = self;
            [self.downDAIL beginDownloadDetail];
        
        }

    }
    
}

- (void)onDlcDetailDataDownloadTimeout
{
    [self.mdelegate countFail];

}

- (void)onDlcDetailDataDownloadProgress:(double)progress
{

    if(self.downDAIL.bHaveVoiceMemo == YES){
        if (self.isDetail) {
            
            [self.mdelegate progress:progress / 2 + 0.5];
            
        }else{

            [self.mdelegate progress:progress/2];
            
        }
        
    }else{
        
        [self.mdelegate progress:progress];
        
    }
    
}

#pragma mark -------ECG Delegate-------------
- (void)onECGDetailDataDownloadSuccess:(FileToRead *)fileData
{
    
    if(fileData.fileType == FILE_Type_EcgDetailData)
    {

        self.downECG.innerData = [FileParser parseEcg_WithFileData:fileData.fileData];
        //  归档存储数据
        NSString *itemStr = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:self.downECG.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downECG.dtcDate][1]];;
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:self.downECG forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];
        [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%@%@",itemStr,curDirName]];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,(long)self.downECG.dtcDate.year,(long)self.downECG.dtcDate.month,self.downECG.dtcDate.day,self.downECG.dtcDate.hour,self.downECG.dtcDate.minute,self.downECG.dtcDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",(long)self.downECG.dtcDate.year,(long)self.downECG.dtcDate.month,self.downECG.dtcDate.day,self.downECG.dtcDate.hour,self.downECG.dtcDate.minute,self.downECG.dtcDate.second];
        
        NSString *description = ecgResultDescrib(self.downECG.innerData.ecgResultDescrib);
        if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
            NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
            description = [NSString stringWithFormat:@"%@\n%@", strArr[0],strArr[1]];
        }else{ //只有一条描述
            
        }
        
        NSString *st;
        if (self.downECG.enLeadKind==kLeadKind_Hand||self.downECG.enLeadKind==kLeadKind_Chest) {
            //                          0x01                                        0x02
            st = @"--";
        }else{
            if (self.downECG.enPassKind==kPassKind_Others) {
                st = @"--";
            }else{
                st = [NSString stringWithFormat:@"%@%@",(self.downECG.innerData.ST>=0?(@"+"):@""),DOUBLE2_TO_STRING(((double)self.downECG.innerData.ST)/100.0)];
            }
        }
        
        NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(self.downECG.innerData.HR);
        NSString *qrs = INT_TO_STRING_WITHOUT_ERR_NUM(self.downECG.innerData.QRS);
        NSString *qtcStr = (self.downECG.innerData.QTc > 260 && self.downECG.innerData.QTc < 600) ? INT_TO_STRING_WITHOUT_ERR_NUM(self.downECG.innerData.QTc): @"--";
        //        NSString *qtStr = (_curECGItem.innerData.QT > 200 && _curECGItem.innerData.QT < 900) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.innerData.QT): @"--";
        
        int _hr  = self.downECG.innerData.HR;
        NSString *pr;
        if (_hr == 0) {
            pr = @"--";
        } else {
            pr = [NSString stringWithFormat:@"%.1f",60.0 / _hr];
        }
        
        NSString *status;
        NSString *status1;
        
        if(self.downECG.innerData.enFilterKind == kFilterKind_Normal){
            
            status = @"N";
            status1 = @"Normal";
            
        }else{
            
            status = @"A";
            status1 = @"Abnormal";
        }
        
        int hrValue = [[NSString stringWithFormat:@"%d",self.downECG.HR] intValue];
        NSString *ecgStrResult;
        if (hrValue == 0) {
            ecgStrResult = DTLocalizedString(@"Unable to Analyze", nil);
        }
        
        else if( 0 < hrValue && hrValue < 50)
        {
            ecgStrResult = @"Heart rate: Low range";
            
        }
        else if( 50 <= hrValue && hrValue <= 100)
        {
            ecgStrResult = @"Heart rate: Medium range";
            
        }
        else if( 100 < hrValue && hrValue < 150)
        {
            ecgStrResult = @"Heart rate: High range";
            
        }
        else {
            
            ecgStrResult = @"Heart rate: Out of range";
        }
        
        NSString *jsonstr;
        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Heart Activity\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131328\",\"display\":\"MDC_ECG_ELEC_POTL\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"%@\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8867-4\",\"display\":\"Heart rate\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"/min\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"{beats}/min\"}},{\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131329\",\"display\":\"MDC_ECG_ELEC_POTL_I\"}},\"valueString\":\"%@\"}]}",str1,time,status,status1,ecgStrResult,hr,self.downECG.innerData.dataStr];;
        
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
            }        }
        
        if (self.downECG.bHaveVoiceMemo) {
            self.isDetail = YES;
            [self.downECG beginDownloadVoice];
        
        }else{
            
            self.downECG.ecgDelegate = nil;
            [self.mdelegate loadDatailOne];
            [_curUser.arrECG removeObjectAtIndex:0];
            
        if(_curUser.arrECG.count != 0){
            
            self.downECG = _curUser.arrECG[0];
            self.downECG.ecgDelegate = self;
            [self.downECG beginDownloadDetail];
            
        }else{
        //下载
            self.uIndex++;
            [self loadData];
            
        }

    }
        
    
    }
     if(fileData.fileType == FILE_Type_ECGVoiceData)
    {
        self.isDetail = NO;
        
        [self.mdelegate loadDatailOne];
        NSString *fileName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:self.downECG.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downECG.dtcDate][1]];
        [FileUtils saveFile:fileName FileData:fileData.fileData withDirectoryName:curDirName];

        self.downECG.ecgDelegate = nil;
        [_curUser.arrECG removeObjectAtIndex:0];
        
        if (_curUser.arrECG.count == 0) {
           
            self.uIndex++;
            [self loadData];
            
        }else{
            
            self.downECG = _curUser.arrECG[0];
            self.downECG.ecgDelegate = self;
            [self.downECG beginDownloadDetail];

        }
    
    }
    
}

- (void)onECGDetailDataDownloadTimeout
{
    //下载失败
    [self.mdelegate countFail];

}

- (void) onECGDetailDataDownloadProgress:(double) progress
{
    //进度提示
    if(self.downECG.bHaveVoiceMemo == YES){
        if (self.isDetail) {
            
            [self.mdelegate progress:progress / 2 + 0.5];
            
        }else{
            
            [self.mdelegate progress:progress/2];
        }
        
    }else{
        
        [self.mdelegate progress:progress];
        
    }

}

#pragma mark -------SLM Delegate-------------
- (void)onSLMDetailDataDownloadSuccess:(FileToRead *)fileData
{
    self.downSLM.slmDelegate = nil;
    self.downSLM.innerData = [FileParser parseSLMData_WithFileData:fileData.fileData];
    
    //  归档存储数据
    NSString *itemStr = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:self.downSLM.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.downSLM.dtcStartDate][1]];;
    NSMutableData *itemData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
    [archiver encodeObject:self.downSLM forKey:itemStr];
    [archiver finishEncoding];
    
    [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];
    [[FirstDownManger sharedManager].downedArray addObject:[NSString stringWithFormat:@"%@%@",itemStr,curDirName]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sn = [userDefaults objectForKey:@"SN"];
    if ([UserList instance].isSpotCheck){
        NSInteger userIndex  = [userDefaults integerForKey:@"LastXuser"];
        Xuser *curXuser = [[UserList instance].arrXuserList objectAtIndex:userIndex];
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,sn,(long)_downSLM.dtcStartDate.year,(long)_downSLM.dtcStartDate.month,_downSLM.dtcStartDate.day,_downSLM.dtcStartDate.hour,_downSLM.dtcStartDate.minute,_downSLM.dtcStartDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",(long)_downSLM.dtcStartDate.year,(long)_downSLM.dtcStartDate.month,_downSLM.dtcStartDate.day,_downSLM.dtcStartDate.hour,_downSLM.dtcStartDate.minute,_downSLM.dtcStartDate.second];
        
        NSString *status;
        NSString *status1;
        NSString *status2;
        
        //诊断结果
        if(_downSLM.LO2Count!=0){
            //            _strResult.text = DTLocalizedString(@"Blood Oxygen drops detected", nil);
            status = @"A";
            status1 = @"Abnormal";
            status2 = @"Blood Oxygen drops detected";
            
        }else if(_downSLM.enPassKind==kPassKind_Pass){
            //            _strResult.text = DTLocalizedString(@"No abnormalities detected", nil);
            status = @"N";
            status1 = @"Normal";
            status2 = @"No abnormalities detected";
            
        }else{
            //            _strResult.text = DTLocalizedString(@"Unable to Analyze", nil);
        }
        
        U32 gap = _downSLM.totalTime;
        int h = gap/3600;
        int m = (gap - h*3600)/60;
        int s = gap - m*60 - h*3600;
        //总时间
        NSString *tatal;
        if (h==0) {
            tatal = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
        }else {
            tatal = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
        }
        
        
        NSString *dropStr;
        //跌落时间
        h = _downSLM.LO2Time/3600;
        m = (_downSLM.LO2Time - h*3600)/60;
        s = _downSLM.LO2Time - m*60 - h*3600;
        if (h==0) {
            dropStr = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
        }else {
            dropStr = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
        }
        
        NSString *jsonstr;
//        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"OxiRecorder\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160503\",\"display\":\"OxiRecorder\"}},\"effectiveDateTime\":\"%@\",\"component\":[{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-9\",\"display\":\"Total duration\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-10\",\"display\":\"<90%% STAT.\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"s\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-11\",\"display\":\"Drops\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-12\",\"display\":\"Avg\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-13\",\"display\":\"Lowest\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-8\",\"display\":\"SLEEP_I\"}},\"valueString\":\"%@\"}]}",str1,time,tatal,INT_TO_STRING_WITHOUT_ERR_NUM(_downSLM.LO2Value),INT_TO_STRING(_downSLM.LO2Count),INT_TO_STRING_WITHOUT_ERR_NUM(_downSLM.AverageSpo2),INT_TO_STRING_WITHOUT_ERR_NUM(_downSLM.LO2Value),_downSLM.innerData.dataStr];
        
        CloudModel *model = [[CloudModel alloc] init];
        //gest
        model.macID = [NSString stringWithFormat:@"%@%d",sn,1];
        model.sn = sn;
        model.ISUpload = @"0";
        model.time = time;
        model.jsonStr = jsonstr;
        model.weight = 600;
        model.name = @"Guest";
        model.sex = 0;
        model.birthDate = @"1980-12-31";
        model.height = 175;
        model.height = 50;
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,curDirName];
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            
            if(_curUser.ID != 1){
                [model save];
            }
        }
    
    }else{
        
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
        NSLog(@"%@",curUser.name);
        NSLog(@"%d",curUser.ID);
        NSLog(@"%f",curUser.weight);
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,sn,_downSLM.dtcStartDate.year,(long)_downSLM.dtcStartDate.month,_downSLM.dtcStartDate.day,_downSLM.dtcStartDate.hour,_downSLM.dtcStartDate.minute,_downSLM.dtcStartDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",_downSLM.dtcStartDate.year,(long)_downSLM.dtcStartDate.month,_downSLM.dtcStartDate.day,_downSLM.dtcStartDate.hour,_downSLM.dtcStartDate.minute,_downSLM.dtcStartDate.second];
        
        //        NSString *description = ecgResultDescrib(_curECGItem.innerData.ecgResultDescrib);
        //        if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
        //            NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
        //            description = [NSString stringWithFormat:@"%@\n%@", strArr[0],strArr[1]];
        //        } else { //只有一条描述
        //        }
        NSString *status;
        NSString *status1;
        NSString *status2;
        
        //诊断结果
        if(_downSLM.LO2Count!=0){
            
            status = @"A";
            status1 = @"Abnormal";
            status2 = @"Blood Oxygen drops detected";
            
        }else if(_downSLM.enPassKind==kPassKind_Pass){
            
            status = @"N";
            status1 = @"Normal";
            status2 = @"No abnormalities detected";
            
        }else{
            
        }
        
        U32 gap = _downSLM.totalTime;
        int h = gap/3600;
        int m = (gap - h*3600)/60;
        int s = gap - m*60 - h*3600;
        
        //总时间
        NSString *tatal;
        if (h==0) {
            tatal = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
        }else {
            tatal = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
        }
        
        NSString *dropStr;
        //跌落时间
        h = _downSLM.LO2Time/3600;
        m = (_downSLM.LO2Time - h*3600)/60;
        s = _downSLM.LO2Time - m*60 - h*3600;
        if (h==0) {
            dropStr = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
        }else {
            dropStr = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
        }
        
        NSString *jsonstr;
//        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"OxiRecorder\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160502\",\"display\":\"Sleep\"}},\"effectiveDateTime\":\"%@\",\"component\":[{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-9\",\"display\":\"Total duration\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-10\",\"display\":\"<90%% STAT.\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"s\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-11\",\"display\":\"Drops\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-12\",\"display\":\"Avg\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-13\",\"display\":\"Lowest\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-8\",\"display\":\"SLEEP_I\"}},\"valueString\":\"%@\"}]}",str1,time,tatal,INT_TO_STRING(_downSLM.LO2Count),dropStr,INT_TO_STRING_WITHOUT_ERR_NUM(_downSLM.AverageSpo2),INT_TO_STRING_WITHOUT_ERR_NUM(_downSLM.LO2Value),_downSLM.innerData.dataStr];
        
        CloudModel *model = [[CloudModel alloc] init];
        model.macID = [NSString stringWithFormat:@"%@%d",sn,1];
        model.sn = sn;
        model.ISUpload = @"0";
        model.time = time;
        model.jsonStr = jsonstr;
        model.weight = 600;
        model.name = @"Guest";
        model.sex = 0;
        model.birthDate = @"1980-12-31";
        model.height = 175;
        model.height = 50;
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,curDirName];
        
        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            
            if(_curUser.ID != 1){
                [model save];
            }
        }
        
    }

    [self.mdelegate loadDatailOne];
    [self.slmArr removeObjectAtIndex:0];
    if (self.slmArr.count == 0) {
        //完成
        [self.mdelegate loadSugrecess];

    }else{
    
        self.downSLM = self.slmArr[0];
        self.downSLM.slmDelegate = self;
        [self.downSLM beginDownloadDetail];
        
    }
    
}

- (void)onSLMDetailDataDownloadTimeout
{
    [self.mdelegate countFail];
}

- (void)onSLMDetailDataDownloadProgress:(double)progress
{
    [self.mdelegate progress:progress];
}

//离线状态下解析本地列表
- (NSArray *)parseLocalSLMList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:SLM_LIST_FILE_NAME];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:curDirName]) {
        
        NSData *dlcListData = [FileUtils readFile:fileName inDirectory:curDirName];
        NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
        dlcListArr = [unArch decodeObjectForKey:fileName];
    }
    return dlcListArr;
    
}


#pragma mark - BTCommunication Delagate

- (void)postCurrentReadProgress:(double)progress
{
    return;
}

- (void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    
//    if (fileData.enLoadResult == kFileLoadResult_TimeOut) {
//        [self.mdelegate countFail];
//        return;
//    }
    /**
     *  if the data is ECG list data
     */
    if(fileData.fileType == FILE_Type_EcgList)   // 0x03
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self loadSpo2];
        }
        else
        {
            [[FirstDownManger sharedManager].downedArray addObject:ECG_LIST_FILE_NAME];
            //解析ECG数据
            NSArray *arr = [FileParser parseEcgList_WithFileData:fileData.fileData];
            [_curUser.arrECG setArray:arr];
            [self saveECGListToLocalPlace];
            [self ecgCount];
            
        }
    }
    
    if(fileData.fileType == FILE_Type_DailyCheckList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self loadECG];
            
        }else {
            // 解析
            NSArray *arr = [FileParser parseDlcList_WithFileData:fileData.fileData];
            [_curUser.arrDlc setArray:arr];
            [self saveDLCListToLocalPlace];
            [self dlcCount];
            
        }
    }
    
    if(fileData.fileType == FILE_Type_SleepMonitorList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self loadSpo2];
        }
        else
        {
            NSArray *arr = [FileParser parseSLMList_WithFileData:fileData.fileData];
            [self.slmArr setArray:arr];
            [self saveSLMListToLocalPlace];
            [self slmCount];
        }
        
    }
    
    if(fileData.fileType == FILE_Type_SPO2List)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self loadTemp];
        }
        else
        {
            NSArray *arr = [FileParser parseSPO2List_WithFileData:fileData.fileData];
            [_curUser.arrSPO2 setArray:arr];
            [self saveSpo2ListToLocalPlace];
            [self loadTemp];
         
        }
    }

    if(fileData.fileType == FILE_Type_TempList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            [self loadRelax];
        }
        else
        {
            NSArray *arr = [FileParser parseTempList_WithFileData:fileData.fileData];
            [_curUser.arrTemp setArray:arr];
            [self saveTempListToLocalPlace];
            [self loadRelax];

        }
    }

    if(fileData.fileType == FILE_Type_RealaxList)
    {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut)
        {
            self.uIndex++;
            [self totalCount];
        }
        else
        {
            NSArray *arr = [FileParser parseRelaxMeList_WithFileData:fileData.fileData];
            [_curUser.arrRelaxMe setArray:arr];
            [self savePedListToLocalPlace];
            self.uIndex++;
            [self totalCount];
            
        }
    }
    
    if (isSpc) {
        /**
         *  if the data is SpotCheck list data
         */
        if (fileData.fileType == FILE_Type_SpotCheckList) {
            if(fileData.enLoadResult == kFileLoadResult_TimeOut)
            {
                
            }else {
                NSArray *arr = [FileParser paserSpotCheckList_WithFileData:fileData.fileData];
                [_curXuser.arrSpotCheck setArray:arr];
                [self saveNoHR_DataToLocalPlace];
                [self spotCount];
            }
        }
    }

}

//保存relax数据
- (void)savePedListToLocalPlace
{
    for (RelaxMeItem *Item in _curUser.arrRelaxMe) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:RELAXME_DATA_USER_TIME_FILE_SAVE_NAME , _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:Item.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:Item.dtcDate][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:Item forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"];
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
        NSLog(@"%@",curUser.name);
        NSLog(@"%d",curUser.ID);
        NSLog(@"%f",curUser.weight);
        
        NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,Item.dtcDate.year,(long)Item.dtcDate.month,Item.dtcDate.day,Item.dtcDate.hour,Item.dtcDate.minute,Item.dtcDate.second];
        NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",Item.dtcDate.year,(long)Item.dtcDate.month,Item.dtcDate.day,Item.dtcDate.hour,Item.dtcDate.minute,Item.dtcDate.second];
        NSString *hrv =  INT_TO_STRING_WITHOUT_ERR_NUM(Item.hrv);

//      [NSDate engDescOfDateComp:_relaxMeItem.dtcDate][1];
//      [NSDate engDescOfDateComp:_relaxMeItem.dtcDate][0];
        
        NSString *jsonstr;
        jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Relax me\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"vital-signs\",\"display\":\"Vital Signs\"}},\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160402\",\"display\":\"Relax me\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"N\",\"display\":\"Normal\"},\"text\":\"--\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"https://api.viatomtech.com.cn/fhir\",\"code\":\"160501-14\",\"display\":\"Relaxation index\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"http://unitsofmeasure.org\",\"code\":\" \"}},{\"code\": {\"coding\":{\"system\": \"https://cloud.viatomtech.com/fhir\",\"code\": \"170114-3\",\"display\": \"HRV(RMSSD)\"}},\"valueQuantity\": {\"value\": \"%@\",\"unit\": \"ms\",\"system\": \"http://unitsofmeasure.org\",\"code\": \"ms\"}},{\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160501-14\",\"display\":\"Duration\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"s\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"s\"}}]}",str1,time,INT_TO_STRING_WITHOUT_ERR_NUM(Item.Relaxation),hrv,INT_TO_STRING_WITHOUT_ERR_NUM(Item.timemiao)];
        
        CloudModel *model = [[CloudModel alloc] init];
        model.macID =_curUser.medical_id;
        model.sn = sn;
        model.weight = curUser.weight ;
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
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,curDirName];        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            
            if(_curUser.ID != 1){
                [model save];
            }
        }
    }
}

//如果不包含HR数据，则直接保存到本地
- (void) saveNoHR_DataToLocalPlace
{
    
    NSString *fileName = [NSString stringWithFormat:SPC_LIST_FILE_NAME, _curXuser.userID];
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:_curXuser.arrSpotCheck forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:curDirName];
    
}

//保存spo2数据列表
- (void) saveSpo2ListToLocalPlace
{
    for (SPO2InfoItem *spo2Item in _curUser.arrSPO2) {
        // 存储
        NSString *itemStr = [NSString stringWithFormat:SPO2_DATA_USER_TIME_FILE_SAVE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][0], [NSDate engDescOfDateCompForDataSaveWith:spo2Item.dtcMeasureTime][1]];
        NSMutableData *itemData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
        [archiver encodeObject:spo2Item forKey:itemStr];
        [archiver finishEncoding];
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
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
        [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:curDirName];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sn = [userDefaults objectForKey:@"SN"];
        NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
        User *curUser = [[UserList instance].arrUserList objectAtIndex:self.uIndex];
        
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
        model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,curDirName];        NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
        if (array.count == 0) {
            
            if(_curUser.ID != 1){
                [model save];
            }
            
        }
        
    }
}

- (void)saveSLMListToLocalPlace
{
    NSString *fileName = [NSString stringWithFormat:SLM_LIST_FILE_NAME];
    NSMutableData *ecglistData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:ecglistData];
    [archiver encodeObject:self.slmArr forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:ecglistData withDirectoryName:curDirName];
    
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

//获取ecg列表
- (NSArray *)parseLocalECGList
{
    NSArray *dlcListArr;
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_SAVE_NAME,_curUser.medical_id];
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

//保存ecg列表
- (void)saveECGListToLocalPlace
{
    NSString *fileName = [NSString stringWithFormat:ECG_LIST_FILE_SAVE_NAME,_curUser.medical_id];
    NSMutableData *ecglistData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:ecglistData];
    [archiver encodeObject:_curUser.arrECG forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:ecglistData withDirectoryName:curDirName];
    
}


@end


