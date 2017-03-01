//
//  NSData+Common.h
//  Controls
//
//  Created by C-147 on 13-2-21.
//  Copyright (c) 2013年 C-147. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Common)

//生成UUID
+ (NSData*)uuid;

@end

//数据: 编码解码
@interface NSData (Encoding)

//base64编码
- (NSData *)encodeWithBase64;
//base64解码
- (NSData *)decodeWithBase64;

//quoted printable编码
- (NSData *)encodeWithQuotedPrintable;
- (NSData *)encodeWithQuotedPrintableAndMaxLineLength:(NSUInteger)maxLineLength;
//quoted printable解码
- (NSData *)decodeWithQuotedPrintable;

//7bit编码
- (NSData *)encodeWith7bit;
//7bit解码
- (NSData *)decodeWith7bit;

@end