//
//  SPO2InfoItem.m
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "SPO2InfoItem.h"

@implementation SPO2InfoItem

@synthesize SPO2_Value = _SPO2_Value;
@synthesize PR = _PR;
@synthesize PI = _PI;

-(id)init
{
    self = [super init];
    if(self)
    {
       
    }
    return self;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.SPO2_Value forKey:@"spo2_value"];
    [aCoder encodeInt:self.PR forKey:@"pr"];
    [aCoder encodeObject:self.dtcMeasureTime forKey:@"dtcMeasure"];
    [aCoder encodeDouble:self.PI forKey:@"pi"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.SPO2_Value = [aDecoder decodeIntForKey:@"spo2_value"];
        self.PR = [aDecoder decodeIntForKey:@"pr"];
        self.dtcMeasureTime = [aDecoder decodeObjectForKey:@"dtcMeasure"];
        self.PI = [aDecoder decodeDoubleForKey:@"pi"];
    }
    return self;
}



-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind
{
    BOOL bMatch = NO;
    
    if((typeKind & kTypeForFilter_Pass) != 0)
    {
        if(_enPassKind == kPassKind_Pass)
            bMatch = YES;
    }
    if((typeKind & kTypeForFilter_Fail) != 0)
    {
        if(_enPassKind == kPassKind_Fail)
            bMatch = YES;
    }
    //不能分析的暂时不筛选掉
    if (_enPassKind == kPassKind_Others) {
        bMatch = YES;
    }
    
    return bMatch;
}

@end
