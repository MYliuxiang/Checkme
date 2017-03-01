//
//  ECG_info.m
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "ECG_info.h"
#import "AppDelegate.h"
@implementation ECG_info

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    _HRLabel.frame = rect(10, 10, 100, 30);
//    _HRValue.frame = rect(0, self.center.y-40, self.bounds.size.width, 80);
    
    //圆角
//    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = RGB(139, 139, 139).CGColor;
//    if([AppDelegate GetAppDelegate].ishaveList == YES)
//    {
//          _jiebingbtn.hidden = NO;
//    } else {
//    
//          _jiebingbtn.hidden = YES;
//    }

    if (!isIpad) {
        _HRLabel.font = font(17);
        _HRValue.font = [UIFont boldSystemFontOfSize:50];
        _zhiLabel.font = [UIFont boldSystemFontOfSize:17];
    }
}

- (IBAction)Screenshot:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Noti_Screenshot object:nil];
    
}
@end
