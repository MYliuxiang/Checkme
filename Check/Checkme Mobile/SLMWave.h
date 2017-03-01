//
//  SLMWave.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLMItem.h"

@class SLMSampleItem;

@interface SLMWave : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,assign) bool viewingDetail;//画详情竖线

-(id)initWithFrame:(CGRect)frame dataItem:(SLMItem *)item;
-(void)onBnViewDetailClicked;
@end


//画图用数据格式
@interface SLMSampleItem : NSObject

@property(nonatomic,assign) int spo2;
@property(nonatomic,assign) int pr;
@property(nonatomic,assign) bool errSample;//是否为无效值

- (instancetype)initWithSPO2:(int)spo2 andPR:(int)pr;
@end