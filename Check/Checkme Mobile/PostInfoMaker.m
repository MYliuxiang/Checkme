//
//  PostInfoMaker.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "PostInfoMaker.h"

@implementation PostInfoMaker

//生成获取语言列表的post表单
+(NSString*)makeGetLanguageListInfo:(CheckmeInfo*) checkmeInfo
{
    if (!checkmeInfo) {
        return nil;
    }
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"Region=%@&",[checkmeInfo region]];
    [str appendFormat:@"Model=%@&",[checkmeInfo model]];
    [str appendFormat:@"Hardware=%@&",[checkmeInfo hardware]];
    [str appendFormat:@"Software=%@&",[checkmeInfo software]];
    [str appendFormat:@"Language=%@&",[checkmeInfo language]];

    DLog(@"获取的语言包的请求参数为：%@", str);
    return str;
}

#warning 升级语言包
//生成获取升级包的post表单
//语言更换
+(NSString*)makeGetPatchsInfo:(CheckmeInfo*) checkmeInfo WantLanguage:(NSString*) wantLanguage
{
    if (!checkmeInfo || !wantLanguage) {
        return nil;
    }
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"Region=%@&",[checkmeInfo region]];
    [str appendFormat:@"Model=%@&",[checkmeInfo model]];
    [str appendFormat:@"Hardware=%@&",[checkmeInfo hardware]];
    [str appendFormat:@"Software=%@&",[checkmeInfo software]];
    [str appendFormat:@"Language=%@&",[checkmeInfo language]];
    [str appendFormat:@"WantLanguage=%@&",wantLanguage];

    DLog(@"获取的升级包的请求参数为：%@", str);
    return str;
}

@end