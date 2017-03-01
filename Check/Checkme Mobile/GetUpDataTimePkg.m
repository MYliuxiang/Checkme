
//
//  GetUpDataTimePkg.m
//  Checkme Mobile
//
//  Created by Viatom on 2017/1/16.
//  Copyright © 2017年 VIATOM. All rights reserved.
//

#import "GetUpDataTimePkg.h"

@implementation GetUpDataTimePkg
- (instancetype)initWithBuf:(NSData*)buf
{
    self = [super init];
    if (self) {
        U8* tempBuf = (U8*)buf.bytes;
        if(tempBuf[0]!=0x55){
            DLog(@"CommonAck包头错误");
            return nil;
        }else if ((_cmdWord=tempBuf[1]) != ACK_CMD_OK || tempBuf[2] != (U8)~ACK_CMD_OK) {
            DLog(@"CommonAck响应包错误");
            return nil;
        }else if (tempBuf[COMMON_ACK_PKG_LENGTH-1]!=[PublicUtils CalCRC8:tempBuf bufSize:COMMON_ACK_PKG_LENGTH-1]) {
            DLog(@"校验码错误");
            return nil;
        }else {
            
        }
     
        
    }
    return self;
}

@end
