//
//  PostUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "PostUtils.h"

static NSMutableData* postReceiveData;//设置一个静态的可变的数据类型

@implementation PostUtils

+ (void)doPost:(NSString*)urlStr DataStr:(NSString*) dataStr
{
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //第二步，创建请求
    /**
     NSURLRequestUseProtocolCachePolicy = 0,  (使用协议缓存政策)
     
     NSURLRequestReloadIgnoringLocalCacheData = 1,   忽略当地的缓存数据 从新加载
     NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4, // Unimplemented  忽略远程的缓存数据
     NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
     
     NSURLRequestReturnCacheDataElseLoad = 2,  返回其他的缓存数据   (负载)
     NSURLRequestReturnCacheDataDontLoad = 3,   返回其中的缓存数据
     
     NSURLRequestReloadRevalidatingCacheData = 5
     */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];//cachePolicy  缓存政策
    [request setHTTPMethod:@"POST"];//请求方式  post
    //第三步，添加参数
//    NSString *str = @"Region=CE&Model=6632&Hardware=A&Software=50000&Language=2";
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding]; //设置数据的编码格式
    [request setHTTPBody:data];
    
    //第四步，连接服务器
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    //超时自定义
//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer) userInfo:nil repeats:NO];
}

//超时处理  (这个方法是超时自定义的处理方法...暂时没有处理这个超时方法)
- (void)handleTimer
{
//    PostUtils connection:<#(NSURLConnection *)#> didFailWithError:<#(NSError *)#>
}

//接收到服务器回应的时候调用此方法
+ (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
//    DLog(@"%@",[res allHeaderFields]);
    postReceiveData = [NSMutableData data];
}
//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [postReceiveData appendData:data];
}
//数据传完之后调用此方法
//数据传输完毕调用此方法
+ (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Post接收完毕");
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_PostSuccess object:postReceiveData];
    [connection cancel];
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
+ (void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    DLog(@"Post接收错误");
    DLog(@"*%@",[error localizedDescription]);
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_PostError object:nil];//使用通知处理网络请求错误的方法
}
@end
