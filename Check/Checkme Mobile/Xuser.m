//
//  Xuser.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/25.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "Xuser.h"

@interface Xuser ()

@end

@implementation Xuser
{
    int curXuserIndex;
    NSString *curDirName;
    NSString *periphralName;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.arrSpotCheck = [NSMutableArray array];
        
    }
    return self;
}

- (void)postCurrentReadProgress:(double)progress
{
    return;
}

@end
