//
//  MyColor.h
//  LingLuoChePing
//
//  Created by yunhe on 15/5/31.
//  Copyright (c) 2015年 李立. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#warning 颜色设置
//设置颜色
#define Colol_labnum ([MyColor colorWithHexString:@"202020"])
#define Colol_lableft ([MyColor colorWithHexString:@"636363"])
#define Colol_labtishi ([MyColor colorWithHexString:@"929292"])
#define Colol_cellbg ([MyColor colorWithHexString:@"f4f4f4"])
#define Colol_xiantiao ([MyColor colorWithHexString:@"6255ad"])   //线条
#define Colol_dailyquxian ([MyColor colorWithHexString:@"636363"])  //赛贝尔曲线



@interface MyColor : NSObject

+ (UIColor *) colorWithHexString: (NSString *)color;
@end