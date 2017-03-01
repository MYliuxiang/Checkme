//
//  RelaxMeItem.h
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "MeasureInfoBase.h"

@interface RelaxMeItem : MeasureInfoBase

@property (nonatomic,retain) NSDateComponents *dtcDate;
@property (nonatomic,assign) LeadKind_t enLeadKind;
@property (nonatomic,assign) U16  Relaxation;
@property (nonatomic,assign) U16  timemiao;
@property (nonatomic,assign) PassKind_t enPassKind;
@property (nonatomic,assign) U8  hrv;

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind leadKind:(LeadKind_t)leadKind;
@end
