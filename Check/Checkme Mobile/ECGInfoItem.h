//
//  ECGInfoItem.h
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DailyCheckItem.h"
#import "BTCommunication.h"

#define ECG_DATA_TOTAL_NUM 10000
#define ECG_DATA_COLLECT_HZ ((double)ECG_DATA_TOTAL_NUM/20.0)
#define ECG_DATA_TOTAL_SECOND 20


#define __ECG_DATA_TEST__ __ALL_DATA_TEST_MODE__

#define __ECG_DATA_FOR_DEMO__ 0

@protocol ECGInfoItemDelegate <NSObject>

/**
 *  the callback method when the detail data requested successfully
 *
 *  @param fileData the data been requested successfully
 */
- (void) onECGDetailDataDownloadSuccess:(FileToRead *)fileData;

/**
 *  the callback method when the detail data requested failed
 */
- (void) onECGDetailDataDownloadTimeout;

/**
 *  the callback method when the detail data is being requested
 *
 *  @param progress the progress of the current being requested data
 */
- (void) onECGDetailDataDownloadProgress:(double) progress;

@end


@interface ECGInfoItem : NSObject<NSCoding, BTCommunicationDelegate>
-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind leadKind:(LeadKind_t)leadKind;

@property (nonatomic, assign) id<ECGInfoItemDelegate> ecgDelegate;

@property (nonatomic,retain) NSDateComponents *dtcDate;
@property (nonatomic,assign) LeadKind_t enLeadKind;
@property (nonatomic,assign) BOOL bHaveVoiceMemo;
@property (nonatomic,assign) PassKind_t enPassKind;
@property (nonatomic,assign) unsigned char userID;
@property (nonatomic,retain) ECGInfoItem_InnerData *innerData;
@property (nonatomic,assign) BOOL bDownloadIng;
@property (nonatomic,assign) double downloadProgress;
@property (nonatomic,retain) NSMutableData *dataVoice;
@property (nonatomic,assign) U16  HR;

/**
 *  download ECG innerData
 */
-(void)beginDownloadDetail;

/**
 *  download ECG voice
 */
-(void)beginDownloadVoice;

/**
 *  others
 */
+(NSString *)ecgTypeDescrib:(U8)diagnose;
+(NSString *)pvcsDescrib:(U16)pvcs;

@end
