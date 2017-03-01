//
//  FirstDownManger.m
//  Checkme Mobile
//
//  Created by Viatom on 16/7/28.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "FirstDownManger.h"

@implementation FirstDownManger

+ (FirstDownManger *)sharedManager
{
    static FirstDownManger *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        sharedAccountManagerInstance = [[self alloc] init];
        
    });
    
    return sharedAccountManagerInstance;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.downedArray = [NSMutableArray array];
    }
    return self;
}

@end




