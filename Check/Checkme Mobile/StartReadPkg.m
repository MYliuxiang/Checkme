//
//  StartReadPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "StartReadPkg.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@implementation StartReadPkg

- (instancetype)initWithFileName:(NSString*)fileName
{
    self = [super init];
    if (self) {
        if(fileName.length>BT_READ_FILE_NAME_MAX_LENGTH) {
            DLog(@"读命令文件名超长");
        }
        int bufLength = (int)(COMMON_PKG_LENGTH + fileName.length + 1);//+1相当于\0
        
        U8 buf[bufLength];   //字符串
        memset(buf,0x00,bufLength);    //buf的初始化      将已开辟内存空间的实例buf的首bufLength个字节的值设置为0x00 (即0)
        buf[0] = 0xAA;   // 1010  1010
        buf[1] = CMD_WORD_START_READ;   // 0x03     0000 0011
        buf[2] = ~CMD_WORD_START_READ;  //  取反运算符   1111 1100    0xFC
        buf[3] = 0;//包号，默认0
        buf[4] = 0;
        buf[5] = bufLength - COMMON_PKG_LENGTH;//数据长度   9-8=1
        buf[6] = (bufLength - COMMON_PKG_LENGTH) >> 8;     //1右移8位 = 0
        for (int i=0; i<fileName.length; i++) {
            buf[i+7] = [fileName characterAtIndex:i];
        }

        buf[bufLength-1] = [PublicUtils CalCRC8:buf bufSize:bufLength-1];
        
        _buf = [NSData dataWithBytes:buf length:bufLength];
    }
    
    return self;
}



@end
