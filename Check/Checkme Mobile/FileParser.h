//
//  FileParser.h
//  BTHealth
//
//  Created by demo on 13-11-4.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Xuser.h"

#import "SpotCheckItem.h"
#import "BPCheckItem.h"
#import "DailyCheckItem.h"
#import "ECGInfoItem.h"
#import "SPO2InfoItem.h"
#import "TempInfoItem.h"
#import "SLMItem.h"
#import "PedInfoItem.h"
#import "GlucoseInfoItem.h"
#import "RelaxMeItem.h"
#import "TypesDef.h"

@interface FileParser : NSObject

/**
 *  parse the home mode user list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'User'
 */
+(NSArray *)parseUserList_WithFileData:(NSData *)data;


/**
 *  parse the BPCheck list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'BPCheckItem'
 */
+(NSArray *)parseBPCheck_WithFileData:(NSData *)data;


/**
 *  parse the DailyCheck list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'DailyCheckItem'
 */
+(NSArray *)parseDlcList_WithFileData:(NSData *)data;


/**
 *  parse the ECG list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'ECGInfoItem'
 */
+(NSArray *)parseEcgList_WithFileData:(NSData *)data;


/**
 *  parse the instance of 'ECGInfoItem_InnerData' through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return the instance of 'ECGInfoItem_InnerData'
 */
+(ECGInfoItem_InnerData *)parseEcg_WithFileData:(NSData *)data;


/**
 *  parse the Spo2 list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'SPO2InfoItem'
 */
+(NSArray *)parseSPO2List_WithFileData:(NSData *)data;


/**
 *  parse the Temp list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'TempInfoItem'
 */
+(NSArray *)parseTempList_WithFileData:(NSData *)data;


/**
 *  parse the SLM list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'SLMItem'
 */
+(NSArray *)parseSLMList_WithFileData:(NSData *)data;


/**
 *  parse the instance of 'SLMItem_InnerData' through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return the instance of 'SLMItem_InnerData'
 */
+(SLMItem_InnerData *)parseSLMData_WithFileData:(NSData *)data;


/**
 *  parse the RelaxMe list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'RelaxMeItem'
 */
+(NSArray *)parseRelaxMeList_WithFileData:(NSData *)data;


/**
 *  parse the Ped list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'PedInfoItem'
 */
+(NSArray *)parsePedList_WithFileData:(NSData *)data;




/**
 *  parse the Hospital mode xUser list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'Xuser'
 */
+ (NSArray *) paserXusrList_WithFileData:(NSData *)data;


/**
 *  parse the SpotCheck list through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return array contains items which is subclass of 'SpotCheckItem'
 */
+(NSArray *)paserSpotCheckList_WithFileData:(NSData *)data;


/**
 *  parse the instance of 'spcInner_Data' through the data reading from blueTooth
 *
 *  @param data the data reading from blueTooth
 *
 *  @return return the instance of 'spcInner_Data'
 */
+ (spcInner_Data *)paserSpcInnerData_WithFileData:(NSData *)data;
@end
