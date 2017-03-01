//
//  CheckmeInfo.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckmeInfo : NSObject

@property(nonatomic,retain) NSString* region;
@property(nonatomic,retain) NSString* model;
@property(nonatomic,retain) NSString* hardware;
@property(nonatomic,retain) NSString* software;  //软件版本
@property(nonatomic,retain) NSString* language;  //语言
@property(nonatomic,retain) NSString* theCurLanguage;
@property(nonatomic,retain) NSString* sn;   //设备的序列号
@property (nonatomic, copy) NSString *Application;

@property (nonatomic, retain) NSString *SPCPVer;
@property (nonatomic, retain) NSString *FileVer;

-(instancetype)initWithJSONStr:(NSData*) data;
@end
