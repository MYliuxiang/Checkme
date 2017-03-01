//
//  DailyCheckCell.m
//  MyCellTest
//
//  Created by Joe on 14-8-1.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//
#import "AppDelegate.h"
#import "DailyCheckCell.h"
#import "BTUtils.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "DailyCheckViewController.h"
#import "UAProgressView.h"
#import "FileUtils.h"

@interface DailyCheckCell() <DailyCheckItemDelegate>

@property (nonatomic,retain) DailyCheckItem *curDLCItem;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;
@property (nonatomic,retain) UAProgressView* progressView;

@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, assign) int curUserIndex;
@property (nonatomic, copy) NSString *curDirName;

@end

@implementation DailyCheckCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)init
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DailyCheckCell" owner:self options:nil];
        if(arr.count > 0)
            self = [arr objectAtIndex:0];
    if(self){
            //从本地拿到 每次连接的蓝牙设备名
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
            self.curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
            NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
            _curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

        }

        return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


+(NSString *)cellReuseId
{
    return @"cellReuseId_DailyCheckCell";
}

-(void)setPropertyWithUser:(User *)user infoItem:(DailyCheckItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    self.curDLCItem = infoItem;
    self.curUser = user;
    self.fatherVC = fatherVC;
    
    if(_curDLCItem.bDownloadIng)
    {
    }
    [self refreshDlcCellView];
}

-(void)refreshDlcCellView
{
    //summary
    _time.text = [NSDate engDescOfDateComp:_curDLCItem.dtcDate][1];
    _date.text = [NSDate engDescOfDateComp:_curDLCItem.dtcDate][0];
    
    _hrSummaryValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.HR);
    _spo2SummaryValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.SPO2);
    _SBPlable.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.BP);
    _RPPlabel.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.RPP);
    
    if ([self.curUser.name isEqualToString:@"Guest"]) {
        
        _SBPlable.text = @"--";
        _RPPlabel.text = @"--";
        _SBPmmHg.text = @" ";
        
    }
    else
    {
        if(_curDLCItem.BP_Flag == 0)
        {
            _SBPmmHg.text = @"%";
            _SBPlable.text = [NSString stringWithFormat:@"%d",_curDLCItem.BP] ;//字符串拼接问题
            
        }
        else if(_curDLCItem.BP_Flag == -1 || _curDLCItem.BP_Flag == 255)
        {
            
            //确定chart类型
            for (BPCheckItem *item in _curUser.arrBPCheck) {
                if (item.userID == _curUser.ID) {//有校准(re或abs)
                    
                    if (item.rPresure==0||item.cPresure==0) {//re
                        _SBPmmHg.text = @"%";
                        
                    }
                    else{//abs
                        _SBPmmHg.text = @"mmHg";
                    }
                }
            }
            
            
        }
        else
        {
            
            _SBPmmHg.text = @"mmHg";
        }
        
    
    }
    
   
//    _ecgImgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curDLCItem.ECG_R]];
//    _spo2ImgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curDLCItem.SPO2_R]];
    
    //录音图标
//    if (_curDLCItem.bHaveVoiceMemo == YES) {  //如果有声音
//        _isVoiceImg.hidden = NO;
//        _isVoiceImg.image = [UIImage imageNamed:@"voice_gray.png"];
//        //在本地找录音数据
//        NSString *voiceName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.ID, [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][1]];
//        if ([FileUtils isFileExist:voiceName inDirectory:_curDirName]) {//如果本地有录音数据  声音图标改为蓝色
//            _isVoiceImg.image = [UIImage imageNamed:@"voice.png"];
//        }
//    }else { //没有声音 不显示声音图标
//        _isVoiceImg.hidden = YES;
//    }
    
    _isVoiceImg.hidden = YES;
    
