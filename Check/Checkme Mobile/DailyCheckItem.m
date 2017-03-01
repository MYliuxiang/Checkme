//
//  DailyCheckItem.m
//  BTHealth
//
//  Created by snake on 14-4-7.
//  Copyright (c) 2014年 LongVision's Mac02. All rights reserved.
//

#import "DailyCheckItem.h"
#import "FileParser.h"
#import "PublicUtils.h"

@implementation ECGInfoItem_InnerData
@synthesize arrEcgContent = _arrEcgContent;
@synthesize arrEcgHeartRate = _arrEcgHeartRate;
@synthesize HR = _HR;
@synthesize ST = _ST;
@synthesize QRS = _QRS;
@synthesize PVCs = _PVCs;
@synthesize QTc = _QTc;
@synthesize ECG_Type = _ECG_Type;
@synthesize ecgResultDescrib = _ecgResultDescrib;

-(id)init
{
    self  = [super init];
    if(self)
    {
        self.arrEcgContent = [NSMutableArray arrayWithCapacity:10];
        self.arrEcgHeartRate = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

//使用归档的方式(注意: 需要遵守 NSCoding 的协议)
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.arrEcgContent forKey:@"content"];
    [aCoder encodeObject:self.arrEcgHeartRate forKey:@"heartRate"];
    [aCoder encodeInt:self.HR forKey:@"HR"];
    [aCoder encodeInt:self.ST forKey:@"ST"];
    [aCoder encodeInt:self.QRS forKey:@"QRS"];
    [aCoder encodeInt:self.PVCs forKey:@"PVCs"];
    [aCoder encodeInt:self.QTc forKey:@"QTc"];
    [aCoder encodeInt:self.ECG_Type forKey:@"ECG_Type"];
    [aCoder encodeObject:self.ecgResultDescrib forKey:@"ecgResult"];
    [aCoder encodeInt32:self.timeLength forKey:@"timeLength"];
    [aCoder encodeInt:self.enFilterKind forKey:@"enFilter"];
    [aCoder encodeInt:self.enLeadKind forKey:@"enLead"];
    [aCoder encodeObject:self.dataStr forKey:@"dataStr"];

    
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.arrEcgContent = [aDecoder decodeObjectForKey:@"content"];
        self.arrEcgHeartRate = [aDecoder decodeObjectForKey:@"heartRate"];
        self.HR = [aDecoder decodeIntForKey:@"HR"];
        self.ST = [aDecoder decodeIntForKey:@"ST"];
        self.QRS = [aDecoder decodeIntForKey:@"QRS"];
        self.PVCs = [aDecoder decodeIntForKey:@"PVCs"];
        self.QTc = [aDecoder decodeIntForKey:@"QTc"];
        self.ECG_Type = [aDecoder decodeIntForKey:@"ECG_Type"];
        self.ecgResultDescrib = [aDecoder decodeObjectForKey:@"ecgResult"];
        self.timeLength = [aDecoder decodeInt32ForKey:@"timeLength"];
        self.enFilterKind = [aDecoder decodeIntForKey:@"enFilter"];
        self.enLeadKind = [aDecoder decodeIntForKey:@"enLead"];
        self.dataStr = [aDecoder decodeObjectForKey:@"dataStr"];

    }
    return self;
}

@end

@implementation DailyCheckItem
{
    NSString *_periphralName;
     int curUserID;
}
@synthesize dtcDate = _dtcDate;
@synthesize bHaveVoiceMemo = _bHaveVoiceMemo;
@synthesize enPassKind = _enPassKind;
@synthesize userID = _userID;
@synthesize innerData = _innerData;

@synthesize downloadProgress = _downloadProgress;
@synthesize bDownloadIng = _bDownloadIng;

@synthesize dataVoice = _dataVoice;

-(id)init
{
    self = [super init];
    if(self){
        
        //_innerData = [[ECGInfoItem_InnerData alloc] init];
    }
    return self;
}

