//
//  User.h
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ECGInfoItem.h"
#import "DailyCheckItem.h"
#import "SPO2InfoItem.h"
#import "TempInfoItem.h"
#import "SLMItem.h"
#import "PedInfoItem.h"
#import "RelaxMeItem.h"
#import "TypesDef.h"


typedef enum
{
    kGender_FeMale,
    kGender_Male
}Gender_t;

typedef enum
{
    kAgeType_Children,
    kAgeType_Adult
}AgeType_t;


@interface User : NSObject
///  user ID
@property (nonatomic,assign) unsigned char ID;
///  ID for icon
@property (nonatomic,assign) unsigned char ICO_ID;
@property (nonatomic,retain) NSDateComponents *dtcBirthday;
@property (nonatomic,retain) UIImage *headIcon;
@property (nonatomic,assign) double weight;
@property (nonatomic,assign) double height;
@property (nonatomic,copy)   NSString *name;
@property (nonatomic,assign) NSInteger age;
@property (nonatomic,assign) Gender_t gender;
@property (nonatomic,copy) NSString *medical_id;


///  array contains the items which is the subclass of 'DailyCheckItem'
@property (nonatomic,retain) NSMutableArray *arrDlc;

///  array contains the items which is the subclass of 'ECGInfoItem'
@property (nonatomic,retain) NSMutableArray *arrECG;

///  array contains the items which is the subclass of 'SLMItem'
@property (nonatomic,retain) NSMutableArray *arrSLM;

///  array contains the items which is the subclass of 'SPO2InfoItem'
@property (nonatomic,retain) NSMutableArray *arrSPO2;

///  array contains the items which is the subclass of 'TempInfoItem'
@property (nonatomic,retain) NSMutableArray *arrTemp;

///  array contains the items which is the subclass of 'GlucoseInfoItem'
@property (nonatomic,retain) NSMutableArray *arrGlucose;

///  array contains the items which is the subclass of 'BPI'
@property (nonatomic,retain) NSMutableArray *arrBPI;

///  array contains the items which is the subclass of 'BPCheckItem'
@property (nonatomic,retain) NSMutableArray *arrBPCheck;

/// array contains the items which is the subclass of 'PedInfoItem'
@property (nonatomic,retain) NSMutableArray *arrPed;

@property (nonatomic,retain) NSMutableArray *arrRelaxMe;

///  Unknown
@property (nonatomic,retain) NSMutableArray *detailSPO2Array;
@property (nonatomic,assign) U16 BPIndex;

@end
