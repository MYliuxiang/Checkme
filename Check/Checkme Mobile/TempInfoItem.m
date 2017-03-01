//
//  TempInfoItem.m
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "TempInfoItem.h"

@implementation TempInfoItem


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
    [aCoder encodeDouble:self.PTT_Value forKey:@"ptt"];
    [aCoder encodeInt:self.measureMode forKey:@"mode"];
    [aCoder encodeInt:self.enPassKind forKey:@"passKind"];
    [aCoder encodeObject:self.dtcMeasureTime forKey:@"measureT"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.PTT_Value = [aDecoder decodeDoubleForKey:@"ptt"];
        self.measureMode = [aDecoder decodeIntForKey:@"mode"];
        self.enPassKind = [aDecoder decodeIntForKey:@"passKind"];
        self.dtcMeasureTime = [aDecoder decodeObjectForKey:@"measureT"];
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
