//
//  HKUpdateUtils.m
//  Checkme Mobile
//
//  Created by 李 乾 on 15/5/22.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "HKUpdateUtils.h"
#import "SVProgressHUD.h"
#import "BTCommunication.h"
#import "FileParser.h"
#import "NSDate+Additional.h"
#import "HealthKitManager.h"

@interface HKUpdateUtils () <BTCommunicationDelegate>
@property (nonatomic, strong) User *curUser;
@end

@implementation HKUpdateUtils

+(HKUpdateUtils *)sharedInstance
{
    static HKUpdateUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

- (void)updateAllDataToHealthKitWithUser:(User *)user
{
    _curUser = user;
    
    [SVProgressHUD showWithStatus:@"Synchronizing data to HealthKit..."];     //显示 "数据同步中..."
    //同步用户身高、体重到HealthKit
    [self saveUserInfoToHealthKitWithCurUser:_curUser];
    //请求数据
    [self loadDlcWithUser:_curUser];
}


//加载dlc列表
-(void)loadDlcWithUser:(User *)user
{
    if(![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有在下载别的数据
        [BTCommunication sharedInstance].delegate = self;
        NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_NAME,user.ID];
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_DailyCheckList];
    }
}
//加载ped列表
- (void)loadPedWithUser:(User *)user
{
    if (![[BTCommunication sharedInstance] bLoadingFileNow]) {
        [BTCommunication sharedInstance].delegate = self;
        NSString* fileName = [NSString stringWithFormat:PED_FILE_NAME,user.ID];
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_PedList];
    }
}

#pragma mark - BTCommunication delegate
- (void)postCurrentReadProgress:(double)progress
{
    return;
}

-(void)readCompleteWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    
    if(fileData.fileType == FILE_Type_DailyCheckList) {
        if(fileData.enLoadResult == kFileLoadResult_TimeOut){
            //  timeOut
            //请求Pedometer处的数据
            [self loadPedWithUser:_curUser];
        }else {
            // 解析
            NSArray *arr = [FileParser parseDlcList_WithFileData:fileData.fileData];
            for (DailyCheckItem *dlcItem in arr) {
                //保存 HR、SpO2、BP数据到HealthKit
                [self saveHR_SpO2_BPToHealthKitWithDLCItem:dlcItem andUser:_curUser];
            }
            
            //再请求Pedometer处的数据
            [self loadPedWithUser:_curUser];
        }
    } else if (fileData.fileType == FILE_Type_PedList) {
        if (fileData.enLoadResult == kFileLoadResult_TimeOut) {
            //timeOut
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Synchronization done", nil)  duration:1.5];
            });
            
        } else {
            //解析
            NSArray *arr = [FileParser parsePedList_WithFileData:fileData.fileData];
            for (PedInfoItem *pedItem in arr) {
                // 保存计步相关的数据到HealthKit
                [self savePedDataToHealthKitWithPedItem:pedItem andUser:_curUser];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Synchronization done", nil) duration:1.5];
        });
        
    }
}


//保存用户身高、体重数据到HealthKit
- (void) saveUserInfoToHealthKitWithCurUser:(User *)user
{
    NSDate *now = [NSDate date];
    
    //height
    NSString *str_h = [NSString stringWithFormat:@"height_%@_%.4f", [NSDate dateDescFromDate:now], user.height];
    if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_h withCurUserName:user.name]) {   //如果上次身高值没变就只存一次   变了再次存储
        [[HealthKitManager defaultHKManager] saveHeightValueToHealthStoreWithInfoPlistIdentifier:str_h];
    }
    //weight
    NSString *str_w = [NSString stringWithFormat:@"weight_%@_%.4f", [NSDate dateDescFromDate:now], user.weight];
    if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_w withCurUserName:user.name]) {
        [[HealthKitManager defaultHKManager] saveWeightValueToHealthStoreWithInfoPlistIdentifier:str_w];
    }
}

