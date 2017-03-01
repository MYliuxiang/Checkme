//
//  MeasureInfoBase.m
//  BTHealth
//
//  Created by demo on 13-11-16.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "MeasureInfoBase.h"
//#import "NSDate+Additional.h"

@implementation MeasureInfoBase
@synthesize paramType = _paramType;
@synthesize measureMethod = _measureMethod;
@synthesize dtcMeasureTime = _dtcMeasureTime;


-(id)init
{
    
    self = [super init];
    if(self)
    {
        _dtcMeasureTime = [[NSDateComponents alloc] init];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.paramType forKey:@"param"];
    [aCoder encodeInt:self.measureMethod forKey:@"measure"];
    [aCoder encodeObject:self.dtcMeasureTime forKey:@"dtcMeasure"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.paramType = [aDecoder decodeIntForKey:@"param"];
        self.measureMethod = [aDecoder decodeIntForKey:@"measure"];
        self.dtcMeasureTime = [aDecoder decodeObjectForKey:@"dtcMeasure"];
    }
    return self;
}



+(NSArray *)arrayOfHalfYearFromOrigin:(NSArray *)arr
{
//   if(arr.count < 1)
//       return arr;
//    NSDateComponents *dtcFirst = ((MeasureInfoBase *)arr[0]).dtcMeasureTime;
//    NSDate *dateFirst = [NSDate dateFromDateComp:dtcFirst];
//    
//    int i= 0;
//    for(i = 1; i < arr.count; ++i)
//    {
//        MeasureInfoBase *item = arr[i];
//        NSDateComponents *dtcThis = item.dtcMeasureTime;
//        NSDate *dateThis = [NSDate dateFromDateComp:dtcThis];
//        double timeInterval =  [dateThis timeIntervalSinceDate:dateFirst];
//        if(timeInterval > (6*31*24*60*60))
//            break;
//    }
//    
//    if(i > 1)
//    {
//        return  [arr subarrayWithRange:NSMakeRange(0, i)];
//    }
//    else
//        return [arr subarrayWithRange:NSMakeRange(0, 1)];
    
    return nil;
}
@end
