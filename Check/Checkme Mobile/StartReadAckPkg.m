//
//  StartReadAckPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/21.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "StartReadAckPkg.h"
#import "BTDefines.h"


@implementation StartReadAckPkg

- (instancetype)initWithBuf:(NSData*)buf
{
    self = [super init];
    if (self) {
        U8* tempBuf = (U8*)buf.bytes;
        if(tempBuf[0]!=0x55){
            DLog(@"CommonAck包头错误");
            return nil;
        }else if ((_cmdWord=tempBuf[1]) != ACK_CMD_OK || tempBuf[2] != (U8)~ACK_CMD_OK) {
            DLog(@"CommonAck错误回应包");
            return nil;
        }else if (tempBuf[COMMON_ACK_PKG_LENGTH-1]!=[PublicUtils CalCRC8:tempBuf bufSize:COMMON_ACK_PKG_LENGTH-1]) {
            DLog(@"校验码错误");
            return nil;
        }
        
        _fileSize = (tempBuf[7]&0xFF) | (tempBuf[8]&0xFF)<<8 | (tempBuf[9]&0xFF)<<16 | (tempBuf[10]&0xFF)<<24;
    }
    return self;
}

@end
