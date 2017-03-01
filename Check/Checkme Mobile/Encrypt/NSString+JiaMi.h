//
//  NSString+JiaMi.h
//  XINRUE
//
//  Created by yunhe on 14/12/12.
//  Copyright (c) 2014年 yunhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (JiaMi)

//url编码
- (NSString *)URLEncodedString;
//md加密
- (NSString *)md5Digest:(NSString *)str;

+ (NSString*) stringWithGUID;
@end
