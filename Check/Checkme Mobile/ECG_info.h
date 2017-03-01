//
//  ECG_info.h
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECG_info : UIView
@property (weak, nonatomic) IBOutlet UILabel *HRLabel;
@property (weak, nonatomic) IBOutlet UILabel *HRValue;
- (IBAction)Screenshot:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *jiebingbtn;
@property (weak, nonatomic) IBOutlet UILabel *zhiLabel;

@end
