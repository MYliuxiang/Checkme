//
//  DownloadUtils.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileToDwon;

@interface DownloadUtils : NSObject

@property(nonatomic,retain) NSMutableData *connectionData;
@property(nonatomic,retain) FileToDwon *fileToDwon;
@property(nonatomic,retain) NSURLConnection *connection;//下载连接操作
+ (DownloadUtils*)sharedInstance; //实例方法
- (void)downloadFile:(NSString*) urtStr FileName:(NSString*)fileName;  //类方法
- (void)cancelDownLoad;  //取消下载操作
@end


//下载文件类
@interface FileToDwon : NSObject

-(instancetype)initWithFileName:(NSString*) fileName;

@property(nonatomic,retain) NSString *fileName;
@property(nonatomic,assign) long long fileSize;
@property(nonatomic,assign) double fileProgress;

@end