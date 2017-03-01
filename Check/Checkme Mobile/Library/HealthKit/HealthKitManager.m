//
//  HealthKitManager.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/4/7.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "HealthKitManager.h"
#import "NSDate+Additional.h"

@implementation HealthKitManager


+(HealthKitManager *)defaultHKManager
{
    static HealthKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        //instance.healthStore = [AppDelegate GetAppDelegate].healthStore;//貌似这种写法错误很多耶。。会获取不到值
        instance.healthStore = [[HKHealthStore alloc]init];
    });
    
    return instance;
}

// 判断identifier   防止数据重复存储到HK
- (BOOL)isSavedToHealthStoreWithIdentifier:(NSString *)identifier withCurUserName:(NSString *)curUserName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];//数据存储
    
    NSString *hkUserName = [ud objectForKey:@"HKUserName"];
    BOOL canBeSaveToHK = NO;
    if ([hkUserName isEqualToString:curUserName]) {
                
        NSArray *hkIdentifiersArr = (NSArray *)[ud objectForKey:@"hkIdentifiers"];

       //对于存储身高值和体重值 单独处理
        if ([identifier hasPrefix:@"height"]) {  //身高值   （hasPrefix 以什么开头 --- 表示前缀是 height 开头的所有内容）
            NSMutableArray *height_value_arr = [NSMutableArray array];
            for (NSString *whole_str in hkIdentifiersArr) {
                NSString *value_str = [[whole_str componentsSeparatedByString:@"_"] lastObject];
                [height_value_arr addObject:value_str];
            }
            NSString *cur_height_value = [[identifier componentsSeparatedByString:@"_"] lastObject];
            if (![height_value_arr containsObject:cur_height_value]) {  //判断当前身高值在已存储的身高值中是否重复  如果没有重复 则可以存储
                canBeSaveToHK = YES;
            }
            
        }else if ([identifier hasPrefix:@"weight"]) {   //体重值
            NSMutableArray *weight_value_arr = [NSMutableArray array];
            for (NSString *whole_str in hkIdentifiersArr) {
                NSString *value_str = [[whole_str componentsSeparatedByString:@"_"] lastObject];
                [weight_value_arr addObject:value_str];
            }
            NSString *cur_weight_value = [[identifier componentsSeparatedByString:@"_"] lastObject];
            if (![weight_value_arr containsObject:cur_weight_value]) {
                canBeSaveToHK = YES;
            }
            
        //其他情况统一处理
        }else {
            if (![hkIdentifiersArr containsObject:identifier]) {   //如果没有存储过此条数据
                canBeSaveToHK = YES;
            }
        }
        
    }
    return canBeSaveToHK;
}

//存储identifier
- (void) saveHKIdentifierToInfoPlistWithIdentifier:(NSString *)identifier
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *mArr = [NSMutableArray array];
    [mArr addObjectsFromArray:(NSArray *)[ud objectForKey:@"hkIdentifiers"]];
    [mArr addObject:identifier];
    NSArray *arr = [NSArray arrayWithArray:mArr];
    [ud setObject:arr forKey:@"hkIdentifiers"];
}

