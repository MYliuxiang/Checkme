//
//  LocalizationUtils.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/5.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "LocalizationUtils.h"

@implementation LocalizationUtils

//处理默认语言
+ (NSString *)DPLocalizedString:(NSString *)translation_key {
    
    NSString * s = NSLocalizedString(translation_key, nil);
    if (![curLanguage isEqual:@"es-CN"]) { //如果当前语言不是 英文、简体中文、日文、法文、匈牙利文的话，就用默认的Base语言(即英文)
        NSLog(@"%@",curLanguage);
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    
    //    NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    //    NSBundle * languageBundle = [NSBundle bundleWithPath:path];
    //    s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    return s;
}

@end
