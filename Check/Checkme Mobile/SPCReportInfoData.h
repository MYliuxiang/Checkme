//
//  SPCReportInfoData.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/30.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPCReportInfoData : UIView
@property (weak, nonatomic) IBOutlet UILabel *patientID;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *genderL;
@property (weak, nonatomic) IBOutlet UILabel *ageL;
@property (weak, nonatomic) IBOutlet UILabel *modeL;
@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UILabel *hrL;
@property (weak, nonatomic) IBOutlet UILabel *qrsL;
@property (weak, nonatomic) IBOutlet UILabel *ecgL;
@property (weak, nonatomic) IBOutlet UILabel *spo2L;
@property (weak, nonatomic) IBOutlet UILabel *piL;
@property (weak, nonatomic) IBOutlet UILabel *Spo2_R;
@property (weak, nonatomic) IBOutlet UILabel *tempL;

@end
