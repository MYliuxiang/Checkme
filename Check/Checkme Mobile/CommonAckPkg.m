//
//  CommonAckPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "CommonAckPkg.h"
#import "BTDefines.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@interface CommonAckPkg(){
    
}

@end

@implementation CommonAckPkg


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
//        _cmdWord = tempBuf[2];
//        _errCode = tempBuf[3];
    }
    return self;
}

@end
