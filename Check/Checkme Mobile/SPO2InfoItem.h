//
//  SPO2InfoItem.h
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"
#import "TypesDef.h"

//#define MAX_Resonable_SPO2_Value 100
//#define MIN_Resonable_SPO2_Value 50


@interface SPO2InfoItem : MeasureInfoBase<NSCoding>

@property (nonatomic,assign) int SPO2_Value;
@property (nonatomic,assign) U16 PR;
@property (nonatomic,assign) double PI;
@property (nonatomic,assign) PassKind_t enPassKind;

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind;

@end
