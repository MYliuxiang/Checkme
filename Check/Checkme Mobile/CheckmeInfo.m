//
//  CheckmeInfo.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "CheckmeInfo.h"

@implementation CheckmeInfo

//被调用处即发网络请求的地方
-(instancetype)initWithJSONStr:(NSData*) data
{
    self = [super init];
    if (self) {
        NSError *err;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
        
        DLog(@"checkmeinfo  jsonObject = %@", jsonObject);
        _region = [jsonObject objectForKey:@"Region"];
        _model = [jsonObject objectForKey:@"Model"];
        _hardware = [jsonObject objectForKey:@"HardwareVer"];
        _software = [jsonObject objectForKey:@"SoftwareVer"];
        _language = [jsonObject objectForKey:@"LanguageVer"];
        _theCurLanguage = [jsonObject objectForKey:@"CurLanguage"];
        _sn = [jsonObject objectForKey:@"SN"];
        _sn = jsonObject[@"SN"];
        self.SPCPVer = [jsonObject objectForKey:@"SPCPVer"];
        self.FileVer = [jsonObject objectForKey:@"FileVer"];
        self.Application = [jsonObject objectForKey:@"Application"];
    
    }
    return self;
}

@end
