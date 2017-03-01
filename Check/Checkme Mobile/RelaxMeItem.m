//
//  RelaxMeItem.m
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "RelaxMeItem.h"

@implementation RelaxMeItem

@synthesize dtcDate = _dtcDate;
@synthesize enLeadKind = _enLeadKind;
@synthesize Relaxation = _Relaxation;
@synthesize timemiao = _timemiao;
@synthesize enPassKind = _enPassKind;

-(id)init
{
    self  = [super init];
    if(self)
    {
      
    }
    
    return self;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   
    [aCoder encodeObject:self.dtcDate forKey:@"dtcDate"];
    [aCoder encodeInt:self.Relaxation forKey:@"Relaxation"];
    [aCoder encodeInt:self.timemiao forKey:@"timemiao"];
    [aCoder encodeInt:self.enLeadKind forKey:@"enLead"];
    [aCoder encodeInt:self.enLeadKind forKey:@"enLeadKind"];
    [aCoder encodeInt:self.hrv forKey:@"hrv"];

}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
       
        self.dtcDate = [aDecoder decodeObjectForKey:@"dtcDate"];
        self.timemiao = [aDecoder decodeIntForKey:@"timemiao"];
        self.Relaxation = [aDecoder decodeIntForKey:@"Relaxation"];
        self.enLeadKind = [aDecoder decodeIntForKey:@"enLead"];
        self.enLeadKind = [aDecoder decodeIntForKey:@"enLeadKind"];
        self.hrv = [aDecoder decodeIntForKey:@"hrv"];

    }
    return self;
}

-(BOOL)bMatchWithCondition_TypeKind:(TypeForFilter_t)typeKind leadKind:(LeadKind_t)leadKind
{
    BOOL bMatch = NO;
    if((leadKind & _enLeadKind) != 0){
        
        if((typeKind & kTypeForFilter_Pass) != 0)
        {
            if(_enPassKind == kPassKind_Pass)
                bMatch = YES;
        }
        if((typeKind & kTypeForFilter_Fail) != 0)
        {
            if(_enPassKind == kPassKind_Fail)
                bMatch = YES;
        }
        //不能分析的暂时不筛选掉
        if (_enPassKind == kPassKind_Others) {
            bMatch = YES;
        }
        
    }
    return bMatch;
}

@end
