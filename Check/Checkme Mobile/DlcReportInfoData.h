//
//  ReportInfoData.h
//  Checkme Mobile
//
//  Created by Lq on 14-12-29.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DlcReportInfoData : UIView
@property (strong, nonatomic) IBOutlet UILabel *Name;
@property (strong, nonatomic) IBOutlet UILabel *Gender;
@property (strong, nonatomic) IBOutlet UILabel *DateBirth;
@property (strong, nonatomic) IBOutlet UILabel *MesuringMode;
@property (strong, nonatomic) IBOutlet UILabel *dateTime;
@property (strong, nonatomic) IBOutlet UILabel *HeartRate;
@property (strong, nonatomic) IBOutlet UILabel *QRS;
@property (weak, nonatomic) IBOutlet UILabel *ECG;
@property (weak, nonatomic) IBOutlet UILabel *spo2;
@property (weak, nonatomic) IBOutlet UILabel *pi;
@property (weak, nonatomic) IBOutlet UILabel *oxySatur;
@property (strong, nonatomic) IBOutlet UILabel *BP;

@property (strong, nonatomic) IBOutlet UILabel *RPP;

@property (strong, nonatomic) IBOutlet UILabel *RPPSatur;



@property (nonatomic, strong) UILabel *usrName;
@property (nonatomic, strong) UILabel *usrGender;
@property (nonatomic, strong) UILabel *usrDateBirth;
@end
