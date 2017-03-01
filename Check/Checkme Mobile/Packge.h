//
//  Packge.h
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Packge : NSObject

@property (nonatomic, strong) NSMutableArray *ECG_Dis;
@property (nonatomic, strong) NSMutableArray *Oxi_Dis;
@property (nonatomic, assign) U8 Oxi;
@property (nonatomic, assign) U8 Oxi_PI;
@property (nonatomic, assign) U16 Oxi_PR;
@property (nonatomic, assign) U16 HR;
@property (nonatomic, assign) U16 QRS;
@property (nonatomic, assign) U16 ST;
@property (nonatomic, assign) U16 PVC;
@property (nonatomic, assign) U8 Battery;
@property (nonatomic, assign) U8 SpO2Identity;
@property (nonatomic, assign) U8 HRIdentity;

@end