//保存心电、血氧数据到HealthKit
- (void) saveHR_SpO2_BPToHealthKitWithDLCItem:(DailyCheckItem *)dlcItem andUser:(User *)user
{
    //存储HR到HK
    if (dlcItem.HR) {
        NSString *str_hr = [NSString stringWithFormat:@"%@_hr",[NSDate dateDescFromDateComp:dlcItem.dtcDate]];
        if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_hr withCurUserName:user.name]) {
            [[HealthKitManager defaultHKManager] saveHeartRateValueToHealthStoreWithHR:dlcItem.HR andDtc:dlcItem.dtcDate withInfoPlistIdentifier:str_hr];   //存到HK
        }
    }
    
    //存储SpO2到HK
    if (dlcItem.SPO2) {
        NSString *str_spo2 = [NSString stringWithFormat:@"%@_spo2",[NSDate dateDescFromDateComp:dlcItem.dtcDate]];
        if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_spo2 withCurUserName:user.name]) {
            [[HealthKitManager defaultHKManager] saveSpo2ValueToHealthStoreWithSpo2:dlcItem.SPO2 andDtc:dlcItem.dtcDate withInfoPlistIdentifier:str_spo2];
        }
    }
    
    //存储BP到HK
    if (dlcItem.BP && dlcItem.BP != 0xff) {
        NSString *str_bp = [NSString stringWithFormat:@"%@_bp",[NSDate dateDescFromDateComp:dlcItem.dtcDate]];
        if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_bp withCurUserName:user.name]) {
            [[HealthKitManager defaultHKManager] saveBPsysValueToHealthStoreWithBPsys:dlcItem.BP andDtc:dlcItem.dtcDate withInfoPlistIdentifier:str_bp];   //存到HK
        }
    }
}

//保存计步相关的数据到HK
- (void) savePedDataToHealthKitWithPedItem:(PedInfoItem *)pedItem andUser:(User *)user
{
    //存储steps数据到HK
    if (pedItem.step) {
        NSString *str_steps = [NSString stringWithFormat:@"%@_step", [NSDate dateDescFromDateComp:pedItem.dtcMeasureTime]];
        if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_steps withCurUserName:user.name]) {
            [[HealthKitManager defaultHKManager] saveStepsValueToHealthStoreWithSteps:pedItem.step andDtc:pedItem.dtcMeasureTime withInfoPlistIdentifier:str_steps];
        }
    }
    
    //存储卡路里数据到HK
    if (pedItem.calorie) {
        //HK
        NSString *str_calorie = [NSString stringWithFormat:@"%@_calorie", [NSDate dateDescFromDateComp:pedItem.dtcMeasureTime]];
        if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_calorie withCurUserName:user.name]) {
            [[HealthKitManager defaultHKManager] saveActiveEnergyValueToHealthStoreWithActiveEnergy:pedItem.calorie andDtc:pedItem.dtcMeasureTime withInfoPlistIdentifier:str_calorie];
        }
    }
    
    
    // 先获取当前选择的单位
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Unit"];
    if (!index) {
        index = 0;
    }
    
    //存储distance到HK
    if (index == 0) {
        if (pedItem.distance) {
            NSString *str_distance = [NSString stringWithFormat:@"%@_distance", [NSDate dateDescFromDateComp:pedItem.dtcMeasureTime]];
            if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_distance withCurUserName:user.name]) {
                [[HealthKitManager defaultHKManager] saveDistanceValueToHealthStoreWithDistance:pedItem.distance andDtc:pedItem.dtcMeasureTime andIsMetric:YES withInfoPlistIdentifier:str_distance];
            }
        }
        
    } else if (index == 1) {
        if (pedItem.distance) {
            NSString *str_distance = [NSString stringWithFormat:@"%@_distance", [NSDate dateDescFromDateComp:pedItem.dtcMeasureTime]];
            if ([[HealthKitManager defaultHKManager] isSavedToHealthStoreWithIdentifier:str_distance withCurUserName:user.name]) {
                [[HealthKitManager defaultHKManager] saveDistanceValueToHealthStoreWithDistance:(pedItem.distance * 0.621371) andDtc:pedItem.dtcMeasureTime andIsMetric:NO withInfoPlistIdentifier:str_distance];
            }
        }
    }
}
@end
