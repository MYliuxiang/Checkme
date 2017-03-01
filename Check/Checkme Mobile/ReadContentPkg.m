//
//  ReadContentPkg.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ReadContentPkg.h"
#import "BTDefines.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@interface ReadContentPkg(){
    
}
//@property(nonatomic,assign) U8* buf;

@end

@implementation ReadContentPkg


- (instancetype)initWithPkgNum:(U32)pkgNum
{
    self = [super init];
    if (self) {
        U8 buf[COMMON_PKG_LENGTH];
        memset(buf,0x00,COMMON_PKG_LENGTH);
        buf[0] = 0xAA;
        buf[1] = CMD_WORD_READ_CONTENT;
        buf[2] = ~CMD_WORD_READ_CONTENT;
        buf[3] = pkgNum;//包号
        buf[4] = pkgNum >> 8;
        buf[5] = 0;//数据包
        buf[6] = 0;
        buf[COMMON_PKG_LENGTH-1] = [PublicUtils CalCRC8:buf bufSize:COMMON_PKG_LENGTH-1];
        
        _buf = [NSData dataWithBytes:buf length:COMMON_PKG_LENGTH];
    }
    return self;
}


@end
