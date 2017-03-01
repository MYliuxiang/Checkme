//
//  WriteContentPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "WriteContentPkg.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@implementation WriteContentPkg

- (instancetype)initWithBuf:(NSData *)inBuf pkgNum:(int)pkgNum cmd:(int)cmd
{
    self = [super init];
    if (self) {
        if (inBuf.length>WRITE_CONTENT_PKG_DATA_LENGTH) {
            DLog(@"写入数据过长");
            return nil;
        }
        U8* dataBuf = (U8 *)inBuf.bytes;
        int bufLenght = inBuf.length+COMMON_PKG_LENGTH;
        U8 buf[bufLenght];
        buf[0] = 0xAA;
        buf[1] = cmd;
        buf[2] = ~cmd;
        buf[3] = pkgNum;
        buf[4] = pkgNum>>8;
        buf[5] = inBuf.length;
        buf[6] = inBuf.length>>8;
        
        for (int i=0; i<inBuf.length; i++) {
            buf[i+7] = dataBuf[i];
        }
        buf[bufLenght-1] = [PublicUtils CalCRC8:buf bufSize:bufLenght-1];
        _buf = [NSData dataWithBytes:buf length:bufLenght];
    }
    return self;
}

@end