#pragma mark - save to HealthKit
//心电值
- (void)saveHeartRateValueToHealthStoreWithHR:(int)heartRate andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *hrUnit = [HKUnit unitFromString:@"count/min"];
    HKQuantity *hrQuantity = [HKQuantity quantityWithUnit:hrUnit doubleValue:heartRate];
    HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *hrSample = [HKQuantitySample quantitySampleWithType:hrType quantity:hrQuantity startDate:date endDate:date];
    [self.healthStore saveObject:hrSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//血氧值
- (void)saveSpo2ValueToHealthStoreWithSpo2:(int)spo2 andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *spo2Unit = [HKUnit unitFromString:@"%"];
    HKQuantity *spo2Quantity = [HKQuantity quantityWithUnit:spo2Unit doubleValue:spo2/100.0];
    HKQuantityType *spo2Type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *spo2Sample = [HKQuantitySample quantitySampleWithType:spo2Type quantity:spo2Quantity startDate:date endDate:date];
    [self.healthStore saveObject:spo2Sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//收缩压值
- (void)saveBPsysValueToHealthStoreWithBPsys:(int)bpSYS andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *bpUnit = [HKUnit millimeterOfMercuryUnit];
    HKQuantity *bpQuantity = [HKQuantity quantityWithUnit:bpUnit doubleValue:bpSYS];
    HKQuantityType *bpType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *bpSample = [HKQuantitySample quantitySampleWithType:bpType quantity:bpQuantity startDate:date endDate:date];
    [self.healthStore saveObject:bpSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//身高值
- (void)saveHeightValueToHealthStoreWithInfoPlistIdentifier:(NSString *)identifier
{
    NSString *date_str = [identifier componentsSeparatedByString:@"_"][1];
    NSDateComponents *dtc = [NSDate dateCompFromString:date_str];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    NSString *value_str = [identifier componentsSeparatedByString:@"_"][2];
    float height = value_str.floatValue;
    
    //写入
    HKUnit *heightUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:heightUnit doubleValue:height];
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:date endDate:date];
    [self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            //存储identifier
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//体重值
-(void)saveWeightValueToHealthStoreWithInfoPlistIdentifier:(NSString *)identifier
{
    NSString *date_str = [identifier componentsSeparatedByString:@"_"][1];
    NSDateComponents *dtc = [NSDate dateCompFromString:date_str];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    NSString *value_str = [identifier componentsSeparatedByString:@"_"][2];
    float weight = value_str.floatValue;
    
    HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:weight];
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:date endDate:date];
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//体温值
-(void)saveTempValueToHealthStoreWithTemp:(double)temp andDtc:(NSDateComponents *)dtc andIsCelsiusUnit:(BOOL)isCelsiusUnit withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *tempUnit = isCelsiusUnit ? [HKUnit degreeCelsiusUnit] : [HKUnit degreeFahrenheitUnit];
    HKQuantity *tempQuantity = [HKQuantity quantityWithUnit:tempUnit doubleValue:temp];
    HKQuantityType *tempType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    NSDate *date = [NSDate dateFromDateComp:dtc];

    HKQuantitySample *tempSample = [HKQuantitySample quantitySampleWithType:tempType quantity:tempQuantity startDate:date endDate:date];
    [self.healthStore saveObject:tempSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//步数值
-(void)saveStepsValueToHealthStoreWithSteps:(int)steps andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *stepUnit = [HKUnit unitFromString:@"count"];
    HKQuantity *stepQuantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:steps];
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:stepQuantity startDate:date endDate:date];
    [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//跑步距离值
-(void)saveDistanceValueToHealthStoreWithDistance:(double)distance andDtc:(NSDateComponents *)dtc andIsMetric:(BOOL)isMetric withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *distanceUnit = isMetric ? [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo] : [HKUnit mileUnit];
    HKQuantity *distanceQuantity = [HKQuantity quantityWithUnit:distanceUnit doubleValue:distance];
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *distanceSample = [HKQuantitySample quantitySampleWithType:distanceType quantity:distanceQuantity startDate:date endDate:date];
    [self.healthStore saveObject:distanceSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//活动时消耗的卡路里
-(void)saveActiveEnergyValueToHealthStoreWithActiveEnergy:(double)activeEnergy andDtc:(NSDateComponents *)dtc withInfoPlistIdentifier:(NSString *)identifier
{
    HKUnit *energyUnit = [HKUnit kilocalorieUnit];
    HKQuantity *energyQuantity = [HKQuantity quantityWithUnit:energyUnit doubleValue:activeEnergy];
    HKQuantityType *energyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    NSDate *date = [NSDate dateFromDateComp:dtc];
    
    HKQuantitySample *energySample = [HKQuantitySample quantitySampleWithType:energyType quantity:energyQuantity startDate:date endDate:date];
    [self.healthStore saveObject:energySample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

//睡眠分析
-(void)saveSleepValueToHealthStoreWithStartDtc:(NSDateComponents *)startDtc andTotalTime:(NSTimeInterval)totalTime withInfoPlistIdentifier:(NSString *)identifier
{
    HKCategoryType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSDate *startDate = [NSDate dateFromDateComp:startDtc];
    NSDate *endDate = [NSDate dateWithTimeInterval:+totalTime sinceDate:startDate];
    HKCategorySample *sleepSample1 = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisInBed startDate:startDate endDate:endDate];
    HKCategorySample *sleepSample2 = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisAsleep startDate:startDate endDate:endDate];
    
    [self.healthStore saveObjects:@[sleepSample1, sleepSample2] withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self saveHKIdentifierToInfoPlistWithIdentifier:identifier];
        }
    }];
}

@end
