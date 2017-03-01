//
//  UpdataTimePkg.m
//  Checkme Mobile
//
//  Created by Viatom on 2017/1/14.
//  Copyright © 2017年 VIATOM. All rights reserved.
//

#import "UpdataTimePkg.h"
#import "TypesDef.h"

@implementation UpdataTimePkg

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        char *p;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd,HH:mm:ss"];
                NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *str = [NSString stringWithFormat:@"{\"SetTIME\":\"%@\"}",strDate];
        //        NSString *str = ;
        //        NSDictionary *dic = @{@"SetTime":strDate};
        //        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
        p = (char *)[data bytes];
        unsigned short temp = [data length];
        U8 buf[temp + COMMON_PKG_LENGTH];
        memset(buf,0x00,COMMON_PKG_LENGTH);
        buf[0] = 0xAA;
        buf[1] = CMD_WORD_UPTIME;
        buf[2] = ~CMD_WORD_UPTIME;
        buf[3] = 0;//包号，默认0
        buf[4] = 0;
        buf[5] = (temp & 0x00FF);//数据包大小为0
        buf[6] = ((temp>>8) & 0x00FF);
        for(int i = 0;i < temp;i++) buf[i+7] = p[i];
        buf[temp + COMMON_PKG_LENGTH-1] = [PublicUtils CalCRC8:buf bufSize:temp + COMMON_PKG_LENGTH-1];
        _buf = [NSData dataWithBytes:buf length:temp + COMMON_PKG_LENGTH];
        
        
        
//        U8 buf[COMMON_PKG_LENGTH];
//        memset(buf,0x00,COMMON_PKG_LENGTH);
//        buf[0] = 0xAA;
//        buf[1] = CMD_WORD_UPTIME;
//        buf[2] = ~CMD_WORD_UPTIME;
//        buf[3] = 0;//包号，默认0
//        buf[4] = 0;
//        buf[5] = 0;//数据包大小为0
//        buf[6] = 0;
//        buf[COMMON_PKG_LENGTH-1] = [PublicUtils CalCRC8:buf bufSize:COMMON_PKG_LENGTH-1];
//        _buf = [NSData dataWithBytes:buf length:COMMON_PKG_LENGTH];
    }
    return self;
}

@end
