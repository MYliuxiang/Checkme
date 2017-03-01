//
//  PedItem.h
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"

@interface PedInfoItem : MeasureInfoBase <NSCoding>

@property (nonatomic,assign) int step;
@property (nonatomic,assign) double distance;
@property (nonatomic,assign) double speed;
@property (nonatomic,assign) double calorie;
@property (nonatomic,assign) double fat;
@property (nonatomic,assign) int totalTime;

@end
