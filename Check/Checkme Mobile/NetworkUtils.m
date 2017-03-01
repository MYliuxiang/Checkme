//
//  NetworkUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "NetworkUtils.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NetworkUtils

//-判断当前网络是否可用
+(BOOL) isNetworkEnabled
{
    BOOL bEnabled = FALSE;
    NSString *url = @"www.apple.com";
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [url UTF8String]);
    SCNetworkReachabilityFlags flags;
    
    bEnabled = SCNetworkReachabilityGetFlags(ref, &flags);

    CFRelease(ref);
    if (bEnabled) {
        //kSCNetworkReachabilityFlagsReachable：能够连接网络
        //kSCNetworkReachabilityFlagsConnectionRequired：能够连接网络，但是首先得建立连接过程
        //kSCNetworkReachabilityFlagsIsWWAN：判断是否通过蜂窝网覆盖的连接，比如EDGE，GPRS或者目前的3G.主要是区别通过WiFi的连接。
        BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
        bEnabled = ((flagsReachable && !connectionRequired) || nonWiFi) ? YES : NO;//三目运算符..
    }
    
    return bEnabled;
}

@end
