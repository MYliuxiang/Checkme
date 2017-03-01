//
//  GetInfoPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "GetInfoPkg.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@implementation GetInfoPkg

- (instancetype)init
{
    self = [super init];
    if (self) {
        U8 buf[COMMON_PKG_LENGTH]; //  包的长度  （8）
        memset(buf, 0, COMMON_PKG_LENGTH);
        buf[0] = 0xAA;
        buf[1] = CMD_WORD_GET_INFO;
        buf[2] = ~CMD_WORD_GET_INFO;
        
        buf[COMMON_PKG_LENGTH-1] = [PublicUtils CalCRC8:buf bufSize:COMMON_PKG_LENGTH-1];
        _buf = [NSData dataWithBytes:buf length:COMMON_PKG_LENGTH];
    }
    return self;
}
@end
