//
//  PublicUtils.m
//  libCheckme
//
//  Created by 李乾 on 15/4/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "PublicUtils.h"
#import "BTDefines.h"

@implementation PublicUtils

const unsigned char Table_CRC8[256]={      /*CRC8 ±í*/
    0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
    0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
    0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
    0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
    0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
    0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
    0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
    0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
    0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
    0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
    0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
    0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
    0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
    0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
    0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
    0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
    0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
    0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
    0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
    0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
    0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
    0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
    0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
    0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
    0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
    0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
    0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
    0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
    0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
    0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
    0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
    0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
};

+ (uint8_t)CalCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int)Buffer_Size
{
    uint8_t x,R_CRC_Data;
    uint32_t i;
    
    R_CRC_Data=0;
    for(i=0;i<Buffer_Size;i++)
    {
        x = R_CRC_Data ^ (*RP_ByteData);
        R_CRC_Data = Table_CRC8[x];
        RP_ByteData++;
    }
    return R_CRC_Data;
}

+(NSString *)MakeDateFileName:(NSDateComponents *)date fileType:(U8)type
{
    NSString* dateString = [NSString stringWithFormat:@"%d%02d%02d%02d%02d%02d",date.year,date.month,date.day,date.hour,date.minute,date.second];
    
    if (type==FILE_Type_ECGVoiceData || type == FILE_Type_SpcVoiceData) {
        NSString* voiceString = [NSString stringWithFormat:@"%@.wav",dateString];
        return voiceString;
    }
    return dateString;
}

+ (NSString *)parseECG_innerData_ecgResultDescribWith:(NSString *)ecgResultDescrib
{
    NSArray *ecgResults = [ECG_RESULT_ARRAYS copy];
    U8 result = [ecgResultDescrib intValue];
    NSString *str = @"";
    if(result==0xFF)
        str = ecgResults[7];
    else if(result==0)
        str = ecgResults[0];
    else{
        for (int i=0; i<9; i++) {
            //第一条前面不加回车
            NSString *tempStr = (result&(1<<i)) == 0 ? @"" : ( str.length<1 ? ecgResults[i+1] : [NSString stringWithFormat:@"\r\n%@",ecgResults[i+1]]);
            str = [str stringByAppendingString:tempStr];
        }
    }
    return str;
}

+(float)get_PPI_ofCurDevice
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if( [platform hasPrefix:@"iPhone1"]
       || [platform hasPrefix:@"iPhone2"]
       || [platform hasPrefix:@"iPhone3"])
        return 163.0f;
    
    if( [platform hasPrefix:@"iPhone4"]
       || [platform hasPrefix:@"iPhone5"]
       || [platform hasPrefix:@"iPhone6"])
        return 326.0f;
    
    //
    // For iPhone6+
    // Added by Gerry 2014.11.22 10:12
    //
    // Note: iPhone6  326ppi
    
    if( [platform hasPrefix:@"iPhone7,2"]) {
        return 326.0f;
    }
    if( [platform hasPrefix:@"iPhone7,1"]) {
        return 401.0f;
    }
    
    if( [platform hasPrefix:@"iPhone8"]) // catch-all for higher-end devices not yet existing
    {
        return 488.0f;
    }
    
    if( [platform hasPrefix:@"iPhone9"]) // catch-all for higher-end devices not yet existing
    {
        
        return 460.0f;
    }
    
    
    
    
    if( [platform hasPrefix:@"iPhone"]) // catch-all for higher-end devices not yet existing
    {
        //        NSAssert(FALSE, @"Not supported yet: you are using an iPhone that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
        return 326.0f;
    }
    
    if( [platform hasPrefix:@"iPod1"]
       || [platform hasPrefix:@"iPod2"]
       || [platform hasPrefix:@"iPod3"])
        return 163.0f;
    
    if( [platform hasPrefix:@"iPod4"]
       || [platform hasPrefix:@"iPod5"])
        return 326.0f;
    
    if( [platform hasPrefix:@"iPod"]) // catch-all for higher-end devices not yet existing
    {
        NSAssert(FALSE, @"Not supported yet: you are using an iPod that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
        return 326.0f;
    }
    
    
    
    // iPad 第一代
    if ([platform isEqualToString:@"iPad1,1"])   return 132;
    
    // iPad 第二代
    if ([platform isEqualToString:@"iPad2,1"])   return 132;
    if ([platform isEqualToString:@"iPad2,2"])   return 132;
    if ([platform isEqualToString:@"iPad2,3"])   return 132;
    if ([platform isEqualToString:@"iPad2,4"])   return 132;
    
    // iPad mini 1
    if ([platform isEqualToString:@"iPad2,5"])   return 163;
    if ([platform isEqualToString:@"iPad2,6"])   return 163;
    if ([platform isEqualToString:@"iPad2,7"])   return 163;
    
    // iPad 第三代
    if ([platform isEqualToString:@"iPad3,1"])   return 264;
    if ([platform isEqualToString:@"iPad3,2"])   return 264;
    if ([platform isEqualToString:@"iPad3,3"])   return 264;
    
    //iPad 第四代
    if ([platform isEqualToString:@"iPad3,4"])   return 264;
    if ([platform isEqualToString:@"iPad3,5"])   return 264;
    if ([platform isEqualToString:@"iPad3,6"])   return 264;
    
    // iPad Air
    if ([platform isEqualToString:@"iPad4,1"])   return 264;
    if ([platform isEqualToString:@"iPad4,2"])   return 264;
    if ([platform isEqualToString:@"iPad4,3"])   return 264;
    
    // iPad mini 2
    if ([platform isEqualToString:@"iPad4,4"])   return 326;
    if ([platform isEqualToString:@"iPad4,5"])   return 326;
    if ([platform isEqualToString:@"iPad4,6"])   return 326;
    else return 264;
    
    //    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    //    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return 0.0;
}

@end
