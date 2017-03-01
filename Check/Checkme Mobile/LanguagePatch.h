//
//  LanguagePatch.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning 语言包列表

@interface LanguagePatch : NSObject

@property(nonatomic,retain) NSString* region;
@property(nonatomic,retain) NSString* model;
@property(nonatomic,retain) NSString* hardware;
@property(nonatomic,assign) int version;
@property(nonatomic,retain) NSMutableString* languages;
@property(nonatomic,retain) NSString* address;

-(instancetype)initWithJSON:(NSDictionary*)jsonObject;
@end
