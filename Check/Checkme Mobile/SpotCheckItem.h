//
//  SpotCheckItem.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/25.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicUtils.h"
#import "BTCommunication.h"

@protocol spotCheckItemDelegate <NSObject>

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

@interface spcInner_Data : NSObject <NSCoding>
@property (nonatomic,retain) NSMutableArray *arrEcgContent;
@property (nonatomic,retain) NSMutableArray *arrEcgHeartRate;

///  the seconds of the measurement
@property (nonatomic,assign) U32 timeLength;
@end

@interface SpotCheckItem : NSObject <NSCoding, BTCommunicationDelegate>
@property (nonatomic, assign) id<spotCheckItemDelegate> spcDelegate;

@property (nonatomic,retain) NSDateComponents *dtcDate;
@property (nonatomic, strong) NSString *dateStr;

///  To distinguish between different measurement
@property (nonatomic, assign) U16 func;

@property (nonatomic, assign) U16 HR;
@property (nonatomic, assign) U16 QRS;
@property (nonatomic, assign) short ST;
@property (nonatomic, strong) NSString *ecgResult;
@property (nonatomic, assign) PassKind_t enECG_PassKind;
@property (nonatomic, assign) PassKind_t enOxi_PassKind;
@property (nonatomic, assign) PassKind_t enTemp_PassKind;
@property (nonatomic, assign) PassKind_t oxi_R;
@property (nonatomic, assign) U8 oxi;
@property (nonatomic, assign) double PI;
@property (nonatomic, assign) U16 temp;

@property (nonatomic,assign) BOOL bDownloadIng;
@property (nonatomic,assign) double downloadProgress;

@property (nonatomic,assign) BOOL bHaveVoiceMemo;
@property (nonatomic,retain) NSMutableData *dataVoice;

@property (nonatomic, assign) BOOL isNoHR;
@property (nonatomic, assign) BOOL isNoOxi;
@property (nonatomic, assign) BOOL isNoTemp;

@property (nonatomic,retain) spcInner_Data *innerData;

/**
 *  download SpotCheck inner data
 */
- (void) beginDownloadDetail;  //细节
/**
 *  download SpotCheck voice
 */
-(void)beginDownloadVoice;  //声音
@end
