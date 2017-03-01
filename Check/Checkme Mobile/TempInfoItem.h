//
//  TempInfoItem.h
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"
#import "TypesDef.h"

//#define MAX_Resonable_Temp_Value 43.0
//#define MIN_Resonable_Temp_Value 33.0

//温度两种测量方式
#define TEMP_MODE_HEAD 0
#define TEMP_MODE_THING 1

@interface TempInfoItem : MeasureInfoBase <NSCoding>

///  temperature value
@property (nonatomic,assign) double PTT_Value;
@property (nonatomic,assign) U8 measureMode;
@property (nonatomic,assign) PassKind_t enPassKind;

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind;
@end
