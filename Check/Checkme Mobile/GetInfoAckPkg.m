//
//  GetInfoAckPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "GetInfoAckPkg.h"
#import "BTDefines.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@implementation GetInfoAckPkg

- (instancetype)initWithBuf:(NSData*)buf
{
    self = [super init];
    if (self) {
        if ([buf length] != GET_INFO_ACK_PKG_LENGTH) {
            DLog(@"GetInfoAck包大小错误");
            return nil;
        }
        U8* tempBuf = (U8*)buf.bytes;
        if(tempBuf[0]!=0x55){
            DLog(@"GetInfoAck包头错误");
            return nil;
        }else if ((_cmdWord=tempBuf[1]) != ACK_CMD_OK || tempBuf[2] != (U8)~ACK_CMD_OK) {
            DLog(@"GetInfoAck响应包错误");
            return nil;
        }else if (tempBuf[GET_INFO_ACK_PKG_LENGTH-1]!=[PublicUtils CalCRC8:tempBuf bufSize:GET_INFO_ACK_PKG_LENGTH-1]) {
            DLog(@"校验码错误");
            return nil;
        }
        
        //先转成字符串，去掉数组后面的0
        NSMutableString *infoStr = [NSMutableString string];//定义一个可变类型的字符串
        //从第7位开始为数据位，去掉包头和CRC部分
        for (int i=7; i<GET_INFO_ACK_PKG_LENGTH - COMMON_PKG_LENGTH; i++) {
            if (tempBuf[i] != 0) {
                [infoStr appendFormat:@"%c",tempBuf[i]];
            }else{
                break;
            }
        }
        _infoData = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    return self;
}

@end
