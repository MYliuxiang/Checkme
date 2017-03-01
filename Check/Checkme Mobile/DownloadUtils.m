//
//  DownloadUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/13.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "DownloadUtils.h"
#import "FileUtils.h"
static DownloadUtils* theInstance = nil; //自定义一个static 静态的属性
@implementation DownloadUtils

//下载
+ (DownloadUtils *)sharedInstance
{
    if (!theInstance) {
        theInstance = [[DownloadUtils alloc] init];
    }
    return theInstance;
}

//下载指定url文件，并保存成指定文件名
-(void)downloadFile:(NSString *) urtStr FileName:(NSString*)fileName
{
    if (!urtStr || !fileName) {
        return;
    }
    //初始化下载文件
    _fileToDwon = [[FileToDwon alloc]initWithFileName:fileName];
    //开始下载
    NSURL* url = [NSURL URLWithString:urtStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    _connectionData = data;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}
//取消下载
- (void)cancelDownLoad
{
    if (self.connection) {
        [self.connection cancel];
    }
}

//下载错误处理函数
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    DLog(@"下载错误 %@", error);
    [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadError object:nil];
    [connection cancel];//下载错误后,取消下载操作
}

//下载中接收数据   不断执行  动态的
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_connectionData appendData:data];
    if (_fileToDwon && _fileToDwon.fileSize!= 0) {
        //计算并发送下载进度
        _fileToDwon.fileProgress = (_connectionData.length / (double)_fileToDwon.fileSize);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadPartFinished object:_fileToDwon];
    }
}

//下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    DLog(@"进入connectionDidFinishLoading方法!");
    if (_connectionData.length == _fileToDwon.fileSize) {
        DLog(@"下载成功");
        //保存文件
        if (_fileToDwon && _fileToDwon.fileName && _connectionData) {
#pragma mark - 当文件下载成功后 全部存储到本地
            //从本地拿到 每次连接的蓝牙设备名
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
//#warning 清除记录 hjz
//            //清除记录
//            [UserDefaults removeObjectForKey:lastCheckmeName];
//            [UserDefaults synchronize];
//            DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >4444444444");
            [FileUtils saveFile:_fileToDwon.fileName FileData:_connectionData withDirectoryName:lastCheckmeName];
            [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadSuccess object:_fileToDwon];//通知
        }else{
            //没有保存，下载失败
            [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadError object:nil];
        }
        [connection cancel];
    }
}

//连接完成
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [self.connectionData setLength:0];
    //获取文件大小
    _fileToDwon.fileSize = response.expectedContentLength; //响应  (预期内容的长度)
    DLog(@"要下载的文件%@大小%lld",_fileToDwon.fileName, _fileToDwon.fileSize);
}

@end


@implementation FileToDwon

-(instancetype)initWithFileName:(NSString *) fileName
{
    if (!fileName) {
        return nil;
    }
    self = [super init];
    if (self) {
        _fileName = fileName;
    }
    return self;
}



@end