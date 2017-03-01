//
//  HealthKitManager.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/4/7.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "HKHealthStore+AAPLExtensions.h"

@import HealthKit;

@interface HealthKitManager : NSObject

//HK
@property (nonatomic) HKHealthStore *healthStore;

+ (HealthKitManager *) defaultHKManager;

// 判断和存储identifier   防止数据重复存储到HK
- (BOOL)isSavedToHealthStoreWithIdentifier:(NSString *)identifier withCurUserName:(NSString *)curUserName;
- (void) saveHKIdentifierToInfoPlistWithIdentifier:(NSString *)identifier;

//存储
- (void) saveHeartRateValueToHealthStoreWithHR:(int) heartRate andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier;
- (void) saveSpo2ValueToHealthStoreWithSpo2:(int)spo2 andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier;
- (void) saveBPsysValueToHealthStoreWithBPsys:(int)bpSYS andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier;
- (void) saveHeightValueToHealthStoreWithInfoPlistIdentifier:(NSString *)identifier;
- (void) saveWeightValueToHealthStoreWithInfoPlistIdentifier:(NSString *)identifier;
- (void)saveTempValueToHealthStoreWithTemp:(double)temp andDtc:(NSDateComponents *)dtc andIsCelsiusUnit:(BOOL)isCelsiusUnit withInfoPlistIdentifier:(NSString *)identifier;
- (void) saveStepsValueToHealthStoreWithSteps:(int)steps andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier;
- (void)saveDistanceValueToHealthStoreWithDistance:(double)distance andDtc:(NSDateComponents *)dtc andIsMetric:(BOOL)isMetric withInfoPlistIdentifier:(NSString *)identifier;
- (void)saveActiveEnergyValueToHealthStoreWithActiveEnergy:(double)activeEnergy andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier;
- (void)saveSleepValueToHealthStoreWithStartDtc:(NSDateComponents *)startDtc andTotalTime:(NSTimeInterval)totalTime withInfoPlistIdentifier:(NSString *)identifier;
@end
