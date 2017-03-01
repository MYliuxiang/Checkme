//
//  DailyCheckItem.h
//  BTHealth
//
//  Created by snake on 14-4-7.
//  Copyright (c) 2014年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasureInfoBase.h"
#import "BTCommunication.h"

@class DailyCheckItem;
@protocol DailyCheckItemDelegate <NSObject>

/**
 *  the callback method when the detail data requested successfully
 *
 *  @param fileData the data been requested successfully
 */
- (void) onDlcDetailDataDownloadSuccess:(FileToRead *)fileData;

/**
 *  the callback method when the detail data requested failed
 */
- (void) onDlcDetailDataDownloadTimeout;

/**
 *  the callback method when the detail data is being requested
 *
 *  @param progress the progress of the current being requested data
 */
- (void) onDlcDetailDataDownloadProgress:(double )progress;

@end


@interface ECGInfoItem_InnerData : MeasureInfoBase<NSCoding>
@property (nonatomic,retain) NSMutableArray *arrEcgContent;
@property (nonatomic,retain) NSMutableArray *arrEcgHeartRate;
@property (nonatomic,copy) NSString *dataStr;

//unsigned short int
@property (nonatomic,assign) U16  HR;
@property (nonatomic,assign) short  ST;
@property (nonatomic,assign) U16  QRS;
@property (nonatomic,assign) U16  PVCs;
@property (nonatomic,assign) U16  QTc;
@property (nonatomic,assign) U8 ECG_Type;
@property (nonatomic,copy) NSString *ecgResultDescrib;
@property (nonatomic,assign) U32 timeLength;//数据秒数
@property (nonatomic,assign) FilterKind_t enFilterKind;
@property (nonatomic,assign) LeadKind_t enLeadKind;

@end

@interface DailyCheckItem : NSObject <NSCoding, BTCommunicationDelegate>
@property (nonatomic, assign) id<DailyCheckItemDelegate> dlcDelegate;

@property (nonatomic,retain) NSDateComponents *dtcDate;
@property (nonatomic,assign) PassKind_t enPassKind;
@property (nonatomic,assign) unsigned char userID;
@property (nonatomic,retain) ECGInfoItem_InnerData *innerData;

@property (nonatomic,assign) BOOL bDownloadIng;
@property (nonatomic,assign) double downloadProgress;

@property (nonatomic,retain) NSMutableData *dataVoice;

@property (nonatomic,assign) U16  HR;
@property (nonatomic,assign) PassKind_t   ECG_R;
@property (nonatomic,assign) U8   SPO2;
@property (nonatomic,assign) double   PI;
@property (nonatomic,assign) PassKind_t   SPO2_R;
@property (nonatomic,assign) int BP_Flag;
@property (nonatomic,assign) short   BP;
@property (nonatomic,assign) PassKind_t   BPI_R;
@property (nonatomic,assign) BOOL bHaveVoiceMemo;
@property (nonatomic,assign) U16  RPP;
@property (nonatomic,assign) U8  RR;

/**
 *  download DailyCheck innerData
 */
-(void)beginDownloadDetail;
/**
 *  download DailyCheck voice
 */
-(void)beginDownloadVoice;


-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind;

@end

@interface OldDailyCheckItem : NSObject <NSCoding, BTCommunicationDelegate>
@property (nonatomic, assign) id<DailyCheckItemDelegate> dlcDelegate;

@property (nonatomic,retain) NSDateComponents *dtcDate;
@property (nonatomic,assign) PassKind_t enPassKind;
@property (nonatomic,assign) unsigned char userID;
@property (nonatomic,retain) ECGInfoItem_InnerData *innerData;

@property (nonatomic,assign) BOOL bDownloadIng;
@property (nonatomic,assign) double downloadProgress;

@property (nonatomic,retain) NSMutableData *dataVoice;

@property (nonatomic,assign) U16  HR;
@property (nonatomic,assign) PassKind_t   ECG_R;
@property (nonatomic,assign) U8   SPO2;
@property (nonatomic,assign) double   PI;
@property (nonatomic,assign) PassKind_t   SPO2_R;
@property (nonatomic,assign) int BP_Flag;
@property (nonatomic,assign) short   BP;
@property (nonatomic,assign) PassKind_t   BPI_R;
@property (nonatomic,assign) BOOL bHaveVoiceMemo;
@property (nonatomic,assign) U16  RPP;
@property (nonatomic,assign) U8  RR;

/**
 *  download DailyCheck innerData
 */
-(void)beginDownloadDetail;
/**
 *  download DailyCheck voice
 */
-(void)beginDownloadVoice;


-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind;

@end




