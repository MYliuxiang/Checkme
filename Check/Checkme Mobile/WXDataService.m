//
//  WXDataService.m
//  MyWeibo
//
//  Created by zsm on 14-3-5.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import "WXDataService.h"
#import "YYCache.h"
#import "MBProgressHUD.h"
#define  LXCACHE @"lxcache"


@implementation WXDataService

- (BOOL)isConnected {
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

//-(void)Reachability {
//    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        NSLog(@"%@",[NSThread currentThread]);
//        switch (status) {
//            case AFNetworkReachabilityStatusNotReachable:
//            {
//                NSLog(@"无网络");
//                self.isNotReachable = NO;
//            }
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            {
//                NSLog(@"有网络");
//                //isuse = @"有网络";
//                 self.isNotReachable = YES;
//            }
//                break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//            {
//                NSLog(@"有网络wifi");
//                 self.isNotReachable = YES;
//            }
//                break;
//            default:
//                break;
//        }
//    }];
//}

+ (AFHTTPSessionManager *)requestAFWithURL:(NSString *)url
                                    params:(NSDictionary *)params
                                httpMethod:(NSString *)httpMethod
                                     isHUD:(BOOL)ishud
                               finishBlock:(FinishBlock)finishBlock
                                errorBlock:(ErrorBlock)errorBlock
{
    
    if (ishud) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    RequestType1 type;
    if ([httpMethod isEqualToString:@"GET"])
    {
        type = RequestGetType1;
    }else{
        type = RequestPostType1;
        
        
    }
    switch (type) {
        case RequestGetType1:
        {
            
            [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                
                if (ishud) {
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                }
                
                if (finishBlock != nil) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    finishBlock(result);
                }
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                
                if (ishud) {
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                }
                if (errorBlock != nil) {
                    errorBlock(error);
                }
                
            }];
            
            
        }
            break;
        case RequestPostType1:
        {
            
            
            [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (ishud) {
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                }
                if (finishBlock != nil) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    finishBlock(result);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (ishud) {
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                }
                if (errorBlock != nil) {
                    
                    errorBlock(error);
                }
            }];
            
        }
            break;
        default:
            break;
    }
    
    return manager;
    
    
}



+ (AFHTTPSessionManager *)postUrl:(NSString *)url
                            params:(NSDictionary *)params
                       finishBlock:(FinishBlock)finishBlock
                        errorBlock:(ErrorBlock)errorBlock
{
    
   
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer= [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval =  30;
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"text/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    manager.requestSerializer setValue:<#(NSString *)#> forHTTPHeaderField:<#(NSString *)#>
    NSString *authstr = [[NSString stringWithFormat:@"%@:%@",[UserDefault objectForKey:EMAIL],[UserDefault objectForKey:Password]] encodeWithBase64];
    NSString *str = [NSString stringWithFormat:@"Basic %@",authstr];
//        [session.requestSerializer setValue:[authstr encodeWithBase64] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:str forHTTPHeaderField:@"Authorization"];
    [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (finishBlock != nil) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    finishBlock(result);
                    
                    
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (errorBlock != nil) {
                    
                    errorBlock(error);
                }
            }];
            
         return manager;

}

+ (AFHTTPSessionManager *)postLoginParams:(NSDictionary *)params
                              finishBlock:(FinishBlock)finishBlock
                               errorBlock:(ErrorBlock)errorBlock
{
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
//    manager.requestSerializer= [AFJSONRequestSerializer serializer];
//    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"text/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];  // 此处设置content-Type生效了，然后就是参数要求是json，怎么设。。
    //@"list":@[@{@"id":@"1"},@{@"id":@"2"}],

    [manager POST:Url_login parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (finishBlock != nil) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            finishBlock(result);
            
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorBlock != nil) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            errorBlock(error);

        }
    }];
    
    return manager;
    
}



