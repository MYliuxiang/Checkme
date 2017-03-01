//
//  NSString+Additional.h
//  DeliveryMS
//
//  Created by demo on 13-6-9.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//


#import <Foundation/Foundation.h>
#warning 字符串的扩展(增强字符串NSString的功能)

@interface NSString (Additional)

//去除两端空格
-(NSString *)stringByDeleteSpaceTowEnds;
//去除所有空白符
- (NSString *)stringByDeleteSpace;
- (NSArray  *)strArrBySepChar:(unichar)c;
//+ (NSString *)numericRandomString:(CGFloat) len;
+(NSString *) numericRandomString : (int) len;

- (NSString *) md5HexDigest;//md5加密
-(BOOL)isValidateEmail;
-(NSArray *)arrFromEveryChar;
@end





//三巨头:  詹姆斯、韦德、波什