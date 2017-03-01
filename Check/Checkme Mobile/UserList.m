//
//  UserList.m
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "UserList.h"

@implementation UserList
@synthesize arrUserList = _arrUserList;

-(id)init
{
    self = [super init];
    if(self){
        self.arrUserList = [NSMutableArray arrayWithCapacity:10];
        self.arrXuserList = [NSMutableArray array];
#if __TEST_MODE__
        [self generateTestUser];
#endif
    }
    return self;
}

-(void) generateTestUser
{
    //srand(time(0));
#define NUM_GENERATE_FOR_TEST 5
    for(int i = 0 ; i < NUM_GENERATE_FOR_TEST; ++i){
        User *user = [[User alloc] init];
        [_arrUserList addObject:user];
        
        Xuser *xuser = [[Xuser alloc] init];
        [_arrXuserList addObject:xuser];
    }
}

+(UserList *)instance
{
    static UserList *list = nil;
    if(!list){
        list = [[UserList alloc] init];
    }
    return list;
}

@end
