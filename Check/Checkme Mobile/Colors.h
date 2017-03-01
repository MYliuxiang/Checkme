//
//  Colors.h
//  MyCellTest
//
//  Created by Joe on 14-8-1.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define DEFAULT_BLUE1 (RGB(38, 154, 208))
#define DEFAULT_BLUE (RGB(255, 255, 255))
#define LIGHT_GREY (RGB(215, 215, 215))//横向坐标线
#define DARK_BLUE (RGB(105, 143, 167))
#define LIGHT_GREEN (RGB(28, 204, 102))
#define YELLOW (RGB(251, 217, 55))
#define LIGHT_BLUE (RGB(13, 181, 252))
#define ORANGE (RGB(235, 97, 0))
#define ITEM_LEFT_BLUE (RGB(1, 131, 187))
#define TRANSPARENT_WHITE (RGBA(255,255,255,0.6))



static UIColor* orange;
static UIColor* darkBlue;
static UIColor* lightGreen;
static UIColor* yellow;
static UIColor* lightBlue;

@interface Colors : NSObject

+(UIColor *)getOrange;
+(UIColor *)getDarkBlue;
+(UIColor *)getLightGreen;
+(UIColor *)getYellow;
+(UIColor *)getLightBlue;

+(void)initStaticColors;
@end
