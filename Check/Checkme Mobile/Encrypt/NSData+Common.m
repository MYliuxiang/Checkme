//
//  NSData+Common.m
//  Controls
//
//  Created by C-147 on 13-2-21.
//  Copyright (c) 2013年 C-147. All rights reserved.
//

#import "NSData+Common.h"
#import "GTMBase64.h"

@implementation NSData (Common)

//生成UUID
+ (NSData*)uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuid_ref);
    NSData* data  = [NSData dataWithBytes: &bytes length: sizeof(bytes)];
    CFRelease(uuid_ref);
    return data;
}

@end

//数据: 编码解码
@implementation NSData (Encoding)

//base64编码
- (NSData *)encodeWithBase64{
    return [GTMBase64 encodeData:self];
}
//base64解码
- (NSData *)decodeWithBase64{
    return [GTMBase64 decodeData:self];
}

//quoted printable编码
- (NSData *)encodeWithQuotedPrintable{
    //RFC 2821.规定每行最长不超过76个字符
    return [self encodeWithQuotedPrintableAndMaxLineLength:76];
}
- (NSData *)encodeWithQuotedPrintableAndMaxLineLength:(NSUInteger)maxLineLength{
    maxLineLength -= 3;
    NSUInteger maxLength = self.length * 3;//最杯具的长度
    maxLength += (maxLength / maxLineLength) * 3;//加上换行符
    NSMutableData *result = [[NSMutableData alloc] initWithLength:maxLength];
    
    const Byte* pSrc = (const Byte*)self.bytes;
    const Byte* pSrcEnd = pSrc + self.length;
    Byte* pDst = (Byte*)result.mutableBytes;
    Byte* pDstStart = pDst;
    NSUInteger lineLength = 0;
    
    while (pSrc < pSrcEnd) {
        // ASCII 33-60, 62-126原样输出，其余的需编码
        if ((*pSrc >= '!') && (*pSrc <= '~') && (*pSrc != '=')){
            *(pDst++) = *(pSrc++);
            lineLength++;
        }else{
            //编码
            Byte sour = *(pSrc++);
            Byte first=sour>>4;
            Byte second=sour&15;
            if(first>9) first+=55;
            else first+=48;
            if(second>9) second+=55;
            else second+=48;
            *(pDst++) = '=';
            *(pDst++) = first;
            *(pDst++) = second;
            lineLength += 3;
        }
        // 输出换行？
        if (lineLength >= maxLineLength)
        {
            *(pDst++) = '=';
            *(pDst++) = '\r';
            *(pDst++) = '\n';
            lineLength = 0;
        }
    }
    //真实的长度
    [result setLength:pDst - pDstStart];
    return result;
}
//quoted printable解码
- (NSData *)decodeWithQuotedPrintable{
    NSMutableData *result = [[NSMutableData alloc] initWithLength:self.length];
    
    const Byte* pSrc = (const Byte*)self.bytes;
    const Byte* pSrcEnd = pSrc + self.length;
    Byte* pDst = (Byte*)result.mutableBytes;
    Byte* pDstStart = pDst;

    while (pSrc < pSrcEnd) {
        // 是编码字节
        if (*pSrc == '='){
            pSrc++;
            Byte first = *(pSrc++);
            Byte second = *(pSrc++);
            // 非软回车，继续
            if (first != '\r' || second != '\n') {
                //解码
                if(first>=65) first-=55;
                else first-=48;
                if(second>=65) second-=55;
                else second-=48;
                Byte sour=NULL;
                sour=first<<4;
                sour|=second;
                *(pDst++) = sour;
            }
        // 非编码字节
        }else{
            *(pDst++) = *(pSrc++);
        }
    }
    //真实的长度
    [result setLength:pDst - pDstStart];
    return result;
}


//7bit编码
- (NSData *)encodeWith7bit{
    //暂不实现
    [NSException raise:@"未实现的方法" format:@"未实现的方法: %s",__FUNCTION__];
    return self;
}
//7bit解码
- (NSData *)decodeWith7bit{
    //暂不实现
    [NSException raise:@"未实现的方法" format:@"未实现的方法: %s",__FUNCTION__];
    return self;
}

@end