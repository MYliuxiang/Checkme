//
//  BPCheckItem.h
//  BTHealth
//
//  Created by snake on 14-4-12.
//  Copyright (c) 2014年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesDef.h"

@interface BPCheckItem : NSObject
@property (nonatomic,assign) U8  userID;
@property (nonatomic,retain) NSDateComponents *dtcDate;

@property (nonatomic,assign) U16   BPIndex;
@property (nonatomic,assign) U8   rPresure;
@property (nonatomic,assign) U8   cPresure;

@end
