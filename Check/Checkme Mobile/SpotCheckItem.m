//
//  SpotCheckItem.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/25.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SpotCheckItem.h"

#import "FileParser.h"
#import "PublicUtils.h"

@implementation spcInner_Data

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
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.arrEcgContent forKey:@"Content"];
    [aCoder encodeObject:self.arrEcgHeartRate forKey:@"HeartRate"];
    [aCoder encodeInt32:self.timeLength forKey:@"TimeLength"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.arrEcgContent = [aDecoder decodeObjectForKey:@"Content"];
        self.arrEcgHeartRate = [aDecoder decodeObjectForKey:@"HeartRate"];
        self.timeLength = [aDecoder decodeInt32ForKey:@"TimeLength"];
    }
    return self;
}

@end

@implementation SpotCheckItem

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_dtcDate forKey:@"_dtcDate"];
    [aCoder encodeObject:_dateStr forKey:@"_dateStr"];
    [aCoder encodeInt:_func forKey:@"_func"];
    [aCoder encodeInt:_HR forKey:@"_HR"];
    [aCoder encodeInt:_QRS forKey:@"_QRS"];
    [aCoder encodeInt:_ST forKey:@"_ST"];
    [aCoder encodeObject:_ecgResult forKey:@"_result"];
    [aCoder encodeInt:_enECG_PassKind forKey:@"_ecgPassK"];
    [aCoder encodeInt:_enOxi_PassKind forKey:@"_oxiPassK"];
    [aCoder encodeInt:_enTemp_PassKind forKey:@"_tempPassK"];
    [aCoder encodeInt:_oxi_R forKey:@"_oxi_R"];
    [aCoder encodeInt:_oxi forKey:@"_oxi"];
    [aCoder encodeDouble:_PI forKey:@"_PI"];
    [aCoder encodeInt:_temp forKey:@"_temp"];
    [aCoder encodeBool:_bDownloadIng forKey:@"_bD"];
    [aCoder encodeBool:_bHaveVoiceMemo forKey:@"_bH"];
    [aCoder encodeDouble:_downloadProgress forKey:@"_D"];
    [aCoder encodeObject:_dataVoice forKey:@"_V"];
    [aCoder encodeBool:_isNoHR forKey:@"_noHR"];
    [aCoder encodeBool:_isNoOxi forKey:@"_noOxi"];
    [aCoder encodeBool:_isNoTemp forKey:@"_noTemp"];
    [aCoder encodeObject:_innerData forKey:@"_Inner"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _dtcDate = [aDecoder decodeObjectForKey:@"_dtcDate"];
        _dateStr = [aDecoder decodeObjectForKey:@"_dateStr"];
        _func = [aDecoder decodeIntForKey:@"_func"];
        _HR = [aDecoder decodeIntForKey:@"_HR"];
        _QRS = [aDecoder decodeIntForKey:@"_QRS"];
        _ST = [aDecoder decodeIntForKey:@"_ST"];
        _ecgResult = [aDecoder decodeObjectForKey:@"_result"];
        _enECG_PassKind = [aDecoder decodeIntForKey:@"_ecgPassK"];
        _enOxi_PassKind = [aDecoder decodeIntForKey:@"_oxiPassK"];
        _enTemp_PassKind = [aDecoder decodeIntForKey:@"_tempPassK"];
        _oxi_R = [aDecoder decodeIntForKey:@"_oxi_R"];
        _oxi = [aDecoder decodeIntForKey:@"_oxi"];
        _PI = [aDecoder decodeDoubleForKey:@"_PI"];
        _temp = [aDecoder decodeIntForKey:@"_temp"];
        _bDownloadIng = [aDecoder decodeBoolForKey:@"_bD"];
        _bHaveVoiceMemo = [aDecoder decodeBoolForKey:@"_bH"];
        _downloadProgress = [aDecoder decodeDoubleForKey:@"_D"];
        _dataVoice = [aDecoder decodeObjectForKey:@"_V"];
        _isNoHR = [aDecoder decodeBoolForKey:@"_noHR"];
        _isNoOxi = [aDecoder decodeBoolForKey:@"_noOxi"];
        _isNoTemp = [aDecoder decodeBoolForKey:@"_noTemp"];
        _innerData = [aDecoder decodeObjectForKey:@"_Inner"];
    }
    return self;
}

- (void)beginDownloadDetail
{
    _bDownloadIng = YES;
    _downloadProgress = 0.0;
    
    [BTCommunication sharedInstance].delegate = self;
    NSString *fileName = [PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_SpcDetailData];  //把日期时间数据转化成字符串
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_SpcDetailData];
}

-(void)beginDownloadVoice;
{
    _bDownloadIng = YES;
    _downloadProgress = 0.0;
    
    [BTCommunication sharedInstance].delegate = self;
    [[BTCommunication sharedInstance] BeginReadFileWithFileName:[PublicUtils MakeDateFileName:_dtcDate fileType:FILE_Type_SpcVoiceData] fileType:FILE_Type_SpcVoiceData];
}

- (void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    _bDownloadIng = NO;
    
    //只处理了超时错误
    if(fileData.enLoadResult == kFileLoadResult_TimeOut)
    {
        _downloadProgress = 0;
        //提示
        [PublicMethods msgBoxWithMessage:[fileData loadStateDesc]];//使用UIAlertView来做到提示效果(但是在iOS9时,弹框提示不使用UIAlertView  跟 UIActioinSheet  将两者的结合体换成了UIAlertController)
        
        if(fileData.fileType == FILE_Type_SpcDetailData)  //0x10
        {
//            [self.spcDelegate onDlcDetailDataDownloadTimeout];
            if(self.spcDelegate && [self.spcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.spcDelegate onDlcDetailDataDownloadTimeout];
                
            }
        }
        else if(fileData.fileType == FILE_Type_SpcVoiceData)
        {
//            [self.spcDelegate onDlcDetailDataDownloadTimeout];
            if(self.spcDelegate && [self.spcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadTimeout)]) {
                
                [self.spcDelegate onDlcDetailDataDownloadTimeout];
                
            }
            
        }
        self.spcDelegate = nil;
        return;
    }
    
    if(fileData.fileType == FILE_Type_SpcDetailData)
    {
        _downloadProgress = 1.0;
//        [self.spcDelegate onDlcDetailDataDownloadSuccess:fileData];
        if(self.spcDelegate && [self.spcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
            [self.spcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
        // 在cell中存储有HR的数据
        
    }else if (fileData.fileType == FILE_Type_SpcVoiceData) {
        _downloadProgress = 1.0;
        self.dataVoice = fileData.fileData;
        
        if(self.spcDelegate && [self.spcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadSuccess:)]) {
            
            [self.spcDelegate onDlcDetailDataDownloadSuccess:fileData];
            
        }
                
    }
    self.spcDelegate = nil;
}
- (void)postCurrentReadProgress:(double)progress
{
    self.downloadProgress = progress;
   
    if(self.spcDelegate && [self.spcDelegate respondsToSelector:@selector(onDlcDetailDataDownloadProgress:)]) {
        
         [self.spcDelegate onDlcDetailDataDownloadProgress:progress];
        
    }

    
}

@end
