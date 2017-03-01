//
//  SpO2_info.m
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "SpO2_info.h"

@implementation SpO2_info

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    _spo2_his.frame = rect(0, (self.bounds.size.height-self.bounds.size.height*0.6)*0.5, 25, self.bounds.size.height*0.6);
//    
//    DLog(@"^^^^ %@", NSStringFromCGRect(_spo2_his.frame));
    if (!isIpad) {
        
//        _zhiLabel.right = self.width;
        
        
    }
    self.clipsToBounds = YES;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    _spo2_lab.frame = rect(10, 10, 70, 30);
//    _spo2_perc.frame = rect(CGRectGetMaxX(_spo2_lab.frame)+10, 10, 80, 30);
//    
////    _spo2_his.frame = rect(0, (self.bounds.size.height-self.bounds.size.height*0.6)*0.5, 25, self.bounds.size.height*0.6);
//
//    _spo2Value.frame = rect(0, self.bounds.size.height*(1.0/5), self.bounds.size.width, 80);
//    
//    _pi_lab.frame = rect(self.bounds.size.width*0.25, self.bounds.size.height*0.70, 40, 30);
//    _piValue.frame = rect(CGRectGetMaxX(_pi_lab.frame)+10, CGRectGetMaxY(_pi_lab.frame)-30, 100, 30);
//    
//    _pr_lab.frame = rect(_pi_lab.frame.origin.x, CGRectGetMaxY(_pi_lab.frame)+20, 40, 30);
//    _prValue.frame = rect(_piValue.frame.origin.x, CGRectGetMaxY(_pr_lab.frame)-30, 60, 30);
    
    
//    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = RGB(139, 139, 139).CGColor;
    
    if (!isIpad) {
        _spo2_lab.font = font(15);
        _pi_lab.font = font(15);
        _pr_lab.font = font(15);
        _spo2_perc.font = [UIFont boldSystemFontOfSize:17];
        _zhiLabel.font = [UIFont boldSystemFontOfSize:17];
        _spo2Value.font = [UIFont boldSystemFontOfSize:27];
        _prValue.font = [UIFont boldSystemFontOfSize:17];
        _piValue.font = [UIFont boldSystemFontOfSize:17];
        
        
    }
    

}

@end
