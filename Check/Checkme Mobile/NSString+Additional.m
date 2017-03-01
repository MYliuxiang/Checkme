//
//  NSString+Additional.m
//  DeliveryMS
//
//  Created by demo on 13-6-9.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "NSString+Additional.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additional)  //扩展、协议、分类
#warning 去除两端的空白部分
-(NSString *)stringByDeleteSpaceTowEnds
{
    NSString *origin  = self;
    NSMutableString *result = [NSMutableString stringWithString:origin];
    
    while ([result length]>0 && [result characterAtIndex:0] == (unichar)' ') {
        [result deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    int i = 0 ;
    while ((i = (int)[result length] - 1)>0 && [result characterAtIndex:i] == (unichar)' ') {
        [result deleteCharactersInRange:NSMakeRange(i, 1)];
    }
    return result;
}
#warning 去除空白
-(NSString *)stringByDeleteSpace
{
    NSString *origin  = self;
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceCharacterSet];
    return [origin stringByTrimmingCharactersInSet:whitespace];
}
/*
 将“  早班,中班,晚班, ”格式的字符串分开，返回字符串数组 【“早班” ， “中班” ， “晚班”】
 */
-(NSArray *)strArrBySepChar:(unichar)c{
    NSString *str = self;
    if([str length] <= 0)//判断字符的长度是否小于0
        return nil;
    NSMutableString *strNoBlk = [NSMutableString stringWithString:[str stringByDeleteSpace]];
    if([strNoBlk characterAtIndex:[strNoBlk length] - 1] != c)
        [strNoBlk appendFormat:@"%c",c];
    
    NSMutableArray *arrRet =  [NSMutableArray array];
    for(int end = 0, start = 0; end < [strNoBlk length]; ){
        while(( end < [strNoBlk length]) && ([strNoBlk characterAtIndex:end] != c )) ++end;
        if(end >= [strNoBlk length]) break;
        
        NSRange range = NSMakeRange(start, end - start);
        NSString *subStr = [strNoBlk substringWithRange:range];
        [arrRet addObject:subStr];
        start = ++end;
    }
    return arrRet;
}
/*
+ (NSString *) numericRandomString : (CGFloat) len
{
    NSString *s = [NSString stringWithFormat:@"%f",len];
    
    NSRange range = [s rangeOfString:@"."];
    
    NSString *subStr = s;
    
    if ([s length] > range.location + 3) {
        subStr = [s substringToIndex:range.location + 3];
    }
     
    return subStr;
}*/

+(NSString *) numericRandomString : (int) len
{
#define RandomNum0_9() (arc4random() % 10)  //设置一个宏,/取   随机数  0 ~ 9
    NSMutableString *string  = [NSMutableString string] ; //[[NSMutableString alloc] init] autorelease];  //需要使用自动释放池么??
    
    for(int i = 0  ; i < len ; )
    {
        char num = RandomNum0_9() + '0' ;
        
        if(i >1 && (num == [string UTF8String][i - 1 ] || num == [string UTF8String][i-2]))
            continue ;
        [string appendFormat:@"%c", num] ;
        ++i ;//前++（先算加法然后在显示）
    }
    return string ;
}

//加密算法
- (NSString *) md5HexDigest
{
    const char *original_str = [self UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        
        [hash appendFormat:@"%02X", result[i]];
  
#warning lowercaseString  (小写字母字符串)
    return [hash lowercaseString];
    
}

//正则表达式(email  邮箱验证)
-(BOOL)isValidateEmail {
    NSString *email  = self;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(NSArray *)arrFromEveryChar
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger index = 0; index < [self length]; index++) {
        [arr addObject:[self substringWithRange:NSMakeRange(index, 1)]];
    }
    return arr;
}

@end
