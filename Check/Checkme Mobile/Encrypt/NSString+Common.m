//
//  NSString+Common.m
//  Controls
//
//  Created by C-147 on 13-2-8.
//  Copyright (c) 2013年 C-147. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Common.h"
#import "GTMBase64.h"

//字符串: 公共
@implementation NSString (Common)

//通用NSData生成NSString
+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding{
    return [[[self class] alloc] initWithData:data encoding:encoding];
}
//将所有字符串串连起来生成新的NSString
+ (NSString*)stringWithStrings:(NSString*)firstStr,...{
    NSMutableString *result = nil;
    id eachStr;
    va_list argumentList;
    if (firstStr)
    {
        result = [[NSMutableString alloc] initWithString:firstStr];
        va_start(argumentList, firstStr);
        while ((eachStr = va_arg(argumentList, id)))
            [result appendString:eachStr];
        va_end(argumentList);
    }
    return result;
}

//将头尾的空格去掉
- (NSString*)trim{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:charSet];
}
//将头尾指定的字符(各个字符，非连续)去掉
- (NSString*)trim:(NSString*)chars{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:chars];
    return [self stringByTrimmingCharactersInSet:charSet];
}
//将头尾指定的字符串去掉
- (NSString*)trimString:(NSString*)string{
	NSMutableString *mutableString = [self mutableCopy];
	CFStringTrim((CFMutableStringRef)mutableString,(CFStringRef)string);
	NSString *strResult = [mutableString copy];
	return strResult;
}
- (NSRange)rangeWithoutStart:(NSString*)start end:(NSString*)end{
    NSRange range = NSMakeRange(0, self.length);
    //start
    if (![NSString isNullOrEmpty:start]) {
        BOOL find = YES;
        for (int i = 0; i < self.length; i++) {
            find = NO;
            unichar c = [self characterAtIndex:i];
            for (int j = 0; j < start.length; j++) {
                if (c == [start characterAtIndex:j]) {
                    find = YES;
                    range.location++;
                    range.length--;
                    break;
                }
            }
            if (!find) break;
        }
        if (find) {
            range.location = NSNotFound;
            range.length = 0;
        }
    }
    if (![NSString isNullOrEmpty:end]) {
        BOOL find = YES;
        for (int i = (int)self.length - 1; i >= range.location; i--) {
            find = NO;
            if (range.length == 0) break;
            unichar c = [self characterAtIndex:i];
            for (int j = 0; j < end.length; j++) {
                if (c == [end characterAtIndex:j]) {
                    find = YES;
                    range.length--;
                    break;
                }
            }
            if (!find) break;
        }
        if (find) {
            range.location = NSNotFound;
            range.length = 0;
        }
    }
    return range;
}
//将头部指定的字符(各个字符，非连续)去掉
- (NSString*)trimStart:(NSString*)chars{
    NSRange range = [self rangeWithoutStart:chars end:nil];
    if (range.location == NSNotFound) {
        return self;
    }
    return [self substringWithRange:range];
}
//将头尾指定的字符串去掉
- (NSString*)trimStartString:(NSString*)string{
    NSString *result = self;
    while ([result hasPrefix:string]) {
        result = [result substringFromIndex:string.length];
    }
    return result;
}
//将尾部指定的字符(各个字符，非连续)去掉
- (NSString*)trimEnd:(NSString*)chars{
    NSRange range = [self rangeWithoutStart:nil end:chars];
    if (range.location == NSNotFound) {
        return self;
    }
    return [self substringWithRange:range];
}
//将尾部指定的字符串去掉
- (NSString*)trimEndString:(NSString*)string{
    NSString *result = self;
    while ([result hasSuffix:string]) {
        result = [result substringWithRange:NSMakeRange(0, result.length - string.length)];
    }
    return result;
}
//将前后指定的字符(各个字符，非连续)去掉
- (NSString*)trimStart:(NSString*)start End:(NSString*)end{
    return [self substringWithRange:[self rangeWithoutStart:start end:end]];
}
//判断字符串是否为空
+ (BOOL)isNullOrEmpty:(NSString*)string{
    if (string == nil) return YES;
    if ([string isKindOfClass:[NSNull class]]) return YES;
    if (string.length == 0) return YES;
    if ([string trim].length == 0) return YES;
    return NO;
}
//判断字符串是否为空
- (BOOL)isNullOrEmpty{
    return [NSString isNullOrEmpty:self];
}

//判断是否一样：不区分大小写
- (BOOL)isEqualToCaseInsensitiveString:(NSString *)aString{
    return [[self lowercaseString] isEqualToString:[aString lowercaseString]];
}

