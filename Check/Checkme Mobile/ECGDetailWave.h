//
//  EcgWaveView_Detail.h
//  BTHealth
//
//  Created by demo on 13-11-6.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECGInfoItem.h"
#import "SpotCheckItem.h"

@interface ECGDetailWave : UIView


-(id)initWithMinFrame:(CGRect)frame ecgInnerData:(ECGInfoItem_InnerData *)data;
-(id)initWithMinFrame:(CGRect)frame spcInnerData:(spcInner_Data *)data;

+(CGSize)calViewSizeForArr:(NSArray *)arr;
+(double)secondsCanBeDisplayOneScreen;

-(CGRect)rectForDisplayStart:(double)startSecond end:(double)endSecond fatherViewFrame:(CGRect)fatherViewFrame;

-(void)showInfo:(NSString*)userName time:(NSDateComponents*) comps;
-(void)hideInfo;

@end
