//
//  FileUtils.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

/** 从沙箱的document文件夹中删除所有的文件*/
+(void) deleteAllFileInDocuments;  //从沙箱的document文件夹中删除所有的文件
/** 删除文件*/
+(void)deleteFile:(NSString *) fileName inDirectory:(NSString *)dirName;  //删除文件
/** 保存文件*/
+(void)saveFile:(NSString *)fileName FileData:(NSData *)data withDirectoryName:(NSString *)dirName;
+(BOOL) isDirectoryExistInDocumentsWithName:(NSString *)dirName;
+(BOOL)isFileExist:(NSString *)fileName inDirectory:(NSString *)dirName;
/** 读文件*/
+(NSMutableData*)readFile:(NSString *)fileName inDirectory:(NSString *)dirName;
// 通过前缀名读取文件夹下的文件
+(NSArray *) readAllFileNamesInDocumentsWithPrefix:(NSString *)prefixName inDirectory:(NSString *)dirName;
// 在documents文件夹内创建一个文件夹
+(void) createDirectoryInDocumentsWithName:(NSString *)name;
@end
