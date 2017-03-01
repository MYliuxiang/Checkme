//
//  Battery.m
//  IOS_Minimotor
//
//  Created by Viatom on 15/6/5.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "Battery.h"

@interface Battery ()

@property (weak, nonatomic) IBOutlet UIButton *OutFrame;
@property (weak, nonatomic) IBOutlet UILabel *DarkPoint;
@property (weak, nonatomic) IBOutlet UILabel *GreenLab;

@end

@implementation Battery

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"Battery" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    
    if (!_batteryColor) {
        _batteryColor = [UIColor blackColor];
    }
    
    _OutFrame.frame = rect(0 ,0 , self.bounds.size.width-4, self.bounds.size.height);
    _OutFrame.backgroundColor = [UIColor clearColor];
    _OutFrame.userInteractionEnabled = NO;
    [_OutFrame setTitle:_batteryValue forState:UIControlStateNormal];
    [_OutFrame setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _OutFrame.layer.borderColor = _batteryColor.CGColor;
    _OutFrame.layer.borderWidth = 1.5f;
    _OutFrame.layer.cornerRadius = 3.0;
    _OutFrame.titleLabel.font = font(15);
    
    _DarkPoint.frame = rect(CGRectGetMaxX(_OutFrame.frame)-1, CGRectGetHeight(_OutFrame.frame)*0.25, 4, CGRectGetHeight(_OutFrame.frame)*0.5);
    _DarkPoint.layer.cornerRadius = 1.5;
    _DarkPoint.clipsToBounds = YES;
    _DarkPoint.backgroundColor = _batteryColor;
    
    _GreenLab.frame = rect(2.0, 2.0, _OutFrame.bounds.size.width-4.0, _OutFrame.bounds.size.height-4.0);
    _GreenLab.backgroundColor = RGB(18, 200, 59);
    
    if (_batteryType == Battery_display_typeDigital || !_batteryType) {
        _GreenLab.hidden = YES;
    } else if (_batteryType == Battery_display_typeGreenPicture) {
        _GreenLab.hidden = NO;
        [_OutFrame setTitle:@"" forState:UIControlStateNormal];
        _GreenLab.frame = rect(2.0, 2.0, _OutFrame.bounds.size.width*(_batteryValue.intValue/100.0)-4.0, _OutFrame.bounds.size.height-4.0);
        if (_batteryValue.intValue <= 30) {  // 电量低于30时显示为红色
            _GreenLab.backgroundColor = [UIColor redColor];
        }
    }
    
}

- (void)setBatteryValue:(NSString *)batteryValue
{
    _batteryValue = batteryValue;
    [self layoutSubviews];
}

@end
