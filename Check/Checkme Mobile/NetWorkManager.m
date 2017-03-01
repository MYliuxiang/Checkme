//
//  NetWorkManager.m
//  NetWorking
//
//  Created by 汪林霞 on 14-11-22.
//  Copyright (c) 2014年 youtu. All rights reserved.
//

#import "NetWorkManager.h"

@implementation NetWorkManager

static NetWorkManager* defaultManager = nil;

+ (NetWorkManager*) sharedManager
{
    if (!defaultManager)
    {
        defaultManager = [[self alloc] init];
    }
    return defaultManager;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (defaultManager == nil)
        {
            defaultManager = [super allocWithZone:zone];
            return defaultManager;
        }
    
    }
    return nil;
}

- (NetworkStatus) checkNowNetWorkStatus
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [r currentReachabilityStatus];
}

- (Boolean) startNetWorkeWatch
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    rech = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    Boolean finish = [rech startNotifier];
    return finish;
    
    
}

- (void) stopNetWorkWatch
{
    [rech stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    //调用代理方法,此方法为必须实现
    [_delegate netWorkStatusWillChange:status];
    
    //代理的可选方法
    switch (status)
    {
        case NotReachable:
        {
            //网络不可达 ,没有网络的情况
            _netWorkIsEnabled = NO;
            _witchNetWorkerEnabled = NotReachable;
            
            if ([(NSObject*)_delegate respondsToSelector:@selector(netWorkStatusWillDisconnection)])
            {
                [_delegate netWorkStatusWillDisconnection];
            }
        }
            break;
        case ReachableViaWiFi:
        {
            //网络可达，GPRS，3G网络的时候
            _netWorkIsEnabled = YES;
            _witchNetWorkerEnabled = ReachableViaWiFi;
            
            if ([(NSObject*)_delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWifi)])
            {
                [_delegate netWorkStatusWillEnabledViaWifi];
            }
        }
            break;
        case ReachableViaWWAN:
        {
            //网络可达，WIFI情况下
            _netWorkIsEnabled = YES;
            _witchNetWorkerEnabled = ReachableViaWWAN;
            
            if ([(NSObject*)_delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWWAN)])
            {
                [_delegate netWorkStatusWillEnabledViaWWAN];
            }
        }
            break;
        default:
            break;
    }
    
}


@end
