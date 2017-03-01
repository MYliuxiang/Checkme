//
//  MeasureInfoBase.h
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesDef.h"

@interface MeasureInfoBase : NSObject<NSCoding>
@property (nonatomic,assign) U8 paramType;
@property (nonatomic,assign) U8 measureMethod;
@property (nonatomic,retain) NSDateComponents *dtcMeasureTime;

+(NSArray *)arrayOfHalfYearFromOrigin:(NSArray *)arr;
@end
