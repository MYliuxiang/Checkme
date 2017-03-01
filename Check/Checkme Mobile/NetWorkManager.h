//
//  NetWorkManager.h
//  NetWorking
//
//  Created by 汪林霞 on 14-11-22.
//  Copyright (c) 2014年 youtu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol NetWorkManagerDelegate <NSObject>

@required

- (void) netWorkStatusWillChange:(NetworkStatus)status;

@optional

- (void) netWorkStatusWillEnabled;

- (void) netWorkStatusWillEnabledViaWifi;

- (void) netWorkStatusWillEnabledViaWWAN;

- (void) netWorkStatusWillDisconnection;

@end

@interface NetWorkManager : NSObject
{
@private
    
    Reachability* rech;
    
    /** 标识网络是否活跃 **/
    Boolean _netWorkIsEnabled;
    
    /** 设备链接网络的方式 **/
    NetworkStatus _witchNetWorkerEnabled;
    
    /** 代理 **/
    id<NetWorkManagerDelegate> _delegate;

}

///!!!NOTICE:WNEH YOU WANT TO GET THIS,YOU MUST START THE WATCH FIRST
@property (readonly, getter = witchNetWorkerEnabled) NetworkStatus witchNetWorkerEnabled;

///!!!NOTICE:WNEH YOU WANT TO GET THIS,YOU MUST START THE WATCH FIRST
@property (readonly, getter = netWorkIsEnabled) Boolean netWorkIsEnabled;

@property (nonatomic, retain) id<NetWorkManagerDelegate> delegate;


/**
 *
 * 获取网络管理器
 *
 */
+ (id) sharedManager;

/**
 *
 * 防止以其他方法创建第二实例
 *
 */
+ (id) allocWithZone:(NSZone *)zone;

/**
 *
 * 检测当前网络状态
 *
 */
- (NetworkStatus) checkNowNetWorkStatus;
/**
 *
 * 开始检测网络
 *
 */
- (Boolean) startNetWorkeWatch;

/**
 *
 * 停止检测网络
 *
 */
- (void) stopNetWorkWatch;

/**
 *
 * 当网络发生变化时
 *
 */
- (void)reachabilityChanged:(NSNotification *)note;



@end
