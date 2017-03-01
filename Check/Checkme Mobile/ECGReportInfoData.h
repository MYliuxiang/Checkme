//
//  ECGReportInfoData.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/1/1.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECGReportInfoData : UIView

@property (weak, nonatomic) IBOutlet UILabel *MesuringMode;
@property (weak, nonatomic) IBOutlet UILabel *DateTime;
@property (weak, nonatomic) IBOutlet UILabel *HeartRate;
@property (weak, nonatomic) IBOutlet UILabel *QRS;
@property (weak, nonatomic) IBOutlet UILabel *stLabel;
@property (weak, nonatomic) IBOutlet UILabel *ST;
@property (weak, nonatomic) IBOutlet UILabel *Description;
@property (strong, nonatomic) IBOutlet UIImageView *mesureImage;

@end
