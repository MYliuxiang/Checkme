//
//  CloudUpLodaManger.m
//  Checkme Mobile
//
//  Created by Viatom on 16/8/11.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "CloudUpLodaManger.h"
#import "AppDelegate.h"

#define DEFAULT_BLUE (RGB(38, 154, 208))


@implementation CloudUpLodaManger

+ (CloudUpLodaManger *)sharedManager
{
    static CloudUpLodaManger *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        sharedAccountManagerInstance = [[self alloc] init];
        
    });
    
    return sharedAccountManagerInstance;
    
}




- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _networkManager          = [NetWorkManager sharedManager];
        _networkManager.delegate = self;
        self.frame               = CGRectMake(0, 0, 60, 25);
        [_networkManager startNetWorkeWatch];
        self.isUpload            = NO;
        //        self.total = [CloudModel findByCriteria:@"where ISUpload = 0"].count;
        self.current             = 0;
        [self initView];
        [self upload];
    }
    return self;
}


- (void)initView
{
    UIView *view          = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
    view.backgroundColor  = [UIColor clearColor];
    //    [[AppDelegate GetAppDelegate].window addSubview:view];
    
    self.gifImageView        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
    NSMutableArray *gifArray = [NSMutableArray array];
    for (int i               = 0; i < 29; i ++) {
        
        UIImage *image           = [UIImage imageNamed:[NSString stringWithFormat:@"gif%d",i]];
        [gifArray addObject:image];
    }
    self.gifImageView.backgroundColor = [UIColor clearColor];
    self.gifImageView.animationImages    = gifArray;
    _gifImageView.animationDuration      = 2;
    _gifImageView.animationRepeatCount   = 99999;
    _gifImageView.userInteractionEnabled = YES;
    
    if (![UserDefault boolForKey:ISLOGIN]) {
        
        self.gifImageView.image = [UIImage imageNamed:@"未登录"];
        
    }else{
        
        self.gifImageView.image = [UIImage imageNamed:@"上传完成.png"];

    }
    
    //    [_gifImageView stopAnimating];
    [self addSubview:_gifImageView];
    
    
}

- (void)tap
{
    
    //    [[self ViewController].navigationController pushViewController:[[CloudVC alloc] init] animated:YES];
    
}

#pragma mark - NetWorkManagerDelegate
- (void) netWorkStatusWillChange:(NetworkStatus)status
{
    //网络发生改变
    [self upload];
    
}

- (void) netWorkStatusWillDisconnection
{
    //网络断开
    self.stateLabel.text    = [NSString stringWithFormat:@"没有网络，请检查网络"];
    self.gifImageView.image = [UIImage imageNamed:@"未登录"];
    [self.gifImageView stopAnimating];
    
}

