//
//  SLMItem.h
//  BTHealth
//
//  Created by snake on 14-4-7.
//  Copyright (c) 2014年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"
#import "BTCommunication.h"

#define MAX_Resonable_SPO2_Value 254
#define MIN_Resonable_SPO2_Value 0

@protocol SLMItemDelegate <NSObject>

/**
 *  the callback method when the detail data requested successfully
 *
 *  @param fileData the data been requested successfully
 */
- (void) onSLMDetailDataDownloadSuccess:(FileToRead *)fileData;

/**
 *  the callback method when the detail data requested failed
 */
- (void) onSLMDetailDataDownloadTimeout;

/**
 *  the callback method when the detail data is being requested
 *
 *  @param progress the progress of the current being requested data
 */
- (void) onSLMDetailDataDownloadProgress:(double) progress;

@end

@interface SLMItem_InnerData : MeasureInfoBase <NSCoding>
///  array contains spo2 values
@property (nonatomic,retain) NSMutableArray *arrOXValue;
///  array contains PluseValues
@property (nonatomic,retain) NSMutableArray *arrPluseValue;
@end

@interface SLMItem : NSObject <NSCoding, BTCommunicationDelegate>
@property (nonatomic, assign) id<SLMItemDelegate> slmDelegate;

@property (nonatomic,retain) NSDateComponents *dtcStartDate;
@property (nonatomic,assign) U32 totalTime;
@property (nonatomic,assign) PassKind_t enPassKind;
@property (nonatomic,assign) unsigned char userID;
@property (nonatomic,assign) BOOL bDownloadIng;
@property (nonatomic,assign) double downloadProgress;
@property (nonatomic,assign) U16  LO2Time;
@property (nonatomic,assign) U16   LO2Count;
@property (nonatomic,assign) U8   LO2Value;
@property (nonatomic,assign) U8 AverageSpo2;
@property (nonatomic,retain) SLMItem_InnerData *innerData;


/**
 *  download SLM inner data
 */
-(void)beginDownloadDetail;

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind;

@end
