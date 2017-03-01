//
//  SpO2_info.h
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpO2_info : UIView
@property (weak, nonatomic) IBOutlet UILabel *spo2_lab;
@property (weak, nonatomic) IBOutlet UILabel *spo2_perc;
@property (weak, nonatomic) IBOutlet UILabel *zhiLabel;

@property (weak, nonatomic) IBOutlet UILabel *spo2_his;
@property (weak, nonatomic) IBOutlet UILabel *spo2Value;
@property (weak, nonatomic) IBOutlet UILabel *prValue;
@property (weak, nonatomic) IBOutlet UILabel *piValue;

@property (weak, nonatomic) IBOutlet UILabel *pi_lab;
@property (weak, nonatomic) IBOutlet UILabel *pr_lab;
@end