//    if (_curDLCItem.ECG_R==kPassKind_Pass && _curDLCItem.SPO2_R==kPassKind_Pass) {
//        _itemImgResult.backgroundColor = ITEM_LEFT_BLUE;
//    }else if (_curDLCItem.ECG_R==kPassKind_Fail||_curDLCItem.SPO2_R==kPassKind_Fail){
//        _itemImgResult.backgroundColor = ORANGE;
//    }else{
//        _itemImgResult.backgroundColor = [UIColor clearColor];
//    }

    //  读取本地文件
    /*
     152037_DLC_Data-6:57:53 AM-10-Feb-2016
     */
    NSString *fileName = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][1]];
    if ([FileUtils isFileExist:fileName inDirectory:_curDirName]) {
        
        
        if ([UserDefaults objectForKey:fileName] == nil) {
            
            NSData *itemData = [FileUtils readFile:fileName inDirectory:_curDirName];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
            DailyCheckItem *readDLCItem = [unArch decodeObjectForKey:fileName];
            _curDLCItem = nil;
            _curDLCItem = readDLCItem;

            
        }else{
            
            NSData *itemData = [FileUtils readFile:fileName inDirectory:_curDirName];
            NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
            DailyCheckItem *localDLCItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
            _curDLCItem = nil;
            _curDLCItem = localDLCItem;
            
        }
        
    }
    
    
    //设置enter按钮，信息已经下载
    if(_curDLCItem.innerData){
        [_enter setImage:[UIImage imageNamed:@"ljenter.png"]];
//        NSLog(@"----------1111-----------");
    }
    //没有下载
    else{
        [_enter setImage:[UIImage imageNamed:@"ljdownload.png"]];
//        NSLog(@"----------222222-----------");
    }
    [self refreshProgressVisibility];
}



  //   下载cell详情
-(void)downloadDetail
{
    _curDLCItem.dlcDelegate = self;
    [_curDLCItem beginDownloadDetail];
    [self initProgress];
}