//归档
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dtcDate forKey:@"dtcDate"];
    [aCoder encodeInt:self.enPassKind forKey:@"enPassKind"];
    [aCoder encodeInt:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.innerData forKey:@"innerData"];
    [aCoder encodeBool:self.bDownloadIng forKey:@"bDownloading"];
    [aCoder encodeDouble:self.downloadProgress forKey:@"progress"];
    [aCoder encodeObject:self.dataVoice forKey:@"voice"];
    [aCoder encodeInt:self.HR forKey:@"dlc_HR"];
    [aCoder encodeInt:self.ECG_R forKey:@"ecg_r"];
    [aCoder encodeInt:self.SPO2 forKey:@"spo2"];
    [aCoder encodeDouble:self.PI forKey:@"pi"];
    [aCoder encodeInt:self.SPO2_R forKey:@"spo2_r"];
    [aCoder encodeInt:self.BP_Flag forKey:@"bp_flag"];
    [aCoder encodeInt:self.BP forKey:@"bp"];
    [aCoder encodeInt:self.BPI_R forKey:@"bpi_r"];
    [aCoder encodeBool:self.bHaveVoiceMemo forKey:@"bHaveVoice"];
    [aCoder encodeInt:self.RPP forKey:@"body_rpp"];
    [aCoder encodeInt:self.RR forKey:@"RR"];
    
}


//解档  （需要注意的是.先要遵守NSCoding 协议）
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
     
        self.dtcDate = [aDecoder decodeObjectForKey:@"dtcDate"];
        self.enPassKind = [aDecoder decodeIntForKey:@"enPassKind"];
        self.userID = [aDecoder decodeIntForKey:@"userID"];
        self.innerData = [aDecoder decodeObjectForKey:@"innerData"];
        self.bDownloadIng = [aDecoder decodeBoolForKey:@"bDownloading"];
        self.downloadProgress = [aDecoder decodeDoubleForKey:@"progress"];
        self.dataVoice = [aDecoder decodeObjectForKey:@"voice"];
        self.HR = [aDecoder decodeIntForKey:@"dlc_HR"];
        self.ECG_R = [aDecoder decodeIntForKey:@"ecg_r"];
        self.SPO2 = [aDecoder decodeIntForKey:@"spo2"];
        self.PI = [aDecoder decodeDoubleForKey:@"pi"];
        self.SPO2_R = [aDecoder decodeIntForKey:@"spo2_r"];
        self.BP_Flag = [aDecoder decodeIntForKey:@"bp_flag"];
        self.BP = [aDecoder decodeIntForKey:@"bp"];
        self.BPI_R = [aDecoder decodeIntForKey:@"bpi_r"];
        self.bHaveVoiceMemo = [aDecoder decodeBoolForKey:@"bHaveVoice"];
        self.RPP = [aDecoder decodeIntForKey:@"body_rpp"];
        self.RR = [aDecoder decodeIntForKey:@"RR"];

        
        
    }
    return self;
}

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind
{
    BOOL bMatch = NO;
    if(1){
        if((typeKind & kTypeForFilter_Pass) != 0)
        {
            if(_ECG_R == kPassKind_Pass)
                bMatch = YES;
        }
        if((typeKind & kTypeForFilter_Fail) != 0)
        {
            if(_ECG_R == kPassKind_Fail)
                bMatch = YES;
        }
        //不能分析暂不去掉
        if(_ECG_R==kPassKind_Others){
            bMatch = YES;
        }
    }
    return bMatch;
}


//开始下载..
-(void)beginDownloadDetail
{
    [BTCommunication sharedInstance].delegate = self;
    _bDownloadIng = YES;
    _downloadProgress = 0.0;//刚开始下载时,进度条走过的进度(0%)
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_EcgDetailData] fileType:FILE_Type_EcgDetailData];
}

//下载时的下载声音
-(void)beginDownloadVoice
{
    [BTCommunication sharedInstance].delegate = self;
    _bDownloadIng = YES;
    _downloadProgress = 0.0;
#if __ECG_DATA_TEST__

    NSString *voiceDataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_voice.wav"];//拼接一个下载时的声音路径
    NSData *voiceData = [NSData dataWithContentsOfFile:voiceDataPath];//数据处理
    FileToLoad *file = [[FileToLoad alloc] init];//这里查看不了它内部实现的代理源码...
    //FileToRead  文件读取操作
    file.fileType = FILE_Type_ECGVoiceData;
    file.enLoadResult = kFileLoadResult_Success;
    file.fileData = [NSMutableData dataWithBytes:voiceData.bytes length:voiceData.length];
    NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:file, Key_FileLoadedFinish_Content,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FileLoadedFinish object:self userInfo:usrInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _bDownloadIng = NO;
#else
    
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_ECGVoiceData] fileType:FILE_Type_ECGVoiceData];
#endif
}

