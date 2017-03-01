//
//  Packge.m
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/13.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "Packge.h"

@implementation Packge

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ECG_Dis = [NSMutableArray array];
        _Oxi_Dis = [NSMutableArray array];
    }
    return self;
}

@end