//+ (AFHTTPSessionManager *)postMP3:(NSString *)url
//                           params:(NSDictionary *)params
//                         fileData:(NSData *)fileData
//                      finishBlock:(FinishBlock)finishBlock
//                       errorBlock:(ErrorBlock)errorBlock
//{
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
////        [formData appendPartWithFileData:fileData name: fileName:[NSString stringWithFormat:@"uploadfile%d",i] mimeType:@"image/jpeg"];
//        [formData appendPartWithFileData:fileData name:@"recoder" fileName:@"recoder.mp3" mimeType:@"mp3"];
//        
//    } success:^(NSURLSessionDataTask *task, id responseObject) {
//        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        if (finishBlock != nil) {
//            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//            finishBlock(result);
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        if (errorBlock != nil) {
//            
//            errorBlock(error);
//        }
//
//    }];
//    
//    return manager;
//
//    
//    
//}

//+ (AFHTTPSessionManager *)postImage:(NSString *)url
//                             params:(NSDictionary *)params
//                           fileData:(NSData *)fileData
//                        finishBlock:(FinishBlock)finishBlock
//                         errorBlock:(ErrorBlock)errorBlock
//{
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//    [formData appendPartWithFileData:fileData name:@"filename" fileName:@"my.png" mimeType:@"image/jpeg"];
////        [formData appendPartWithFileData:fileData name:@"recoder" fileName:@"recoder.mp3" mimeType:@"mp3"];
//        
//    } success:^(NSURLSessionDataTask *task, id responseObject) {
//        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        if (finishBlock != nil) {
//            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//            finishBlock(result);
//        }
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        if (errorBlock != nil) {
//            
//            errorBlock(error);
//        }
//        
//    }];
//    
//    return manager;
//    
//
//
//
//}
//


//+ (AFHTTPSessionManager *)syncrequestAFWithURL:(NSString *)url
//                                    params:(NSDictionary *)params
//                                httpMethod:(NSString *)httpMethod
//                               finishBlock:(FinishBlock)finishBlock
//                                errorBlock:(ErrorBlock)errorBlock
//{
//    
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    RequestType1 type;
//    if ([httpMethod isEqualToString:@"GET"])
//    {
//        type = RequestGetType1;
//    }else{
//        type = RequestPostType1;
//        
//    }
//    switch (type) {
//        case RequestGetType1:
//        {
//            
//            [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//                
//                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//                if (finishBlock != nil) {
//                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//                    finishBlock(result);
//                }
//                
//                
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                NSLog(@"Error: %@", [error localizedDescription]);
//                
//                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//                if (errorBlock != nil) {
//                    
//                    errorBlock(error);
//                }
//                
//            }];
//            
//            
//        }
//            break;
//        case RequestPostType1:
//        {
//            
//            [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//                if (finishBlock != nil) {
//                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//                    finishBlock(result);
//                }
//                
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//                if (errorBlock != nil) {
//                    
//                    errorBlock(error);
//                }
//            }];
//            
//        }
//            break;
//        default:
//            break;
//    }
//    
//
//    return manager;
//    
//    
//}

+ (AFHTTPSessionManager *)postPatianIDUrl:(NSString *)url
                                   params:(NSDictionary *)params
                                 cacheKey:(NSString *)key
                              finishBlock:(FinishBlock)finishBlock
                               errorBlock:(ErrorBlock)errorBlock
{
    
    //处理中文和空格问题
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //拼接
//    NSString *cacheUrl = [self urlDictToStringWithUrlStr:url WithDict:parameters];
    
    //设置YYCache属性
    YYCache *cache = [[YYCache alloc] initWithName:LXCACHE];
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    id cacheData;
    
        //根据网址从Cache中取数据
    cacheData = [cache objectForKey:key];
//    if (cacheData != 0){
//            
//            //将数据统一处理
//        [[self alloc] returnDataWithRequestData:cacheData Success:^(id requestDic) {
//            
//            finishBlock(requestDic);
//            
//        } failure:^(NSError *error) {
//            
//        }];
//        return nil;
//        
//        }
    
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    session.requestSerializer= [AFJSONRequestSerializer serializer];
    session.requestSerializer.timeoutInterval =  30;
    //    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];

//        session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [session.requestSerializer setValue:@"text/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *authstr = [[NSString stringWithFormat:@"%@:%@",[UserDefault objectForKey:EMAIL],[UserDefault objectForKey:Password]] encodeWithBase64];
    NSString *str = [NSString stringWithFormat:@"Basic %@",authstr];
//    [session.requestSerializer setValue:[authstr encodeWithBase64] forHTTPHeaderField:@"Authorization"];
    [session.requestSerializer setValue:str forHTTPHeaderField:@"Authorization"];

    
    //post请求
    [session POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
       
        
        [[self alloc] dealWithResponseObject:responseObject
                               cache:cache
                            cacheKey:key
                             success:^(id responseObject) {
            
            finishBlock(responseObject);
                                 
        } failure:^(NSError *error) {
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        errorBlock(error);
        
    }];
    
    return session;

}

#pragma mark  统一处理请求到的数据
- (void)dealWithResponseObject:(NSData *)responseData
                        cache:(YYCache*)cache
                     cacheKey:(NSString *)cacheKey
                      success:(FinishBlock)success
                     failure :(ErrorBlock)failure
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dataString = [self deleteSpecialCodeWithStr:dataString];
    NSData *requestData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
//    [cache setObject:requestData forKey:cacheKey];
    
    [self returnDataWithRequestData:requestData Success:^(id requestDic) {
            
            success(requestDic);
            
        } failure:^(NSError *error) {
            
        }];
    
}


#pragma mark --根据返回的数据进行统一的格式处理  ----requestData 网络或者是缓存的数据----
- (void)returnDataWithRequestData:(NSData *)requestData Success:(FinishBlock)finishBlock failure:(ErrorBlock)errorBlock
{
    
    id myResult = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:nil];
    
    finishBlock(myResult);
    
}


-(NSString *)urlDictToStringWithUrlStr:(NSString *)urlStr WithDict:(NSDictionary *)parameters
{
    if (!parameters) {
        return urlStr;
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    //enumerateKeysAndObjectsUsingBlock会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block 这其实就是传递一个block到另一个方法，在这个例子里它会带着特定参数被反复调用，直到找到一个ENOUGH的key，然后就会通过重新赋值那个BOOL *stop来停止运行，停止遍历同时停止调用block
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part =[NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@?%@",urlStr,queryString];
    
    return pathStr;
    
}




#pragma mark -- 处理json格式的字符串中的换行符、回车符
- (NSString *)deleteSpecialCodeWithStr:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    return string;
}

@end
