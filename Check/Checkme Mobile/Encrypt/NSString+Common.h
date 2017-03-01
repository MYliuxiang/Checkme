//
//  NSString+Common.h
//  Controls
//
//  Created by C-147 on 13-2-8.
//  Copyright (c) 2013年 C-147. All rights reserved.
//

#import <Foundation/Foundation.h>

//创建字符串
#define StrMake(fm,...) [NSString stringWithFormat:fm, ##__VA_ARGS__]
//连接字符串
#define StrConnect(f,...) [NSMutableString stringWithStrings:f,##__VA_ARGS__,nil]

#define StrConnect2(s1,s2) [NSString stringWithFormat:@"%@%@",s1,s2]
#define StrConnect3(s1,s2,s3) [NSString stringWithFormat:@"%@%@%@",s1,s2,s3]
#define StrConnect4(s1,s2,s3,s4) [NSString stringWithFormat:@"%@%@%@%@",s1,s2,s3,s4]
#define StrConnect5(s1,s2,s3,s4,s5) [NSString stringWithFormat:@"%@%@%@%@%@",s1,s2,s3,s4,s5]
#define StrConnect6(s1,s2,s3,s4,s5,s6) [NSString stringWithFormat:@"%@%@%@%@%@%@",s1,s2,s3,s4,s5,s6]
#define StrConnect7(s1,s2,s3,s4,s5,s6,s7) [NSString stringWithFormat:@"%@%@%@%@%@%@%@",s1,s2,s3,s4,s5,s6,s7]
#define StrConnect8(s1,s2,s3,s4,s5,s6,s7,s8) [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",s1,s2,s3,s4,s5,s6,s7,s8]
#define StrConnect9(s1,s2,s3,s4,s5,s6,s7,s8,s9) [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",s1,s2,s3,s4,s5,s6,s7,s8,s9]
//编码解码
#define UrlEncode(s) ([s isKindOfClass:[NSString class]] ? [s urlEncode] : s)
#define UrlDecode(s) ([s isKindOfClass:[NSString class]] ? [s urlDecode] : s)
#define UrlEncodeSinglePart(s) ([s isKindOfClass:[NSString class]] ? [s urlEncodeSinglePart] : s)

//字符串: 公共
@interface NSString (Common)

//通用NSData生成NSString
+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
//将所有字符串串连起来生成新的NSString
+ (NSString*)stringWithStrings:(NSString*)firstStr,...;

//将头尾的空格去掉
- (NSString*)trim;
//将头尾指定的字符(各个字符，非连续)去掉
- (NSString*)trim:(NSString*)chars;
//将头尾指定的字符串去掉
- (NSString*)trimString:(NSString*)string;
//将头部指定的字符(各个字符，非连续)去掉
- (NSString*)trimStart:(NSString*)chars;
//将头尾指定的字符串去掉
- (NSString*)trimStartString:(NSString*)string;
//将尾部指定的字符(各个字符，非连续)去掉
- (NSString*)trimEnd:(NSString*)chars;
//将尾部指定的字符串去掉
- (NSString*)trimEndString:(NSString*)string;
//将前后指定的字符(各个字符，非连续)去掉
- (NSString*)trimStart:(NSString*)start End:(NSString*)end;
//判断字符串是否为空
+ (BOOL)isNullOrEmpty:(NSString*)string;
//判断字符串是否为空
- (BOOL)isNullOrEmpty;

//判断是否一样：不区分大小写
- (BOOL)isEqualToCaseInsensitiveString:(NSString *)aString;

//生成UUID(16进制表示,UTF8)
+ (NSString*)uuid;
//生成UUID(Base64编码,UTF8)
+ (NSString*)uuidWithBase64;

/**
 *	@brief	比较版本号
 *
 *	@param 	aString 	新字符串
 *
 *	@return	比较结果
 */
- (NSComparisonResult)compareVersionNumber:(NSString*)aString;

@end

//可变字符串: 公共
@interface NSMutableString (Common)

//通用NSData生成NSString
+ (NSMutableString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
//将所有字符串串连起来生成新的NSString
+ (NSMutableString*)stringWithStrings:(NSString*)firstStr,...;

@end

//字符串: 格式验证
@interface NSString (FormatValidation)

//正则表达式验证
- (BOOL)isValidateExpression:(NSString*)expression;
//验证邮箱格式
- (BOOL)isValidateEmail;
//手机号码验证
- (BOOL)isValidateMobile;
//车牌号验证
- (BOOL)isValidateCarNo;

@end

//字符串: 加密解密
@interface NSString (Encryption)

//生成MD5
- (NSString*)md5;
/**
 *	@brief	3DES加密后转成BASE64编码
 *
 *	@return	加密后的Base64字符串
 */
- (NSString*)tripleDESEncryptToBase64WithKey:(NSString*)key iv:(NSString*)iv;
/**
 *	@brief	将3DES加密过后用BASE64编码的字符串解密
 *
 *	@return	解密后的字符串
 */
- (NSString*)tripleDESDecryptFromBase64WithKey:(NSString*)key iv:(NSString*)iv;

@end

//字符串: 编码解码
@interface NSString (Encoding)

//Url编码
- (NSString *)encodeWithPercentEscapeString;
//Url解码
- (NSString *)decodeWithPercentEscapeString;
//完整路径的Url编码
- (NSString *)urlEncode;
//Url编码
- (NSString *)urlEncodeSinglePart;
//Url解码
- (NSString *)urlDecode;

//base64编码:源使用UTF8，结果使用ASCII
- (NSString *)encodeWithBase64;
//base64解码:源使用ASCII，结果使用UTF8
- (NSString *)decodeWithBase64;

//quoted printable编码:源使用UTF8，结果使用ASCII
- (NSString *)encodeWithQuotedPrintable;
//quoted printable解码:源使用ASCII，结果使用UTF8
- (NSString *)decodeWithQuotedPrintable;

@end