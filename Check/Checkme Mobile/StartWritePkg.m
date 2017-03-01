//
//  StartWritePkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "StartWritePkg.h"

@implementation StartWritePkg


- (instancetype)initWithFileName:(NSString *)fileName fileSize:(U32)size cmd:(int)cmd
{
    self = [super init];
    if (self) {
        if(fileName.length>BT_WRITE_FILE_NAME_MAX_LENGTH){
            DLog(@"读命令文件名超长");
        }
        //buf长度，+1相当于\0，+4文件size
        int bufLength = COMMON_PKG_LENGTH + fileName.length + 1 + 4;
        U8 buf[bufLength];
        memset(buf,0x00,bufLength);
        buf[0] = 0xAA;
        buf[1] = cmd;
        buf[2] = ~cmd;
        buf[3] = 0; //包号
        buf[4] = 0;
        buf[5] = bufLength - COMMON_PKG_LENGTH; //数据长度
        buf[6] = (bufLength - COMMON_PKG_LENGTH) >> 8;
        buf[7] = size;
        buf[8] = size >> 8;
        buf[9] = size >> 16;
        buf[10] = size >> 24;
        for (int i=0; i<fileName.length; i++) {
            buf[i+11] = [fileName characterAtIndex:i];
        }
        buf[bufLength-1] = [PublicUtils CalCRC8:buf bufSize:bufLength-1];
        _buf = [NSData dataWithBytes:buf length:bufLength];
    }
    return self;
}

@end
