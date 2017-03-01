//
//  ECGInfoItem.m
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "ECGInfoItem.h"
#import "FileParser.h"
#import "PublicUtils.h"

@implementation ECGInfoItem
@synthesize dtcDate = _dtcDate;
@synthesize enLeadKind = _enLeadKind;
@synthesize bHaveVoiceMemo = _bHaveVoiceMemo;
@synthesize enPassKind = _enPassKind;
@synthesize userID = _userID;
@synthesize innerData = _innerData;

@synthesize downloadProgress = _downloadProgress;
@synthesize bDownloadIng = _bDownloadIng;

@synthesize dataVoice = _dataVoice;
@synthesize HR = _HR;

-(id)init
{
    self = [super init];
    if(self){

        //_innerData = [[ECGInfoItem_InnerData alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dtcDate forKey:@"dtcDate"];
    [aCoder encodeInt:self.enLeadKind forKey:@"enLeadKind"];
    [aCoder encodeInt:self.enPassKind forKey:@"passKind"];
    [aCoder encodeObject:self.innerData forKey:@"innerData"];
    [aCoder encodeBool:self.bHaveVoiceMemo forKey:@"haveVoice"];
    [aCoder encodeObject:self.dataVoice forKey:@"voice"];
    [aCoder encodeInt:self.HR forKey:@"ecg_HR"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.dtcDate = [aDecoder decodeObjectForKey:@"dtcDate"];
        self.enLeadKind = [aDecoder decodeIntForKey:@"enLeadKind"];
        self.enPassKind = [aDecoder decodeIntForKey:@"passKind"];
        self.innerData = [aDecoder decodeObjectForKey:@"innerData"];
        self.bHaveVoiceMemo = [aDecoder decodeBoolForKey:@"haveVoice"];
        self.dataVoice = [aDecoder decodeObjectForKey:@"voice"];
        self.HR = [aDecoder decodeIntForKey:@"ecg_HR"];
    }
    return self;
}


//定义的一个静态的数组
+(NSString *)ecgTypeDescrib:(U8)diagnose
{
    static NSString *describs[] =
    {
        @"------",
        @"Irregular ECG",
        @"Artifact",
        @"Aberrant Beat",
        @"Asystole",
        @"Bradycardia",
        @"Tachycardia",
        @"Ventricular Fibrillation/Flutter",
        @"Ventricular Tachycardia",
        @"Ventricular Run",
        @"Ventricular Couplet",
        @"Ventricular Bigeminy",
        @"Ventricular Escape Beat",
        @"Premature Ventricular Contraction",
        @"Early PVC",
        @"Multiform PVCs",
        @"Supraventricular Arrhythmia",
        @"Paroxysmal Supraventricular Tachycardia",
        @"Premature Supraventricular Contraction",
        @"Pause of 2 missed beats",
        @"Pause of 1 missed beat",
        @"Pause",
        @"Absolute Pause",
        @"Learn QRS complex",
        @"New Form"
    };
    
    return describs[diagnose];
}

+(NSString *)pvcsDescrib:(U16)pvcs
{
    NSString *describ = @"";
#define IN_ARRANGE(v,arange_l,arragne_h) ((v)>= arange_l && (v)<=arragne_h)
   if(IN_ARRANGE(pvcs,0,1))
   {
       describ = @"Normal";
   }
    else if(IN_ARRANGE(pvcs, 2, 9))
    {
        describ = @"High";
    }
    else
    {
        describ = @"Very High";
    }
    return describ;
}

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind leadKind:(LeadKind_t)leadKind
{
    BOOL bMatch = NO;
    if((leadKind & _enLeadKind) != 0){

        if((typeKind & kTypeForFilter_Pass) != 0)
        {
            if(_enPassKind == kPassKind_Pass)
                bMatch = YES;
        }
        if((typeKind & kTypeForFilter_Fail) != 0)
        {
            if(_enPassKind == kPassKind_Fail)
                bMatch = YES;
        }
        //不能分析的暂时不筛选掉
        if (_enPassKind == kPassKind_Others) {
            bMatch = YES;
        }
        
    }
        return bMatch;
}

//开始下载
-(void)beginDownloadDetail
{
    _bDownloadIng = YES;
    _downloadProgress = 0.0;

    [BTCommunication sharedInstance].delegate = self;
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_EcgDetailData] fileType:FILE_Type_EcgDetailData];
}

-(void)beginDownloadVoice
{
    _bDownloadIng = YES;
    _downloadProgress = 0.0;
    
#if __ECG_DATA_TEST__
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除通知中心中的所有通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFileLoadFinishNtf:) name:NtfName_FileLoadedFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressUpdateNtf:) name:NtfName_ProgressUpdate object:nil];
    NSString *voiceDataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_voice.wav"];
    NSData *voiceData = [NSData dataWithContentsOfFile:voiceDataPath];
    FileToLoad *file = [[FileToLoad alloc] init];
    file.fileType = FILE_Type_ECGVoiceData;
    file.enLoadResult = kFileLoadResult_Success;
    file.fileData = [NSMutableData dataWithBytes:voiceData.bytes length:voiceData.length];
    NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:file, Key_FileLoadedFinish_Content,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FileLoadedFinish object:self userInfo:usrInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _bDownloadIng = NO;
#else
    [BTCommunication sharedInstance].delegate = self;
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_ECGVoiceData] fileType:FILE_Type_ECGVoiceData];
#endif
}

- (void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    _bDownloadIng = NO;
    

    if(fileData.enLoadResult == kFileLoadResult_TimeOut)
    {
        _downloadProgress = 0;
        //提示
        [PublicMethods msgBoxWithMessage:[fileData loadStateDesc]];
        
        if(fileData.fileType == FILE_Type_EcgDetailData)
        {
            if(self.ecgDelegate && [self.ecgDelegate respondsToSelector:@selector(onECGDetailDataDownloadTimeout)]) {
                
                [self.ecgDelegate onECGDetailDataDownloadTimeout];
                
            }
        }
        else if(fileData.fileType == FILE_Type_ECGVoiceData)
        {
            if(self.ecgDelegate && [self.ecgDelegate respondsToSelector:@selector(onECGDetailDataDownloadTimeout)]) {
                
                [self.ecgDelegate onECGDetailDataDownloadTimeout];
                
            }
        }
        self.ecgDelegate = nil;
        return;
    }
    
    if(fileData.fileType == FILE_Type_EcgDetailData)
    {
        _downloadProgress = 1.0;
        if(self.ecgDelegate && [self.ecgDelegate respondsToSelector:@selector(onECGDetailDataDownloadSuccess:)]) {
            
            [self.ecgDelegate onECGDetailDataDownloadSuccess:fileData];
            
        }
    }
    else if(fileData.fileType == FILE_Type_ECGVoiceData)
    {
        _downloadProgress = 1.0;
        self.dataVoice = fileData.fileData;
        if( self.ecgDelegate && [self.ecgDelegate respondsToSelector:@selector(onECGDetailDataDownloadSuccess:)]) {
            
            [self.ecgDelegate onECGDetailDataDownloadSuccess:fileData];
            
        }
    }
    self.ecgDelegate = nil;
}

- (void)postCurrentReadProgress:(double)progress
{
    self.downloadProgress = progress;
   
    if(self.ecgDelegate && [self.ecgDelegate respondsToSelector:@selector(onECGDetailDataDownloadProgress:)]) {
        
        [self.ecgDelegate onECGDetailDataDownloadProgress:progress];
        
    }
}
@end
