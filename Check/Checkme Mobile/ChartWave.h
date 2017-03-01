//
//  NewHRWave.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/30.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ChartItem.h"

#define CHART_TYPE_HR 1
#define CHART_TYPE_SPO2 2
#define CHART_TYPE_BP_RE 3
#define CHART_TYPE_BP_ABS 4
#define CHART_TYPE_BP_NONE 5
#define CHART_TYPE_PI 6
#define CHART_TYPE_Relaxaction 7
@class SampleItem;

@interface ChartWave : UIView
- (instancetype)initWithFrame:(CGRect)frame withChartList:(NSArray*) inList chartType:(int)chartType;
-(void)initParams:(float) maxVal min:(float) minVal lineNum:(int) lineNum errNum:(int) errNum;
-(void)switchScale:(U8)scale;
@end


@interface SampleItem : NSObject

@property(nonatomic,assign) int maxVal;
@property(nonatomic,assign) int minVal;
@property(nonatomic,assign) bool isMultiVal;//是否是多值
@property(nonatomic,assign) bool isNilVal;//是否是空值
@property (nonatomic,retain) NSDate* dtcDate;

- (void)addVal:(ChartItem*) item;

@end