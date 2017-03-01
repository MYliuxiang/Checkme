//
//  LoadingViewUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-9.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "LoadingViewUtils.h"
#import "Colors.h"


@implementation LoadingViewUtils

//显示加载动画
+(MONActivityIndicatorView*)initLoadingView:(UIViewController*)controller
{
    MONActivityIndicatorView* indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 3;
    indicatorView.radius = 8;//半径
    indicatorView.internalSpacing = 3;
    indicatorView.center = controller.view.center;
    [indicatorView startAnimating];
    [controller.view addSubview:indicatorView];
    return indicatorView;
}

//停止加载动画
+(void)stopLoadingView:(MONActivityIndicatorView*)indicatorView
{
    if (indicatorView) {
        [indicatorView stopAnimating];//停止动画
    }
//    [indicatorView removeFromSuperview];
}

#pragma mark - MONActivityIndicatorViewDelegate Methods
#warning  颜色
+(UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
//    CGFloat red   = (arc4random() % 256)/255.0;
//    CGFloat green = (arc4random() % 256)/255.0;
//    CGFloat blue  = (arc4random() % 256)/255.0;
//    CGFloat alpha = 1.0f;
//    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    if (index==0) {
        return LIGHT_BLUE;//显示蓝色
    }else if(index==1){
        return LIGHT_GREEN; //显示绿色
    }else{
        return ORANGE;  //显示橘黄色
    }
    
}

@end