- (void)onDlcDetailDataDownloadSuccess:(FileToRead *)fileData
{
    NSLog(@"下载完成");
    _curDLCItem.dlcDelegate = nil;
    _curDLCItem.innerData = [FileParser parseEcg_WithFileData:fileData.fileData];
    NSLog(@"%@",_curDLCItem.innerData.dataStr);
    
    //  归档存储数据
    NSString *itemStr = [NSString stringWithFormat:DLC_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCItem.dtcDate][1]];
    NSMutableData *itemData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
    [archiver encodeObject:_curDLCItem forKey:itemStr];
    [archiver finishEncoding];
    [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_curDirName];    //存到指定文件夹
    
    NSLog(@"%@",_curDLCItem.innerData.dataStr);

    
    [self refreshDlcCellView];
    [_progressView removeFromSuperview];
    _enter.hidden = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sn = [userDefaults objectForKey:@"SN"];
    NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
    User *curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
    
    NSLog(@"%@",_curDLCItem.innerData.dataStr);

    
    NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,_curDLCItem.dtcDate.year,(long)_curDLCItem.dtcDate.month,_curDLCItem.dtcDate.day,_curDLCItem.dtcDate.hour,_curDLCItem.dtcDate.minute,_curDLCItem.dtcDate.second];
    
    
    NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",_curDLCItem.dtcDate.year,(long)_curDLCItem.dtcDate.month,_curDLCItem.dtcDate.day,_curDLCItem.dtcDate.hour,_curDLCItem.dtcDate.minute,_curDLCItem.dtcDate.second];
    
    NSString *description = ecgResultDescrib(_curDLCItem.innerData.ecgResultDescrib);
    if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
        NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
        description = [NSString stringWithFormat:@"%@\n%@", strArr[0],strArr[1]];
    } else { //只有一条描述
    }
    NSLog(@"%@",_curDLCItem.innerData.dataStr);


    NSString *status;
    NSString *status1;
    
    if(_curDLCItem.innerData.enFilterKind == kFilterKind_Normal){
        
        status = @"N";
        status1 = @"Normal";
    }else{
        
        status = @"A";
        status1 = @"Abnormal";
    }
    
    
    NSArray *desarray =  [NSArray arrayWithObjects:@"Normal Blood Oxygen",@"Low Blood Oxygen", @"Unable to Analyze", nil];
    NSString *spo2des = [desarray objectAtIndex:_curDLCItem.SPO2_R];
    
    NSString *spo2 = INT_TO_STRING_WITHOUT_ERR_NUM( _curDLCItem.SPO2);
    //    NSString *pi = DOUBLE0_TO_STRING_WITHOUT_ERR_NUM( _curDLCItem.PI);
    
    NSString *qrs = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QRS);
    //    NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.HR);
    NSString *qtcStr = (_curDLCItem.innerData.QTc > 260 && _curDLCItem.innerData.QTc < 600) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QTc): @"--";
    //    NSString *qtStr = (_curDLCItem.innerData.QT > 200 && _curDLCItem.innerData.QT < 900) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QT): @"--";
    //
    //    NSString *BP = (_curDLCItem.BP > 0 && _curDLCItem.innerData.QT < 255) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.QT): @"--";
    
    NSString *sbp = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.BP);
    NSString *rpp = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.RPP);
    
    
    
    NSString *strHr = [NSString stringWithFormat:@"%hu", _curDLCItem.HR];
    if ([strHr intValue] == 0) {
        strHr = @"--";
    } else {
        
    }
    
    NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.innerData.HR);
    int hrValue = [[NSString stringWithFormat:@"%d",_curDLCItem.HR] intValue];
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
    
    int spoValue = [[NSString stringWithFormat:@"%d",_curDLCItem.SPO2] intValue];
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
    
    int rppValue = [[NSString stringWithFormat:@"%d",_curDLCItem.RPP] intValue];
    
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
    
    NSString *sbpUnit;
    
    if(_curDLCItem.BP_Flag == 0)
    {
        sbp = [NSString stringWithFormat:@"%d",_curDLCItem.BP] ;
        sbpUnit = @"%";

    }
    else if(_curDLCItem.BP_Flag == -1 || _curDLCItem.BP_Flag == 255)
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
    
    
    NSString *rr = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCItem.RR);

    NSString *jsonstr;
    jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Body Check\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"code\":\"160401\",\"display\":\"Body Check\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"%@\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8867-4\",\"display\":\"Heart rate\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"/min\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"/min\"}},{\"code\": {\"coding\":{\"system\": \"http://loinc.org\",\"code\": \"9304-7\",\"display\": \"Respiration rhythm\"}},\"valueQuantity\": {\"value\": \"%@\",\"unit\": \"/min\",\"system\": \"http://unitsofmeasure.org\",\"code\": \"/min\"}},{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"20564-1\",\"display\":\"Oxygen saturation in Blood\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%%\"}},{\"code\":{\"coding\":{\"system\":\"https://en.wikipedia.org/wiki/Rate_pressure_product\",\"code\":\"RPP\",\"display\":\"Rate Pressure Product\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\" \",\"system\":\"https://en.wikipedia.org/wiki/Rate_pressure_product\",\"code\":\" \"}},{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8480-6\",\"display\":\"Systolic blood pressure\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"%@\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"mm[Hg]\"}},{\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131329\",\"display\":\"MDC_ECG_ELEC_POTL_I\"}},\"valueString\":\"%@\"}]}",str1,time,status,status1,result,strHr,rr,spo2,rpp,sbp,sbpUnit,_curDLCItem.innerData.dataStr];
    
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
        //        model.height = curUser.stride;
        
    model.ISUpload = @"0";
    model.time = time;
    model.jsonStr = jsonstr;
    model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,_curDirName];
    
    NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
    if (array.count == 0) {
        
        if(_curUser.ID != 1){
            [model save];
        }
    }
    [[CloudUpLodaManger sharedManager] noticeUpdata];
}

- (void)onDlcDetailDataDownloadTimeout
{
    NSLog(@"失败超时了");
    _curDLCItem.dlcDelegate = nil;
    [self refreshDlcCellView];
    [_progressView removeFromSuperview];
    _enter.hidden = NO;
}

- (void)onDlcDetailDataDownloadProgress:(double)progress
{
    if (_progressView) {
        [_progressView setProgress:progress animated:YES];
        NSLog(@"_progressView进度");
    }
}

-(void)initProgress
{
    if (_curDLCItem.bDownloadIng) {
        _enter.hidden = YES;
        double bondSize = 35;
        CGRect bond = CGRectMake(_enter.frame.origin.x+((_enter.frame.size.width-bondSize)/2), self.frame.size.height/2-bondSize/2, bondSize, bondSize);
        _progressView = [[UAProgressView alloc] initWithFrame:bond];
        [self addSubview:_progressView];
    }
}

-(void)refreshProgressVisibility
{
    if (_curDLCItem.bDownloadIng) {
        if (!_progressView) {
            [self initProgress];
        }
        _enter.hidden = YES;
        _progressView.hidden = NO;
    }else{
        _enter.hidden = NO;
        _progressView.hidden = YES;
    }
}

@end
