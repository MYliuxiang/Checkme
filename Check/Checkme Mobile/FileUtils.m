//
//  FileUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

+ (void) deleteAllFileInDocuments
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *dirNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    for (NSString *dirName in dirNames) {
        NSURL *dirURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        [fileManager removeItemAtPath:dirURL.path error:nil];
    }
    
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    [fileManager removeItemAtPath:cachesDir error:nil];
}
//删除指定文件
+(void)deleteFile:(NSString *) fileName inDirectory:(NSString *)dirName
{
    if (!fileName || !dirName) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];//创建documentsUrl路径(沙箱路径...)
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:directoryURL.path]) {
         NSError *err;
        [fileManager removeItemAtPath:fileURL.path error:&err];//删除指定的文件
    }
}

//保存文件     //把获取到的数据文件保存到沙盒中
+(void)saveFile:(NSString *)fileName FileData:(NSData *)data withDirectoryName:(NSString *)dirName
{
    if (!fileName || !data) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];//保存在 document 路径中
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];

    [fileManager createFileAtPath:fileURL.path contents:data attributes:nil];//创建文件路径地址(path路径)
}

//读文件
+(NSData *)readFile:(NSString *)fileName inDirectory:(NSString *)dirName     //获取document下的NSData类型的数据
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:fileURL.path isDirectory:NO]) { //如果文件存在
        NSData *data = [[NSData alloc] initWithContentsOfFile:fileURL.path];
        return data; //如果存在就返回数据
    }else{
        return nil;
    }
}

//判断文件是否存在
+(BOOL)isFileExist:(NSString*)fileName inDirectory:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];//使用沙箱路径存储
    NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:fileURL.path]) {
        return YES;
    }
    return  NO;
}


//判断沙箱路径下的url地址路径 hjz
+ (BOOL) isDirectoryExistInDocumentsWithName:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *dirURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
    BOOL isDir = YES;
    if ([fileManager fileExistsAtPath:dirURL.path isDirectory:&isDir]) {
        return YES;
    }
    return NO;
}


#warning 指定名字开头的文件名称
//获取指定name开头的文件名称
+ (NSArray *)readAllFileNamesInDocumentsWithPrefix:(NSString *)prefixName inDirectory:(NSString *)dirName
{
    NSMutableArray *NameArr = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSArray *allFileNames = [NSArray array];
    if (dirName) {
        NSURL *directoryURL = [documentsURL URLByAppendingPathComponent:dirName isDirectory:YES];
        //获取文件夹下的所有文件的名字
        allFileNames = [fileManager contentsOfDirectoryAtPath:directoryURL.path error:nil];
    }else {
        allFileNames = [fileManager contentsOfDirectoryAtPath:documentsURL.path error:nil];
    }
    for (NSString *fileName in allFileNames) {
        if ([fileName hasPrefix:prefixName]) {
            [NameArr addObject:fileName];
        }
    }
    return NameArr;
}

// 在documents文件夹内创建一个文件夹
+ (void) createDirectoryInDocumentsWithName:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取应用的Document文件夹路径的URL     .path 可获取路径
    NSURL *fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *dirPath = [fileURL.path stringByAppendingPathComponent:name];
    BOOL isDIR = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDIR];//是否存在文件夹
    if (!(isDIR == YES && existed == YES)) {
        //创建文件夹的路径
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
