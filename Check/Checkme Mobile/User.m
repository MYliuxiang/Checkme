//
//  User.m
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "User.h"

@interface User ()

@end

@implementation User

@synthesize name = _name;
@synthesize age = _age;
@synthesize gender = _gender;
@synthesize arrECG = _arrECG;
@synthesize arrDlc = _arrDlc;
@synthesize arrSLM = _arrSLM;
@synthesize arrRelaxMe = _arrRelaxMe;
@synthesize BPIndex = _BPIndex;
@synthesize detailSPO2Array = _detailSPO2Array;
@synthesize ID = _ID;
@synthesize ICO_ID = _ICO_ID;
@synthesize dtcBirthday = _dtcBirthday;
@synthesize weight = _weight;
@synthesize height = _height;
@synthesize arrBPI = _arrBPI;
@synthesize arrBPCheck = _arrBPCheck;
@synthesize arrSPO2 = _arrSPO2;
@synthesize arrTemp = _arrTemp;
@synthesize arrGlucose = _arrGlucose;
@synthesize medical_id = _medical_id;


-(id)init
{
    self = [super init];
    if(self){
        self.arrECG = [NSMutableArray array];
        self.arrDlc = [NSMutableArray arrayWithCapacity:10];
        self.arrSLM = [NSMutableArray arrayWithCapacity:10];
        self.arrBPI = [NSMutableArray arrayWithCapacity:10];
        self.arrBPCheck = [NSMutableArray arrayWithCapacity:10];
        self.arrSPO2 = [NSMutableArray arrayWithCapacity:10];
        self.arrTemp = [NSMutableArray arrayWithCapacity:10];
        self.arrPed = [NSMutableArray arrayWithCapacity:10];
        self.arrGlucose = [NSMutableArray arrayWithCapacity:10];
        self.arrRelaxMe = [NSMutableArray arrayWithCapacity:10];
        _dtcBirthday = [[NSDateComponents alloc] init];
        self.detailSPO2Array = [NSMutableArray arrayWithCapacity:10];
        
#if __TEST_MODE__
        [self generateForTest];
#endif

    }
    return self;
}


-(UIImage *)headIcon
{
    return  [self loadHeadImage];
}

-(UIImage *)loadHeadImage
{
    UIImage *ret = nil;
    ret = [UIImage imageNamed:[NSString stringWithFormat:@"ico%d", _ICO_ID]];
    return ret;
}

@end
