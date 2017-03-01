//
//  SettingCell.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/1/5.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SettingCell.h"
#import "Colors.h"
#import "AppDelegate.h"

@implementation SettingCell

- (void)awakeFromNib {
    
//    self.theSegCtr.tintColor = DEFAULT_BLUE1;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByTruncatingMiddle;//枚举值
    
    [self.theSegCtr setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor lightGrayColor], NSParagraphStyleAttributeName: paragraph} forState:UIControlStateNormal];
    [self.theSegCtr setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName: paragraph} forState:UIControlStateSelected];
}

- (void) layoutSubviews
{
    [super layoutSubviews];//调用父类的layoutSubviews方法
}

//*****************************************************************//
#pragma mark - 添加 HealthKit 功能
- (IBAction)switchAction:(id)sender {
    [self ConfigurateHealthKit];  //添加 HealthKit 功能
     NSLog(@"11111111111111111滑动了滑块22222222222222222222滑动了滑块");//测试滑动滑块事件
}


//#pragma mark - HealthKit
- (void) ConfigurateHealthKit
{
    
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])  //首先进行检查判断 HealthKit 的可用性
    {    //说明: HealthKit 只能在 iphone设备上使用,不能在ipad 以及 ipod 上操作使用
        // Add your HealthKit code here    //添加 HealthKit 的代码
        // HK
        self.healthStore = [AppDelegate GetAppDelegate].healthStore;//不能这样写(这样写的话没有初始化到 healthStore  就不会有 授权操作的过程  可以注释掉)
        self.healthStore = [[HKHealthStore alloc]init];//初始化healthStore
        
        if ([HKHealthStore isHealthDataAvailable]) {
            /*
            NSSet *shareObjectTypes = [NSSet setWithObjects:
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                                       nil];
            
            // Read date of birth, biological sex and step count
            NSSet *readObjectTypes  = [NSSet setWithObjects:
                                       [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                                       [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                       nil];
             //自己加的测试的
            */
            
            //请求用户授权操作
//            [self.healthStore requestAuthorizationToShareTypes:shareObjectTypes readTypes:readObjectTypes completion:^(BOOL success, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
            
            NSSet *writeDataType = [self dataTypesToWrite];
            [self.healthStore requestAuthorizationToShareTypes:writeDataType readTypes:nil completion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setBool:YES forKey:@"isConfigurateHealthKit"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Ntf_HKSwitch_ON object:nil];
                });
            }];
        }
        
    }
    
}
#pragma mark - HealthKit Permissions
//要往HK写入的数据  (原创的写法)
/*
- (NSSet *) dataTypesToWrite
{
    HKQuantityType *height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *activeEnergyBurned = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    HKQuantityType *temperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantityType *BPsys = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    //    HKQuantityType *BPdias = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    //    HKQuantityType *respiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //呼吸速率
    HKQuantityType *spo2 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
//    HKCategoryType *sleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];  //睡眠
    
    return [NSSet setWithObjects:height, weight, steps, distance, activeEnergyBurned, heartRate, BPsys, spo2, nil];
}
*/



- (NSSet *) dataTypesToWrite
{
    HKQuantityType *height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];  //身高
    HKQuantityType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];//体重
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];//步数
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];//跑步
    HKQuantityType *activeEnergyBurned = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
//        HKQuantityType *temperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    
    
    HKQuantityType *BPsys = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    
    //HKQuantityType *BPdias = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    //HKQuantityType *respiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //呼吸速率
    
    
    HKQuantityType *spo2 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    
        //HKCategoryType *sleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];  //睡眠
    
    
    return [NSSet setWithObjects:height, weight, steps, distance, activeEnergyBurned, heartRate, BPsys, spo2, nil];
}

//*****************************************************************//


#pragma mark - 单元格的选中状态
//选中状态
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //NSLog(@"444444444444444444444444444444444444444444444444444444444444444444444444444444444444444");
    // Configure the view for the selected state
}

@end
