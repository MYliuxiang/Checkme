//
//  HKUpdateUtils.h
//  Checkme Mobile
//
//  Created by 李 乾 on 15/5/22.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface HKUpdateUtils : NSObject

+(HKUpdateUtils *)sharedInstance;

//一次性保存所有数据到healthKit   在SettingsVC中用到
- (void) updateAllDataToHealthKitWithUser:(User *)user;

//保存用户身高、体重数据到HealthKit
- (void) saveUserInfoToHealthKitWithCurUser:(User *)user;

//保存心电、血氧数据到HealthKit    //dlc界面用到
- (void) saveHR_SpO2_BPToHealthKitWithDLCItem:(DailyCheckItem *)dlcItem andUser:(User *)user;

//保存计步相关的数据到HK
- (void) savePedDataToHealthKitWithPedItem:(PedInfoItem *)pedItem andUser:(User *)user;
@end
