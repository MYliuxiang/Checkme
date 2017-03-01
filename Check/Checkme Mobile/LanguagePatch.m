//
//  LanguagePatch.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "LanguagePatch.h"

@implementation LanguagePatch

-(instancetype)initWithJSON:(NSDictionary*)jsonObject
{
    if (!jsonObject) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _region = [jsonObject objectForKey:@"LanguageRegion"];
        _model = [jsonObject objectForKey:@"LanguageModel"];
        _hardware = [jsonObject objectForKey:@"LanguageHardware"];
        _version = [[jsonObject objectForKey:@"LanguageVersion"] intValue];
        _address = [jsonObject objectForKey:@"LanguageAddress"];
        //包含语言列表，将数组转换为一条字符串
        NSArray *languageList = [jsonObject objectForKey:@"LanguageLanguages"];
        _languages = [NSMutableString string];
        for (int i = 0; i < languageList.count; i++) {//处理语言列表
            [_languages appendString:[languageList objectAtIndex:i]];
            [_languages appendString:@","];
        }
    }
    return self;
}

@end
