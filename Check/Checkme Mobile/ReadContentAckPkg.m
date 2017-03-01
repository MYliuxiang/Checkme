//
//  ReadContentAckPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ReadContentAckPkg.h"
#import "BTDefines.h"

@interface ReadContentAckPkg(){
    
}

@end

@implementation ReadContentAckPkg


- (instancetype)initWithBuf:(NSData*)inBuf
{
    self = [super init];
    if (self) {
        U8* buf = (U8 *)inBuf.bytes;
        
        if(inBuf.length>READ_CONTENT_ACK_DATA_LENGTH+READ_CONTENT_ACK_PKG_FRONT_LENGTH){ //（512 + 8）
            DLog(@"ReadContentAckPkg长度错误");
            return nil;
        }
        if(buf[0]!=0x55){
            DLog(@"ReadContentAckPkg包头错误");
            return nil;
        }else if ((_cmdWord=buf[1]) != ACK_CMD_OK || buf[2] != (U8)~ACK_CMD_OK) {
            DLog(@"ReadContentAckPkg错误回应包");
            return nil;
        }else if (buf[inBuf.length-1]!=[PublicUtils CalCRC8:buf bufSize:inBuf.length-1]) {
            DLog(@"校验码错误");
            return nil;
        }
        _dataLength = buf[5] | buf[6]<<8;
        if (_dataLength>READ_CONTENT_ACK_DATA_LENGTH || _dataLength>inBuf.length-READ_CONTENT_ACK_PKG_FRONT_LENGTH) {
            DLog(@"ReadContentAckPkg数据长度错误");
            return nil;
        }
        U8 tempBuf[_dataLength];
        for (int i = 0; i < _dataLength; i++) {
            tempBuf[i] = buf[7+i];
        }
        _dataBuf = [[NSData alloc]initWithBytes:tempBuf length:_dataLength];
    }
    return self;
}

@end
