//
//  PedItem.m
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "PedInfoItem.h"

@implementation PedInfoItem

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.step forKey:@"step"];
    [aCoder encodeDouble:self.distance forKey:@"distance"];
    [aCoder encodeDouble:self.speed forKey:@"speed"];
    [aCoder encodeDouble:self.calorie forKey:@"calorie"];
    [aCoder encodeDouble:self.fat forKey:@"fat"];
    [aCoder encodeInt:self.totalTime forKey:@"totalTime"];
    [aCoder encodeObject:self.dtcMeasureTime forKey:@"measureT"];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.step = [aDecoder decodeIntForKey:@"step"];
        self.distance = [aDecoder decodeDoubleForKey:@"distance"];
        self.speed = [aDecoder decodeDoubleForKey:@"speed"];
        self.calorie = [aDecoder decodeDoubleForKey:@"calorie"];
        self.fat = [aDecoder decodeDoubleForKey:@"fat"];
        self.totalTime = [aDecoder decodeIntForKey:@"totalTime"];
        self.dtcMeasureTime = [aDecoder decodeObjectForKey:@"measureT"];
    }
    return self;
}


@end
