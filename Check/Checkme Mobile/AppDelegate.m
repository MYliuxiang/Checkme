//
//  AppDelegate.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-4.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"

#import "MMDrawerController.h"
#import "RootViewController.h"
#import "NavigationViewController.h"
#import "FileUtils.h"


#define UMENG_APPKEY @"56303668e0f55a1440001055"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //貌似这位同仁是不是经常看limingjie 的视屏呀  (又是版本判断)

//    BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:ISFIRST];
//    
//    if (!isFirst) {
//        
//
//        
//    }else{
//        
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ISFIRST];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    }
    
    
    
    [UserDefault setBool:NO forKey:@"ISAIRTRACE"];
    [UserDefault synchronize];
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) BATCH channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //        [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
#warning 点击 取消按钮 Cancel   hjzXx
    [MobClick checkUpdate:DTLocalizedString(@"New Version", nil) cancelButtonTitle:DTLocalizedString(@"Cancel", nil) otherButtonTitles:DTLocalizedString(@"Update", nil)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    DLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self umengTrack];
    
    
    
      
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self setUpHealthStoreForAllControllers];
    self.healthStore = [[HKHealthStore alloc] init];
    
    return YES;
}

- (void) setUpHealthStoreForAllControllers
{
    RootViewController *rootVC = (RootViewController *)self.window.rootViewController;
    MMDrawerController *mmdVC = rootVC.mmDrawer;
    NavigationViewController *navi = (NavigationViewController *)mmdVC.centerViewController;
    
    id vc = navi.visibleViewController;
    if ([vc respondsToSelector:@selector(setHealthStore:)]) {
        [vc setHealthStore:self.healthStore];
    }
    
    for (id VC in navi.viewControllers) {
        if ([VC respondsToSelector:@selector(setHealthStore:)]) {
            [VC setHealthStore:self.healthStore];
        }
    }
}


#warning 离线数据处理
+(AppDelegate *)GetAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


@end