//生成UUID(16进制表示)
+ (NSString*)uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}
//生成U-ID(Base64编码,UTF8)
+ (NSString*)uuidWithBase64{
    NSData *data = [NSData uuid];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSComparisonResult)compareVersionNumber:(NSString*)aString{
    NSString *exp = @"[0-9]+(?:\\.[0-9]+)*";
    BOOL fValidated = [self isValidateExpression:exp];
    BOOL sValidated = [aString isValidateExpression:exp];
    if (fValidated && sValidated) {
        NSArray *fVers = [self componentsSeparatedByString:@"."];
        NSArray *sVers = [aString componentsSeparatedByString:@"."];
        int i = 0;
        for (; i < fVers.count && i < sVers.count; i++) {
            int fVer = [fVers[i] intValue];
            int sVer = [sVers[i] intValue];
            if (fVer > sVer) {
                return NSOrderedDescending;
            }else if(fVer < sVer){
                return NSOrderedAscending;
            }
        }
        if (i < fVers.count) {
            return NSOrderedDescending;
        }else if (i < sVers.count){
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }else{
        if (fValidated) {
            return NSOrderedDescending;
        }else if(sValidated){
            return NSOrderedAscending;
        }else{
            return [self compare:aString];
        }
    }
}

@end

//可变字符串: 公共
@implementation NSMutableString (Common)

//通用NSData生成NSString
+ (NSMutableString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding{
    return [[[self class] alloc] initWithData:data encoding:encoding];
}
//将所有字符串串连起来生成新的NSString
+ (NSMutableString*)stringWithStrings:(NSString*)firstStr,...{
    NSMutableString *result = nil;
    id eachStr;
    va_list argumentList;
    if (firstStr)
    {
        result = [[NSMutableString alloc] initWithString:firstStr];
        va_start(argumentList, firstStr);
        while ((eachStr = va_arg(argumentList, id)))
            [result appendString:eachStr];
        va_end(argumentList);
    }
    return result;
}

@end

//字符串: 格式验证
@implementation NSString (FormatValidation)

-(NSMutableArray *)substringByExpression:(NSString *)expression{
    NSRange r= [self rangeOfString:expression options:NSRegularExpressionSearch];
    NSMutableArray *arr=[NSMutableArray array];
    
    if (r.length != NSNotFound &&r.length != 0) {
        while (r.length != NSNotFound &&r.length != 0) {
            NSString* substr = [self substringWithRange:r];
            [arr addObject:substr];
            
            NSRange startr=NSMakeRange(r.location+r.length, [self length]-r.location-r.length);
            r=[self rangeOfString:expression options:NSRegularExpressionSearch range:startr];
        }
    }
    return arr;
}

//正则表达式验证
- (BOOL)isValidateExpression:(NSString*)expression{
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    return [regexTest evaluateWithObject:self];
}
//邮箱验证
- (BOOL)isValidateEmail{
    return [self isValidateExpression:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
}
//手机号码验证
- (BOOL)isValidateMobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    return [self isValidateExpression:@"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"];
}
//车牌号验证
- (BOOL)isValidateCarNo
{
    return [self isValidateExpression:@"^[A-Za-z]{1}[A-Za-z_0-9]{5}$"];
}

@end

//字符串: 加密解密
@implementation NSString (Encryption)

//生成MD5
-(NSString *)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
- (NSString*)tripleDESEncryptToBase64WithKey:(NSString*)key iv:(NSString*)iv{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [iv UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    free(bufferPtr);
    return result;
}
- (NSString*)tripleDESDecryptFromBase64WithKey:(NSString*)key iv:(NSString*)iv{
    NSData *encryptData = [GTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [iv UTF8String];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                      length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    free(bufferPtr);
    return result;
}

@end

//字符串: 编码解码
@implementation NSString (Encoding)

//Url编码
- (NSString *)encodeWithPercentEscapeString{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    return outputStr;
}
//Url解码
- (NSString *)decodeWithPercentEscapeString{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
//完整路径的Url编码
- (NSString *)urlEncode{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            (CFStringRef)@"\\",
                                            NULL,
                                            kCFStringEncodingUTF8));
    return outputStr;
}
//Url编码
- (NSString *)urlEncodeSinglePart{
    return [self encodeWithPercentEscapeString];
}
//Url解码
- (NSString *)urlDecode{
    return [self decodeWithPercentEscapeString];
}

//base64编码:使用ASCII
- (NSString *)encodeWithBase64{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] encodeWithBase64];
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
//base64解码:使用ASCII
- (NSString *)decodeWithBase64{
    NSData *data = [[self dataUsingEncoding:NSASCIIStringEncoding] decodeWithBase64];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//quoted printable编码:使用ASCII
- (NSString *)encodeWithQuotedPrintable{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] encodeWithQuotedPrintable];
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
//quoted printable解码:使用ASCII
- (NSString *)decodeWithQuotedPrintable{
    NSData *data = [[self dataUsingEncoding:NSASCIIStringEncoding] decodeWithQuotedPrintable];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
