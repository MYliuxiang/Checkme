//
//  GlucoseInfoItem.h
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"


#define MAX_Resonable_Glucose_Value 300.0
#define MIN_Resonable_Glucose_Value 0.0

@interface GlucoseInfoItem : MeasureInfoBase
@property (nonatomic,assign) double Glucose_Value;
@end
