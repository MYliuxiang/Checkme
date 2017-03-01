//
//  SleepMonitorInfoData.h
//  Checkme Mobile
//
//  Created by Lq on 15-1-6.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SleepMonitorInfoData : UIView
@property (strong, nonatomic) IBOutlet UILabel *measuringMode;
@property (strong, nonatomic) IBOutlet UILabel *dateTime;
@property (strong, nonatomic) IBOutlet UILabel *totalDur;
@property (strong, nonatomic) IBOutlet UILabel *sata;
@property (strong, nonatomic) IBOutlet UILabel *average;
@property (strong, nonatomic) IBOutlet UILabel *lowest;
@property (strong, nonatomic) IBOutlet UILabel *info;

@end