- (void)upload
{
    //进行网络检查
    
    NetworkStatus *status = [[NetWorkManager sharedManager] checkNowNetWorkStatus];
    
    if (status == NotReachable) {
        
        self.gifImageView.image = [UIImage imageNamed:@"未登录"];
        //不能上传
        return;
    }
    
    if (![UserDefault boolForKey:ISLOGIN]) {
        
        self.gifImageView.image = [UIImage imageNamed:@"未登录"];
        
    }else{
        
        if ([UserDefault boolForKey:Auto]) {
            //自动上传
            
            NSArray *cloundArray = [CloudModel findByCriteria:@"where ISUpload = '0'"];
            if (cloundArray.count == 0) {
                //没有可以上传的
                self.isUpload = NO;
                [self.gifImageView stopAnimating];
                self.gifImageView.image = [UIImage imageNamed:@"上传完成.png"];
                return;
                
            }else{
                //patianId
                
                [self.gifImageView startAnimating];
                
                self.stateLabel.superview.alpha = 1;
                self.isUpload = YES;
                CloudModel *model = cloundArray[0];
//                int h = round((float)(model.height)/2.54);
                
                [WXDataService postPatianIDUrl:@"https://cloud.bodimetrics.com/fhir/patient"
                        params:@{@"resourceType":@"Patient",@"identifier":@{@"system":@"https://cloud.viatomtech.com/fhir",@"value": model.sn,@"medicalId": model.macID},@"active": @"1",@"name":model.name,@"gender":model.sex == 0 ? @"male":@"female",@"birthDate":model.birthDate,@"height":[NSString stringWithFormat:@"%.fcm",model.height],@"weight": [NSString stringWithFormat:@"%.fkg",model.weight],@"stepSize":@"--"}
                                      cacheKey:[NSString stringWithFormat:@"%@%@",model.macID,[UserDefault objectForKey:EMAIL]]
                                   finishBlock:^(id result) {
                                       NSDictionary *dic = result;
                                       NSString *patinID = dic[@"patient_id"];
                                       NSLog(@"%@",patinID);
                                       model.patinID = patinID;
                                       [model update];
                                       [self loadCloudModel:model];
                                       
                                   } errorBlock:^(NSError *error) {
                                       
                                       [self.gifImageView stopAnimating];
                                       self.gifImageView.image = [UIImage imageNamed:@"上传完成"];
                                       
                                   }];
                
            }
            
        }else{
            //手动上传
            if ([UserDefault boolForKey:Suto]) {
                NSArray *cloundArray = [CloudModel findByCriteria:@"where ISUpload = 0"];
                
                if (cloundArray.count == 0) {
                    //没有可以上传的
                    self.isUpload = NO;
                    self.gifImageView.image = [UIImage imageNamed:@"上传完成"];
                    [self.gifImageView stopAnimating];
                    [UserDefault setBool:NO forKey:Suto];
                    return;
                    
                }else{
                    //patianId
                    
                    [self.gifImageView startAnimating];
                    self.stateLabel.superview.alpha = 1;
                    self.isUpload = YES;
                    CloudModel *model = cloundArray[0];
                    int h = round((float)(model.height)/2.54);

                    [WXDataService postPatianIDUrl:@"https://cloud.bodimetrics.com/fhir/patient"
                            params:@{@"resourceType":@"Patient",@"identifier":@{@"system":@"https://cloud.viatomtech.com/fhir",@"value": model.sn,@"medicalId": model.macID},@"active": @"1",@"name":model.name,@"gender":model.sex == 0 ? @"male":@"female",@"birthDate":model.birthDate,@"height":[NSString stringWithFormat:@"%.fcm",model.height],@"weight": [NSString stringWithFormat:@"%.fkg",model.weight],@"stepSize":@"--"}
                                          cacheKey:[NSString stringWithFormat:@"%@%@",model.macID,[UserDefault objectForKey:EMAIL]]
                                       finishBlock:^(id result) {
                                           NSDictionary *dic       = result;
                                           NSString *patinID       = dic[@"patient_id"];
                                           model.patinID           = patinID;
                                           [model update];
                                           [self loadCloudModel:model];
                                           
                                       } errorBlock:^(NSError *error) {
                                           [self.gifImageView stopAnimating];
                                           self.gifImageView.image = [UIImage imageNamed:@"上传完成"];
                                       }];
                }
                
            }else{
                
                self.gifImageView.image = [UIImage imageNamed:@"上传完成"];
                [self.gifImageView stopAnimating];
            }
        }
    }
}

- (void)loadCloudModel:(CloudModel *)model
{
    
    NSMutableString *uploadStr = [NSMutableString stringWithFormat:@"%@",model.jsonStr];
    [uploadStr insertString:[NSString stringWithFormat:@"\"subject\":{\"reference\":\"%@\",\"display\":\"%@\"},\"device\":{\"sn\":\"%@\",\"display\":\"BM88\"},",model.patinID,model.name,model.sn] atIndex:1];
    NSData *data = [uploadStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    [WXDataService postUrl:@"https://cloud.bodimetrics.com/fhir/observation" params:dic finishBlock:^(id result) {
        _current++;
        self.stateLabel.text = [NSString stringWithFormat:@"UpCloudloading from device:%.2f%%",_current / (double)_total * 100];
        model.ISUpload = @"1";
        [model update];
        [self upload];
        
    } errorBlock:^(NSError *error) {
        
        [self.gifImageView stopAnimating];
        self.gifImageView.image = [UIImage imageNamed:@"上传完成"];
        
    }];
    
}


- (void)noticeUpdata
{
    self.total++;
    self.stateLabel.text = [NSString stringWithFormat:@"UpCloudloading from device:%.2f%%",_current / (double)_total * 100];
    if (self.isUpload) {
    }else{
        
        [self upload];
    }
    
}

@end




