//
//  PublicUtils.h
//  libCheckme
//
//  Created by 李乾 on 15/4/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesDef.h"
#import <sys/sysctl.h>



#define ECG_RESULT_ARRAYS ([NSArray arrayWithObjects:NSLocalizedString(@"Regular ECG Rhythm", nil), NSLocalizedString(@"High Heart Rate", nil), NSLocalizedString(@"Low Heart Rate", nil), NSLocalizedString(@"High QRS Value", nil), NSLocalizedString(@"High ST Value", nil), NSLocalizedString(@"Low ST Value", nil), NSLocalizedString(@"Irregular ECG Rhythm", nil), NSLocalizedString(@"Suspected Premature Beat", nil), NSLocalizedString(@"Unable to Analyze", nil),nil])

@interface PublicUtils : NSObject

+(NSString*)MakeDateFileName:(NSDateComponents*)date fileType:(U8)type;
+(uint8_t)CalCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int) Buffer_Size;


/**
 *  parse the ecgResult strings with 'ecgResultDescrib'
 *
 *  @param ecgResultDescrib   the property of  'DailyCheckItem' or 'ECGInfoItem'
 *
 *  @return ecgResult strings
 */
+ (NSString *) parseECG_innerData_ecgResultDescribWith:(NSString *)ecgResultDescrib;

+(float)get_PPI_ofCurDevice;

@end
