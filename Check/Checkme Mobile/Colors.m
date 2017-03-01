//
//  Colors.m
//  MyCellTest
//
//  Created by Joe on 14-8-1.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "Colors.h"

@implementation Colors


+(void)initStaticColors
{
    orange = RGB(235, 97, 0);
    darkBlue = RGB(105, 143, 167);
    lightBlue = RGB(13, 181, 252);
    lightGreen = RGB(28, 204, 102);
    yellow = RGB(251, 217, 55);
}

+(UIColor*)getOrange
{
    return orange;
}

+(UIColor*)getDarkBlue
{
    return darkBlue;
}

+(UIColor*)getLightBlue
{
    return lightBlue;
}

+(UIColor*)getLightGreen
{
    return lightGreen;
}

+(UIColor*)getYellow
{
    return yellow;
}

@end
