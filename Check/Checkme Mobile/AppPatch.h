//
//  AppPatch.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  the app patch to write
 */
@interface AppPatch : NSObject

@property(nonatomic,retain) NSString* region;
@property(nonatomic,retain) NSString* model;
@property(nonatomic,retain) NSString* hardware;
@property(nonatomic,assign) int version; //版本号
@property(nonatomic,retain) NSString* address;

-(instancetype)initWithJSON:(NSDictionary*)jsonObject;//json 数据类型解析

@end
