//
//  LoadingViewUtils.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-9.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MONActivityIndicatorView.h"

@interface LoadingViewUtils : NSObject<MONActivityIndicatorViewDelegate>

+(MONActivityIndicatorView *)initLoadingView:(UIViewController *)controller;
+(void)stopLoadingView:(MONActivityIndicatorView *)indicatorView;

@end
