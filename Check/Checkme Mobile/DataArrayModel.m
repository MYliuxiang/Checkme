//
//  DataArrayModel.m
//  IOS_Minimotor
//
//  Created by Viatom on 15/10/20.
//  Copyright © 2015年 Viatom. All rights reserved.
//

#import "DataArrayModel.h"

@implementation DataArrayModel

+ (DataArrayModel *)sharedInstance
{
    static DataArrayModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
