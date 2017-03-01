//
//  NSString+JiaMi.m
//  XINRUE
//
//  Created by yunhe on 14/12/12.
//  Copyright (c) 2014年 yunhe. All rights reserved.
//

#import "NSString+JiaMi.h"

@implementation NSString (JiaMi)

//md5加密
- (NSString *)md5Digest:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    NSString *string = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]];
    
    NSString *string2 = [string lowercaseString];
    return string2;
}

- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString*) stringWithGUID {
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString  *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}




@end
