//
//  SLMItem.m
//  BTHealth
//
//  Created by snake on 14-4-7.
//  Copyright (c) 2014年 LongVision's Mac02. All rights reserved.
//

#import "SLMItem.h"
#import "FileParser.h"
#import "PublicUtils.h"

@implementation SLMItem_InnerData

-(id)init
{
    self  = [super init];
    if(self)
    {
        self.arrOXValue = [NSMutableArray arrayWithCapacity:10];
        self.arrPluseValue = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.arrOXValue forKey:@"arrOX"];
    [aCoder encodeObject:self.arrPluseValue forKey:@"arrPluse"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.arrOXValue = [aDecoder decodeObjectForKey:@"arrOX"];
        self.arrPluseValue = [aDecoder decodeObjectForKey:@"arrPluse"];
    }
    return self;
}
@end

@implementation SLMItem

-(id)init
{
    self = [super init];
    if(self){
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dtcStartDate forKey:@"dtcStart"];
    [aCoder encodeInt32:self.totalTime forKey:@"totalTime"];
    [aCoder encodeInt:self.LO2Time forKey:@"lo2Time"];
    [aCoder encodeInt:self.LO2Count forKey:@"lo2Count"];
    [aCoder encodeInt:self.LO2Value forKey:@"lo2Value"];
    [aCoder encodeInt:self.AverageSpo2 forKey:@"average"];
    [aCoder encodeObject:self.innerData forKey:@"slm_innerData"];
    
//    
//    [aCoder encodeInt:self.enPassKind forKey:@"enPass"];
//    [aCoder encodeInt:self.userID forKey:@"userID"];
//    [aCoder encodeBool:self.bDownloadIng forKey:@"bDown"];
//    [aCoder encodeDouble:self.downloadProgress forKey:@"downP"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.dtcStartDate = [aDecoder decodeObjectForKey:@"dtcStart"];
        self.totalTime = [aDecoder decodeInt32ForKey:@"totalTime"];
        self.LO2Time = [aDecoder decodeIntForKey:@"lo2Time"];
        self.LO2Count = [aDecoder decodeIntForKey:@"lo2Count"];
        self.LO2Value = [aDecoder decodeIntForKey:@"lo2Value"];
        self.AverageSpo2 = [aDecoder decodeIntForKey:@"average"];
        self.innerData = [aDecoder decodeObjectForKey:@"slm_innerData"];
        
//        self.enPassKind = [aDecoder decodeIntForKey:@"enPass"];
//        self.userID = [aDecoder decodeIntForKey:@"userID"];
//        self.bDownloadIng = [aDecoder decodeBoolForKey:@"bDown"];
//        self.downloadProgress = [aDecoder decodeDoubleForKey:@"downP"];
     }
    return self;
}


-(void)dealloc
{
  //都是使用的是,自动内存管理..不需要对内存进行销毁操作
}

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind
{
    BOOL bMatch = NO;
    if(1){        
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

-(void)beginDownloadDetail
{
    _bDownloadIng = YES;
    _downloadProgress = 0.0;

    [BTCommunication sharedInstance].delegate = self;
    [[BTCommunication sharedInstance] BeginReadFileWithFileName: [PublicUtils MakeDateFileName:_dtcStartDate fileType:FILE_Type_SleepMonitorDetailData] fileType:FILE_Type_SleepMonitorDetailData];
}

- (void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    DLog(@"进入SLM-Item下载完成处理函数");
    _bDownloadIng = NO;
    
    if(fileData.enLoadResult == kFileLoadResult_TimeOut)
    {
        _downloadProgress = 0;
        if(fileData.fileType == FILE_Type_SleepMonitorDetailData)
        {
            [self.slmDelegate onSLMDetailDataDownloadTimeout];
        }
        return;
    }
        
    if(fileData.fileType == FILE_Type_SleepMonitorDetailData)
    {
        _downloadProgress = 1.0;
        [self.slmDelegate onSLMDetailDataDownloadSuccess:fileData];
    }
    self.slmDelegate = nil;
}

- (void)postCurrentReadProgress:(double)progress
{
    self.downloadProgress = progress;
    [self.slmDelegate onSLMDetailDataDownloadProgress:progress];
}


@end

