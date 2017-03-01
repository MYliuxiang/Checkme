//
//  AppPatch.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "AppPatch.h"

@implementation AppPatch

-(instancetype)initWithJSON:(NSDictionary*)jsonObject
{
    if (!jsonObject) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _region = [jsonObject objectForKey:@"AppRegion"];
        _model = [jsonObject objectForKey:@"AppModel"];
        _hardware = [jsonObject objectForKey:@"AppHardware"];
        _version = [[jsonObject objectForKey:@"AppVersion"] intValue];
       // _address = [jsonObject objectForKey:@"AppAddress"];
        self.address = [jsonObject objectForKey:@"AppAddress"];
    }
    return self;
}

@end
