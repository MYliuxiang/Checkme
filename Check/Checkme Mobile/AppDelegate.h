//
//  AppDelegate.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-4.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
//** HealthKit 健康值*/
@import HealthKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/** 判断是否是离线数据*/
@property (nonatomic) BOOL isOffline;

@property (nonatomic,assign)BOOL ishaveList;//是否有左滑菜单和截屏按钮

@property (nonatomic,strong)UIImage *image;

@property (nonatomic) BOOL ischonglian;


//** HealthKit 健康值*/
@property (nonatomic) HKHealthStore *healthStore;

+(AppDelegate *)GetAppDelegate;

@end
