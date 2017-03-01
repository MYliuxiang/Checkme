//
//  WaveInfo.h
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/11.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECG_info.h"
#import "SpO2_info.h"
#import "RESP_info.h"
#import "ART_info.h"


typedef NS_ENUM(NSInteger, Wave_type) {
    Wave_type_ECG = 0,
    Wave_type_SpO2 = 1,
    Wave_type_RESP = 2,
    Wave_type_ART
};

@interface WaveInfo : UIView

@property (nonatomic, strong) ECG_info *ecg_info;
@property (nonatomic, strong) SpO2_info *spo2_info;
@property (nonatomic, strong) RESP_info *resp_info;
@property (nonatomic, strong) ART_info *art_info;

- (instancetype) initWithFrame:(CGRect)frame andType:(Wave_type)type;
//刷新画线
- (void)refreshWaveWithDataArr:(NSArray *)dataArr;

- (void)_shujuqingling;

@end
