//
//  ECGCell.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ECGCell.h"
#import "AppDelegate.h"
#import "BTUtils.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "ECGViewController.h"
#import "Colors.h"
#import "UAProgressView.h"
#import "FileUtils.h"

@interface ECGCell()


@property (nonatomic,retain) User *curUser;//用户
@property (nonatomic,assign) UIViewController *fatherVC;
@property (nonatomic,retain) UAProgressView* progressView;//进度条

@property (nonatomic,retain) NSString  *reID;
@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, copy) NSString *curDirName;

@end

@implementation ECGCell

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
    NSArray *arr;
    arr = [[NSBundle mainBundle] loadNibNamed:@"ECGCell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];
    if(self){
        
        //从本地拿到 每次连接的蓝牙设备名
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
        NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
        _curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

    }
    return self;
}

-(void)setReuseIdentifier:(NSString *)reuseIdentifier
{
    self.reID = reuseIdentifier;
    DLog(@"new reID:%@",self.reID);
}

- (void)awakeFromNib
{
    // Initialization code
}

+(NSString *)cellReuseId
{
//    NSString* strReuseId = [NSString stringWithFormat:@"cellReuseId_ECGCell_%d",row];
    return @"cellReuseId_ECGCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPropertyWithUser:(User *)user infoItem:(ECGInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.curECGItem = infoItem;
    self.curUser = user;
    self.fatherVC = fatherVC;
    
    if(_curECGItem.bDownloadIng)
    {
    }
     [self refreshCellView];
}

-(void)refreshCellView
{
    
     _ecgImgResult.hidden = YES;
    
    _time.text = [NSDate engDescOfDateComp:_curECGItem.dtcDate][1];
    _date.text = [NSDate engDescOfDateComp:_curECGItem.dtcDate][0];
    _hrlable.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.HR);
//    _ecgImgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curECGItem.enPassKind]];
//    _imgLead.image = [UIImage imageNamed:[IMG_LEAD_ARRAY objectAtIndex:(0)]];
    _imgLead.hidden = YES;
    _imgVoice.hidden = YES;
//    _itemImgResult.backgroundColor = _curECGItem.enPassKind == kPassKind_Pass ? ITEM_LEFT_BLUE : _curECGItem.enPassKind == kPassKind_Fail ? ORANGE : [UIColor clearColor];
    
//    //录音图标
//    if (_curECGItem.bHaveVoiceMemo) {  //如果有声音
//        _imgVoice.hidden = YES;
//        _imgVoice.image = [UIImage imageNamed:@"voice_gray.png"];
//        //在本地找录音数据
//        NSString *voiceName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][1]];
//        if ([FileUtils isFileExist:voiceName inDirectory:_curDirName]) {//本地有录音数据
//            _imgVoice.image = [UIImage imageNamed:@"voice.png"];
//        }
//    }else { //没有声音
//        _imgVoice.hidden = YES;
//       
//    }
  

    
    //读取本地文件
    NSString *fileName = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][1]];
    if ([FileUtils isFileExist:fileName inDirectory:_curDirName]) {
        //  测试  反归档取数据
        
        if ([UserDefaults objectForKey:fileName] == nil) {
            
            NSData *itemData = [FileUtils readFile:fileName inDirectory:_curDirName];
            NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
            ECGInfoItem *readECGItem = [unAch decodeObjectForKey:fileName];
            _curECGItem = readECGItem;
        }else{
            
            NSData *itemData = [FileUtils readFile:fileName inDirectory:_curDirName];
            NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
            ECGInfoItem *readECGItem = [unAch decodeObjectForKey:[UserDefaults objectForKey:fileName]];
            _curECGItem = readECGItem;
            
            
        }
        
    }

    //设置enter按钮，信息已经下载
    if(_curECGItem.innerData){
        [_enter setImage:[UIImage imageNamed:@"ljenter.png"]];
    }
    //没有下载
    else{
        [_enter setImage:[UIImage imageNamed:@"ljdownload.png"]];
    }
    
    [self refreshProgressVisibility];
}

-(void)downloadDetail
{
    _curECGItem.ecgDelegate = self;
    [_curECGItem beginDownloadDetail];
    [self initProgress];
}