- (void) readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    _bDownloadIng = NO;
    
    
    //只处理了超时错误
    if(fileData.enLoadResult == kFileLoadResult_TimeOut)
    {
        _downloadProgress = 0;//下载的进度条
        //提示
        [PublicMethods msgBoxWithMessage:[fileData loadStateDesc]];
     
        NSLog(@"失败");
        if(fileData.fileType == FILE_Type_EcgDetailData)
        {
            if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.dlcDelegate onDlcDetailDataDownloadTimeout];
                
            }
            
        }
        else if(fileData.fileType == FILE_Type_ECGVoiceData)
        {
            if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.dlcDelegate onDlcDetailDataDownloadTimeout];
                
            }
        }
        self.dlcDelegate = nil;
        return;
    }
    
    
    
    if(fileData.fileType == FILE_Type_EcgDetailData)
    {
        NSLog(@"下载成功了");
        
        _downloadProgress = 1.0;//下载成功的进度条的值
        
        if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
             [self.dlcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
        
    }else if (fileData.fileType == FILE_Type_ECGVoiceData) {
        _downloadProgress = 1.0;
        
        self.dataVoice = fileData.fileData;
        if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
            [self.dlcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
        
    }
    self.dlcDelegate = nil;
}

- (void)postCurrentReadProgress:(double)progress
{
    _downloadProgress = progress;
    if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadProgress:)]) {
        
        [self.dlcDelegate onDlcDetailDataDownloadProgress:progress];
    }
   
}


@end

@implementation OldDailyCheckItem
{
    NSString *_periphralName;
    int curUserID;
}
@synthesize dtcDate = _dtcDate;
@synthesize bHaveVoiceMemo = _bHaveVoiceMemo;
@synthesize enPassKind = _enPassKind;
@synthesize userID = _userID;
@synthesize innerData = _innerData;

@synthesize downloadProgress = _downloadProgress;
@synthesize bDownloadIng = _bDownloadIng;

@synthesize dataVoice = _dataVoice;

-(id)init
{
    self = [super init];
    if(self){
        
        //_innerData = [[ECGInfoItem_InnerData alloc] init];
    }
    return self;
}

//归档
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dtcDate forKey:@"dtcDate"];
    [aCoder encodeInt:self.enPassKind forKey:@"enPassKind"];
    [aCoder encodeInt:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.innerData forKey:@"innerData"];
    [aCoder encodeBool:self.bDownloadIng forKey:@"bDownloading"];
    [aCoder encodeDouble:self.downloadProgress forKey:@"progress"];
    [aCoder encodeObject:self.dataVoice forKey:@"voice"];
    [aCoder encodeInt:self.HR forKey:@"dlc_HR"];
    [aCoder encodeInt:self.ECG_R forKey:@"ecg_r"];
    [aCoder encodeInt:self.SPO2 forKey:@"spo2"];
    [aCoder encodeDouble:self.PI forKey:@"pi"];
    [aCoder encodeInt:self.SPO2_R forKey:@"spo2_r"];
    [aCoder encodeInt:self.BP_Flag forKey:@"bp_flag"];
    [aCoder encodeInt:self.BP forKey:@"bp"];
    [aCoder encodeInt:self.BPI_R forKey:@"bpi_r"];
    [aCoder encodeBool:self.bHaveVoiceMemo forKey:@"bHaveVoice"];
    [aCoder encodeInt:self.RPP forKey:@"body_rpp"];
    
}


