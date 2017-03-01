//
//  SettingCell.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/1/5.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;

#warning 设置界面的单元格cell

@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *theLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSegCtr;//分段控制器

//**  HealthKit*/
@property (nonatomic) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UISwitch *HKSwh;


@end
