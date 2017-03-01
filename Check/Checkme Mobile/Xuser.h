//
//  Xuser.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/25.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotCheckItem.h"
#import "TypesDef.h"


@interface Xuser : NSObject

@property (nonatomic, assign) U8 userID;
@property (nonatomic, strong) NSString *patient_ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) U8 sex;

@property (nonatomic, assign) U8 unit;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
@property (nonatomic, assign) int age;


///  array contains the items which is the subclass of 'SpotCheckItem'
@property (nonatomic,retain) NSMutableArray *arrSpotCheck;


@end