//解档  （需要注意的是.先要遵守NSCoding 协议）
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.dtcDate = [aDecoder decodeObjectForKey:@"dtcDate"];
        self.enPassKind = [aDecoder decodeIntForKey:@"enPassKind"];
        self.userID = [aDecoder decodeIntForKey:@"userID"];
        self.innerData = [aDecoder decodeObjectForKey:@"innerData"];
        self.bDownloadIng = [aDecoder decodeBoolForKey:@"bDownloading"];
        self.downloadProgress = [aDecoder decodeDoubleForKey:@"progress"];
        self.dataVoice = [aDecoder decodeObjectForKey:@"voice"];
        self.HR = [aDecoder decodeIntForKey:@"dlc_HR"];
        self.ECG_R = [aDecoder decodeIntForKey:@"ecg_r"];
        self.SPO2 = [aDecoder decodeIntForKey:@"spo2"];
        self.PI = [aDecoder decodeDoubleForKey:@"pi"];
        self.SPO2_R = [aDecoder decodeIntForKey:@"spo2_r"];
        self.BP_Flag = [aDecoder decodeIntForKey:@"bp_flag"];
        self.BP = [aDecoder decodeIntForKey:@"bp"];
        self.BPI_R = [aDecoder decodeIntForKey:@"bpi_r"];
        self.bHaveVoiceMemo = [aDecoder decodeBoolForKey:@"bHaveVoice"];
        self.RPP = [aDecoder decodeIntForKey:@"body_rpp"];
        
        
        
    }
    return self;
}

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind
{
    BOOL bMatch = NO;
    if(1){
        if((typeKind & kTypeForFilter_Pass) != 0)
        {
            if(_ECG_R == kPassKind_Pass)
                bMatch = YES;
        }
        if((typeKind & kTypeForFilter_Fail) != 0)
        {
            if(_ECG_R == kPassKind_Fail)
                bMatch = YES;
        }
        //不能分析暂不去掉
        if(_ECG_R==kPassKind_Others){
            bMatch = YES;
        }
    }
    return bMatch;
}


//开始下载..
-(void)beginDownloadDetail
{
    [BTCommunication sharedInstance].delegate = self;
    _bDownloadIng = YES;
    _downloadProgress = 0.0;//刚开始下载时,进度条走过的进度(0%)
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_EcgDetailData] fileType:FILE_Type_EcgDetailData];
}

//下载时的下载声音
-(void)beginDownloadVoice
{
    [BTCommunication sharedInstance].delegate = self;
    _bDownloadIng = YES;
    _downloadProgress = 0.0;
#if __ECG_DATA_TEST__
    
    NSString *voiceDataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_voice.wav"];//拼接一个下载时的声音路径
    NSData *voiceData = [NSData dataWithContentsOfFile:voiceDataPath];//数据处理
    FileToLoad *file = [[FileToLoad alloc] init];//这里查看不了它内部实现的代理源码...
    //FileToRead  文件读取操作
    file.fileType = FILE_Type_ECGVoiceData;
    file.enLoadResult = kFileLoadResult_Success;
    file.fileData = [NSMutableData dataWithBytes:voiceData.bytes length:voiceData.length];
    NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:file, Key_FileLoadedFinish_Content,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FileLoadedFinish object:self userInfo:usrInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _bDownloadIng = NO;
#else
    
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_ECGVoiceData] fileType:FILE_Type_ECGVoiceData];
#endif
}

- (void) readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    _bDownloadIng = NO;
    
    
    //只处理了超时错误
    if(fileData.enLoadResult == kFileLoadResult_TimeOut)
    {
        _downloadProgress = 0;//下载的进度条
        //提示
        [PublicMethods msgBoxWithMessage:[fileData loadStateDesc]];
        
        NSLog(@"失败");
        if(fileData.fileType == FILE_Type_EcgDetailData)
        {
            if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.dlcDelegate onDlcDetailDataDownloadTimeout];
                
            }
            
        }
        else if(fileData.fileType == FILE_Type_ECGVoiceData)
        {
            if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.dlcDelegate onDlcDetailDataDownloadTimeout];
                
            }
        }
        self.dlcDelegate = nil;
        return;
    }
    
    
    
    if(fileData.fileType == FILE_Type_EcgDetailData)
    {
        NSLog(@"下载成功了");
        
        _downloadProgress = 1.0;//下载成功的进度条的值
        
        if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
            [self.dlcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
        
    }else if (fileData.fileType == FILE_Type_ECGVoiceData) {
        _downloadProgress = 1.0;
        
        self.dataVoice = fileData.fileData;
        if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
            [self.dlcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
        
    }
    self.dlcDelegate = nil;
}

- (void)postCurrentReadProgress:(double)progress
{
    _downloadProgress = progress;
    if(self.dlcDelegate && [self.dlcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadProgress:)]) {
        
        [self.dlcDelegate onDlcDetailDataDownloadProgress:progress];
    }
    
}


@end