- (void)onECGDetailDataDownloadSuccess:(FileToRead *)fileData
{
    _curECGItem.ecgDelegate = self;
    _curECGItem.innerData = [FileParser parseEcg_WithFileData:fileData.fileData];
    
    //  归档存储数据
    
    
    NSString *itemStr = [NSString stringWithFormat:ECG_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGItem.dtcDate][1]];;
    NSMutableData *itemData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
    [archiver encodeObject:_curECGItem forKey:itemStr];
    [archiver finishEncoding];
    
    [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_curDirName];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self refreshCellView];
    [_progressView removeFromSuperview];
    _enter.hidden = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sn = [userDefaults objectForKey:@"SN"];
    NSInteger userIndex =  [userDefaults integerForKey:@"LastUser"] ;
    User *curUser = [[UserList instance].arrUserList objectAtIndex:userIndex];
      
    NSString *str1 = [NSString stringWithFormat:@"%@%@%ld%.2ld%.2ld%.2ld%.2ld%.2ld",sn,_curUser.medical_id,_curECGItem.dtcDate.year,(long)_curECGItem.dtcDate.month,_curECGItem.dtcDate.day,_curECGItem.dtcDate.hour,_curECGItem.dtcDate.minute,_curECGItem.dtcDate.second];
    NSString *time = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",_curECGItem.dtcDate.year,(long)_curECGItem.dtcDate.month,_curECGItem.dtcDate.day,_curECGItem.dtcDate.hour,_curECGItem.dtcDate.minute,_curECGItem.dtcDate.second];
    
    NSString *description = ecgResultDescrib(_curECGItem.innerData.ecgResultDescrib);
    if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
        NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
        description = [NSString stringWithFormat:@"%@\n%@", strArr[0],strArr[1]];
    }else{ //只有一条描述
        
    }
    
    NSString *st;
    if (_curECGItem.enLeadKind==kLeadKind_Hand||_curECGItem.enLeadKind==kLeadKind_Chest) {
        //                          0x01                                        0x02
        st = @"--";
    }else{
        if (_curECGItem.enPassKind==kPassKind_Others) {
            st = @"--";
        }else{
            st = [NSString stringWithFormat:@"%@%@",(_curECGItem.innerData.ST>=0?(@"+"):@""),DOUBLE2_TO_STRING(((double)_curECGItem.innerData.ST)/100.0)];
        }
    }
    
    NSString *hr = INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.innerData.HR);
    NSString *qrs = INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.innerData.QRS);
    NSString *qtcStr = (_curECGItem.innerData.QTc > 260 && _curECGItem.innerData.QTc < 600) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.innerData.QTc): @"--";
    //        NSString *qtStr = (_curECGItem.innerData.QT > 200 && _curECGItem.innerData.QT < 900) ? INT_TO_STRING_WITHOUT_ERR_NUM(_curECGItem.innerData.QT): @"--";
    
    int _hr  = _curECGItem.innerData.HR;
    NSString *pr;
    if (_hr == 0) {
        pr = @"--";
    } else {
        pr = [NSString stringWithFormat:@"%.1f",60.0 / _hr];
    }
    
    
    NSString *status;
    NSString *status1;
    
    if(_curECGItem.innerData.enFilterKind == kFilterKind_Normal){
        
        status = @"N";
        status1 = @"Normal";
    }else{
        
        status = @"A";
        status1 = @"Abnormal";
    }
    
    int hrValue = [[NSString stringWithFormat:@"%d",_curECGItem.HR] intValue];
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
    jsonstr = [NSString stringWithFormat:@"{\"resourceType\":\"Observation\",\"id\":\"Heart Activity\",\"identifier\":{\"system\":\"https://cloud.viatomtech.com/fhir\",\"value\":\"%@\"},\"category\":{\"coding\":{\"system\":\"http://hl7.org/fhir/observation-category\",\"code\":\"procedure\",\"display\":\"Procedure\"}},\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131328\",\"display\":\"MDC_ECG_ELEC_POTL\"}},\"effectiveDateTime\":\"%@\",\"interpretation\":{\"coding\":{\"system\":\"http://hl7.org/fhir/v2/0078\",\"code\":\"%@\",\"display\":\"%@\"},\"text\":\"%@\"},\"component\":[{\"code\":{\"coding\":{\"system\":\"http://loinc.org\",\"code\":\"8867-4\",\"display\":\"Heart rate\"}},\"valueQuantity\":{\"value\":\"%@\",\"unit\":\"/min\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"{beats}/min\"}},{\"code\":{\"coding\":{\"system\":\"urn:oid:2.16.840.1.113883.6.24\",\"code\":\"131329\",\"display\":\"MDC_ECG_ELEC_POTL_I\"}},\"valueString\":\"%@\"}]}",str1,time,status,status1,ecgStrResult,hr,_curECGItem.innerData.dataStr];;
    
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
    model.detedStr = [NSString stringWithFormat:@"%@%@",itemStr,_curDirName];
    NSArray *array = [CloudModel findByCriteria:[NSString stringWithFormat:@"where jsonStr = '%@'",jsonstr]];
    if (array.count == 0) {
        
        if(_curUser.ID != 1){
            [model save];
        }
    }
    [[CloudUpLodaManger sharedManager] noticeUpdata];
}

- (void)onECGDetailDataDownloadTimeout
{
    DLog(@"进入ECG详情下载超时处理函数");
    [self refreshCellView];
    [_progressView removeFromSuperview];
    _enter.hidden = NO;
}

- (void)onECGDetailDataDownloadProgress:(double)progress
{
    if(_progressView){
        [_progressView setProgress:progress animated:YES];
    }
}

-(void)initProgress
{
    if (_curECGItem.bDownloadIng) {
        _enter.hidden = YES;
        double bondSize = 35;
        CGRect bond = CGRectMake(_enter.frame.origin.x+((_enter.frame.size.width-bondSize)/2), self.frame.size.height/2-bondSize/2, bondSize, bondSize);
        _progressView = [[UAProgressView alloc] initWithFrame:bond];
        [self addSubview:_progressView];
        DLog(@"初始化pro");
    }
}

//因为cell在tableview中复用，所以要动态刷新pro
-(void)refreshProgressVisibility
{
    if (_curECGItem.bDownloadIng) {
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
