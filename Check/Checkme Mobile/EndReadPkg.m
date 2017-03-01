//
//  EndReadPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/21.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "EndReadPkg.h"
#import "BTDefines.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@implementation EndReadPkg

- (instancetype)init
{
    self = [super init];
    if (self) {
        U8 buf[COMMON_PKG_LENGTH];
        memset(buf,0x00,COMMON_PKG_LENGTH);
        buf[0] = 0xAA;
        buf[1] = CMD_WORD_END_READ;
        buf[2] = ~CMD_WORD_END_READ;
        buf[3] = 0;//包号，默认0
        buf[4] = 0;
        buf[5] = 0;//数据包大小为0
        buf[6] = 0;
        buf[COMMON_PKG_LENGTH-1] = [PublicUtils CalCRC8:buf bufSize:COMMON_PKG_LENGTH-1];
        _buf = [NSData dataWithBytes:buf length:COMMON_PKG_LENGTH];
    }
    return self;
}


@end
