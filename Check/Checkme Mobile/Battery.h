//
//  Battery.h
//  IOS_Minimotor
//
//  Created by Viatom on 15/6/5.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Battery_display_type) {
    Battery_display_typeDigital = 0,
    Battery_display_typeGreenPicture
};


@interface Battery : UIView

@property (nonatomic, strong) UIColor *batteryColor;
@property (nonatomic) Battery_display_type batteryType;
@property (nonatomic, copy) NSString *batteryValue;

- (instancetype) initWithFrame:(CGRect)frame;
@end
