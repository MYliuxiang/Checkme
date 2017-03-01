//
//  MiniMonitorViewController.m
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/11.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "MiniMonitorViewController.h"
#import "Packge.h"
#import "NSDate+Additional.h"
#import "Battery.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayListViewController.h"
#import "WMAlterView.h"
#import "STAlertView.h"
#import "ImageListViewController.h"
#import "ListsViewController.h"
@interface MiniMonitorViewController ()<AVAudioPlayerDelegate,ListsViewControllerDelegate>
@property(nonatomic, strong) WaveInfo *wave_ecg;
@property(nonatomic, strong) WaveInfo *wave_spo2;
@property(nonatomic, strong) WaveInfo *wave_resp;
@property(nonatomic, strong) WaveInfo *wave_art;

@property (nonatomic, strong) UIView *patientInfo;

@end

#define statusBar_height 20

@implementation MiniMonitorViewController
{
    float patient_info_h;
    
    Battery *battery;
    STAlertView *stAlertView ;
    UIButton *_enmdbtn;
    
    UIView *_btnView;
    
    UIImageView *_luzhiimageView;
    UILabel *_luzhilable;

    NSTimer *_timer;
    int _miao;
    int _min;
    int _h;
    
    float _volume;
    AVAudioPlayer *_player;
    
    UIView *_bgView;
    UIView *_bgYXView;
}

- (void)tapAction
{
    
    [_bgYXView removeFromSuperview];
    [_bgView removeFromSuperview];
    
    
}
- (void) dealloc
{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popVC) name:@"pop" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Screenshot) name:Noti_Screenshot object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"UpdateVolume"
                                                object:nil];
    

    
//    5.可以动画的改变我们view的显示方式了
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
    
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
////    （获取当前电池条动画改变的时间）
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:duration];
//    
//    //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
//    
//    [UIView commitAnimations];
  
    _volume = .6;
    
     patient_info_h = 0.0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];  //屏幕长亮
    [AppDelegate GetAppDelegate].ishaveList = YES;
    
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor clearColor];
    DLog(@"width= %.f, heigth = %.f ", CUR_SCREEN_W, CUR_SCREEN_H);
    
    [BTCommunication sharedInstance].delegate = self;

    //状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    }
    _patientInfo = [[UIView alloc] initWithFrame:rect(0, statusBar_height, CUR_SCREEN_W, 30)];
    _patientInfo.backgroundColor = RGB(213, 213, 213);
    _patientInfo.alpha = 0.9;
    [self.view addSubview:_patientInfo];
    patient_info_h = _patientInfo.bounds.size.height;
    _patientInfo.tag = 1000;
    
   
    
    if (_patientInfo) {
    
        UILabel *patientInfo = [[UILabel alloc] initWithFrame:rect(10, 0, CUR_SCREEN_W, 15)];
        patientInfo.font = font(16);
        patientInfo.textColor = [UIColor blackColor];
        patientInfo.textAlignment = NSTextAlignmentLeft;
        patientInfo.text = @"Patient A, NO. 1";
//        [_patientInfo addSubview:patientInfo];
        
        
        UIButton *btu = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 30 - 70 , 5, 20, 20)];
        [btu setImage:[UIImage imageNamed:@"aboutimage"] forState:UIControlStateNormal];
        [btu addTarget:self action:@selector(btuabout) forControlEvents:UIControlEventTouchUpInside];
        [_patientInfo addSubview:btu];

        // 电池电量显示
        battery = [[[NSBundle mainBundle] loadNibNamed:@"Battery" owner:self options:nil] lastObject];
        battery.frame = rect(CUR_SCREEN_W - 50 - 10, 5, 48, 20);
        battery.batteryType = Battery_display_typeDigital;
        battery.batteryValue = @"--";
        [_patientInfo addSubview:battery];
        
        
    }
    
    int count = 1;   //波形区的个数
    float unWaveAreaHeight = patient_info_h + statusBar_height;   //非波形区的高度
    float singleWaveAreaHeight = (CUR_SCREEN_H - unWaveAreaHeight)/count;   //单个波形区的高度
    // ECG波形
    _wave_ecg = [[WaveInfo alloc] initWithFrame:CGRectMake(0, unWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_ECG];
    _wave_ecg.tag = 1;
    [self.view addSubview:_wave_ecg];
    
    //  SpO2波形
    _wave_spo2 = [[WaveInfo alloc] initWithFrame:CGRectMake(0, unWaveAreaHeight + singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_SpO2];
    _wave_spo2.tag = 2;
    [self.view addSubview:_wave_spo2];
    

    
    _luzhiimageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 50 + 30 * ration_H, 27 * ration_H, 15 * ration_H)];
    _luzhiimageView.image = [UIImage imageNamed:@"Image-2"];
    _luzhiimageView.hidden = YES;
    [self.view addSubview:_luzhiimageView];
    
    _luzhilable = [[UILabel alloc]initWithFrame:CGRectMake(_luzhiimageView.right + 10 * ration_H, _luzhiimageView.top , 200 * ration_H, 15 * ration_H)];
    _luzhilable.textColor = [UIColor whiteColor];
    _luzhilable.font = [UIFont boldSystemFontOfSize:20.0 * ration_H];
    _luzhilable.hidden = YES;
    [self.view addSubview:_luzhilable];
    
    // RESP波形
//    _wave_resp = [[WaveInfo alloc] initWithFrame:rect(0, unWaveAreaHeight + 2*singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_RESP];
//    _wave_resp.tag = 3;
//    [self.view addSubview:_wave_resp];

//    //  ART波形
//    _wave_art = [[WaveInfo alloc]initWithFrame:rect(0, unWaveAreaHeight + 2*singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_ART];
//    _wave_art.tag = 4;
//    [self.view addSubview:_wave_art];
    
//    [self _addxuanfuBtu];
    
    [self _initBtnView];
}

- (void)btuabout
{
    
    _bgYXView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,  kScreenHeight)];
    _bgYXView.backgroundColor = [UIColor blackColor];
    _bgYXView.alpha = .7;
    _bgYXView.userInteractionEnabled = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_bgYXView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_bgYXView addGestureRecognizer:tap];
    
    
    _bgView = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth - 100) / 2.0, (kScreenHeight - 80) / 2.0 , 100, 80)];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.masksToBounds = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
    
    UIButton *imageVeiw = [[UIButton alloc]initWithFrame:CGRectMake((_bgView.width - 250 * ration_H)/2.0, 0, 250 * ration_H, 120)];
//    imageVeiw.contentMode = UIViewContentModeScaleAspectFill;
//    imageVeiw.image = [UIImage imageNamed:@"my"];
    [imageVeiw setImage:[UIImage imageNamed:@"my"] forState:UIControlStateNormal];
   // [_bgView addSubview:imageVeiw];
    
//    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeBtn.backgroundColor = [UIColor redColor];
//    closeBtn.frame = CGRectMake(0, 0, 20, 20);
//    [closeBtn addTarget:self action:@selector(closeAC) forControlEvents:UIControlEventTouchUpInside];
//    [_bgView addSubview:closeBtn];
    
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 30 , _bgView.width, 20)];
    lable.font = [UIFont systemFontOfSize:14.0];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor colorWithRed:0 green:127/255.0 blue:188/255.0 alpha:1];
    [_bgView addSubview:lable];
   // lable.center = _bgView.center;

    
    NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    lable.text = [NSString stringWithFormat:@"Version %@",appVer];
    
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(0, lable.bottom, _bgView.width, 20)];
    lable1.font = [UIFont systemFontOfSize:14.0];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.textColor = [UIColor colorWithRed:0 green:127/255.0 blue:188/255.0 alpha:1];
    lable1.text = @"Supported by  Viatom";
   // [_bgView addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(0, lable1.bottom + 30, _bgView.width, 60)];
    lable2.font = [UIFont systemFontOfSize:14.0];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.numberOfLines = 3;
    lable2.textColor = [UIColor colorWithRed:0 green:127/255.0 blue:188/255.0 alpha:1];
    lable2.text = @"© Copyright 2016Viatom Technology Co., Ltd. \n All Rights Reserved";
//  [_bgView addSubview:lable2];
    
    
    NSLog(@"==anniu");
    
}

- (void)closeAC
{

    [_bgYXView removeFromSuperview];
    [_bgView removeFromSuperview];

}

//创建三个按钮
- (void)_initBtnView
{

    _btnView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth * 0.8, (kScreenHeight - 50) - 80 * ration_H + 50 - 10 , kScreenWidth * 0.2 , 80 * ration_H)];
    _btnView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_btnView];
    
    NSArray *array = @[@"Image-1",@"Image-5",@"Image-3"];
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((_btnView.width - 50 * ration_H * 3) / 4.0 * (i + 1) + i * 50 * ration_H, _btnView.height - 50 * ration_H, 50 * ration_H, 50 * ration_H)];
//        button.backgroundColor = RGB(225, 225, 225);
        [button setImage:[UIImage imageNamed:array[i]] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnView addSubview:button];
    }


}

- (void)btnAction:(UIButton *)btn
{
   //截屏
    if (btn.tag == 100) {
        
        [self Screenshot];
    }
    //录制/停止
    if (btn.tag == 101) {
        
        if ([DataArrayModel sharedInstance].isluzhi == NO) {
            NSLog(@"录制视频");
            
            [UIView animateWithDuration:.35 animations:^{
                btn.x = btn.x + 25;
                btn.y = btn.y + 25;
                btn.width = 0;
                btn.height = 0;
                
                
            } completion:^(BOOL finished) {
                
                [btn setImage:[UIImage imageNamed:@"Image-4"] forState:UIControlStateNormal];
                [UIView animateWithDuration:.35 animations:^{
                    btn.x = btn.x - 25;
                    btn.y = btn.y - 25;
                    btn.width = 50 * ration_H;
                    btn.height = 50 * ration_H;
                } completion:^(BOOL finished) {
                    [self STDnotiString:@"录制视频"];
                     [DataArrayModel sharedInstance].isluzhi = YES;
                    
                }];
                
            }];

           
        } else {
            
            NSLog(@"停止录制");
            [UIView animateWithDuration:.35 animations:^{
                btn.x = btn.x + 25;
                btn.y = btn.y + 25;
                btn.width = 0;
                btn.height = 0;
                
                
            } completion:^(BOOL finished) {
                
                [btn setImage:[UIImage imageNamed:@"Image-5"] forState:UIControlStateNormal];
                [UIView animateWithDuration:.35 animations:^{
                    btn.x = btn.x - 25;
                    btn.y = btn.y - 25;
                    btn.width = 50 * ration_H;
                    btn.height = 50 * ration_H;
                } completion:^(BOOL finished) {
                    [self STDnotiString:@"停止录制"];
                    [DataArrayModel sharedInstance].isluzhi = NO;
                }];
                
            }];
        }
    }
   
    //列表
    if (btn.tag == 102) {
        
        NSArray *array = [Notice allDbObjects];
        NSLog(@"=============数组个数%lu",(unsigned long)array.count);
        NSMutableArray *dataArray = [NSMutableArray new];
        for (int i = 0; i < array.count ; i ++) {
//            Notice *nito = array[i];
//            NSLog(@"------%@",nito.typeSting);
            [dataArray addObject:array[array.count - i - 1]];
        }
        
        ListsViewController *listVC = [[ListsViewController alloc]init];
        listVC.noticeArray = dataArray;
        listVC.ListsVCdelegate = self;
        [self presentViewController:listVC animated:YES completion:nil];
    }



}

//定时器调用
-(void)timerFireMeThod:(NSTimer *) dt
{
     _luzhilable.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",_h,_min,_miao];
    if (_miao == 59) {
       
        if (_min == 59) {
            _h ++ ;
            _min = 0;
            _miao = 0;
        } else {
            _min ++;
            _miao = 0;
        }
    } else {
        
        _miao ++;
    
    }
   
    
    
}

- (void)STDnotiString:(NSString *)noti
{
    
    if([noti isEqualToString:@"录制视频"])
    {
       
        [DataArrayModel sharedInstance].dataMutableArray = [NSMutableArray new];
        [DataArrayModel sharedInstance].isluzhi = YES;
        //获取开始时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         NSString *datetime = [formatter stringFromDate:[NSDate date]];
        [DataArrayModel sharedInstance].StardateString = datetime;

        //创建定时器
        _luzhiimageView.hidden = NO;
        _luzhilable.hidden = NO;
        _miao = 0;
        _min = 0;
        _h = 0;
        _luzhilable.text = @"00:00:00";
        if(_timer == nil){
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMeThod:) userInfo:nil repeats:YES];
    
        }
        
       
    }
    if([noti isEqualToString:@"停止录制"])
    {
        //获取结束时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *datetime = [formatter stringFromDate:[NSDate date]];
        [DataArrayModel sharedInstance].EeddateString = datetime;
        [DataArrayModel sharedInstance].isluzhi = NO;
        Notice *notice = [[Notice alloc]init];
        notice.PkArray = [NSMutableArray new];
       
        notice.StardateString = [DataArrayModel sharedInstance].StardateString;
        notice.EnddateString =  [DataArrayModel sharedInstance].EeddateString;
        notice.typeSting = @"movie";
        [notice.PkArray addObjectsFromArray:[DataArrayModel sharedInstance].dataMutableArray];
        [notice insertToDb];
        
        NSString *message = @"";
        message = @"Save succeeded";//保存成功
        [SVProgressHUD showWithStatus:message];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:.5];
        
        //消除定时器
        [_timer invalidate];
        _timer = nil;
        _luzhilable.hidden = YES;
        _luzhiimageView.hidden = YES;

        
//       stAlertView = [[STAlertView alloc] initWithTitle:@"提示"
//                                                      message:@"录制结束,是否保存"
//                                                textFieldHint:@"请输入该视频的名字(可不填)"
//                                               textFieldValue:nil
//                                            cancelButtonTitle:@"取消"
//                                            otherButtonTitles:@"确定"
//                            
//                                            cancelButtonBlock:^{
//                                                NSLog(@"Please, give me some feedback!");
//                                                Notice *notice = [Notice allDbObjects].lastObject;
//                                                [notice removeFromDb];
//                                            } otherButtonBlock:^(NSString * result){
//                                                NSLog(@"%@", result);
//                                                
//                                                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//                                                //2.把任务添加到队列中执行
//                                                dispatch_async(queue, ^{
//                                                
//                                                    //打印当前线程
//                                                    NSLog(@"%@",[NSThread currentThread]);
//                                                    Notice *notice = [Notice allDbObjects].lastObject;
//                                                    notice.StardateString = [DataArrayModel sharedInstance].StardateString;
//                                                    notice.EnddateString =  [DataArrayModel sharedInstance].EeddateString;
//                                                   
//                                                    if ([result isEqualToString:@""]) {
//                                                        notice.NameString = [DataArrayModel sharedInstance].EeddateString;
//                                                    } else {
//                                                         notice.NameString = result;
//                                                    }
//                                                   
//                                                    [notice.PkArray addObjectsFromArray:[DataArrayModel sharedInstance].dataMutableArray];
//                                                    [notice updatetoDb];
//                                        
//                                                    
//                                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                                        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功,可在录制列表查看" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                                                        [aler show];
//                                        
//                                                    });
//                                                });
//
//
//                                            }];
//
        
          }

}

// 一包数据过来，刷新
- (void)realTimeCallBackWithPack:(Packge *)pkg
{
    //ECG
    _wave_ecg.ecg_info.HRValue.text = (pkg.HR == 0xff || pkg.HR == 0) ? @"--" : [NSString stringWithFormat:@"%d", pkg.HR];
    [_wave_ecg refreshWaveWithDataArr:pkg.ECG_Dis];
    
    //SpO2
    _wave_spo2.spo2_info.spo2Value.text = (pkg.Oxi == 0xff || pkg.Oxi == 0) ? @"--" : [NSString stringWithFormat:@"%d", pkg.Oxi];
    _wave_spo2.spo2_info.prValue.text = pkg.Oxi_PR == 0xff ? @"--" : [NSString stringWithFormat:@"%d", pkg.Oxi_PR];
    _wave_spo2.spo2_info.piValue.text = (pkg.Oxi_PI == 0xff || pkg.Oxi_PI == 0) ? @"--" : [NSString stringWithFormat:@"%.1f", pkg.Oxi_PI/10.0];
    [_wave_spo2 refreshWaveWithDataArr:pkg.Oxi_Dis];
    
    
//    NSLog(@"================pkg.Identity:======%d,%d",pkg.SpO2Identity,pkg.HRIdentity);
    
  
        if ( ([pkg.ECG_Dis[0] floatValue]!= 0 && [pkg.ECG_Dis[1] floatValue] != 0 && [pkg.ECG_Dis[2] floatValue] != 0 && [pkg.ECG_Dis[3] floatValue] != 0 && [pkg.ECG_Dis[4] floatValue] != 0) || (pkg.HR != 0xff && pkg.HR != 0)) {
            
            if (pkg.HRIdentity == 1) {
                
                [self playSpO2VoiceWithVoiceID:@"ECG"];
            }
            
        } else {
           
            if(pkg.SpO2Identity == 1)
            {
                if(![_wave_spo2.spo2_info.spo2Value.text isEqualToString:@"--"]){
                 [self playSpO2VoiceWithVoiceID:_wave_spo2.spo2_info.spo2Value.text];
                }
               
            }
        }
    
    
    //电量
    battery.batteryValue = [NSString stringWithFormat:@"%d", pkg.Battery];
}

- (BOOL)shouldAutorotate{
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}


- (void)playSpO2VoiceWithVoiceID:(NSString *)VoiceID
{
    //1.获得音效文件的全路径
//    NSString *Voicestr = [NSString stringWithFormat:@"%@.wav",VoiceID];
//     NSURL *url=[[NSBundle mainBundle]URLForResource:Voicestr withExtension:nil];
//
//    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
//    if([VoiceID isEqualToString:@"ECG"])
//    {
//       VoiceID = @"1000";
//    }
//     SystemSoundID soundID= [VoiceID intValue];
//     AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
// 
//    //把需要销毁的音效文件的ID传递给它既可销毁
////    AudioServicesDisposeSystemSoundID(soundID);
//
//     //3.播放音效文件
//        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
////    AudioServicesPlayAlertSound(soundID);
//    AudioServicesPlaySystemSound(soundID);
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",VoiceID] ofType:@"wav"]] error:nil];//使用本地URL创建
    _player.delegate = self;
    _player.volume = _volume;//0.0-1.0之间
    //3.缓冲
//    [_player prepareToPlay];
    [_player play];//播放
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //播放结束时执行的动作
      [_player stop];
      _player = nil;
}



-(void)volumeChanged:(NSNotification *)notification
{

    NSLog(@"----%@",notification.object);
    
    _volume = [notification.object floatValue];
    
}




//截屏保存到数据库
- (void)Screenshot
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //2.把任务添加到队列中执行
    dispatch_async(queue, ^{
        
        //打印当前线程
        NSLog(@"%@",[NSThread currentThread]);
     
        UIGraphicsBeginImageContext(self.view.bounds.size);     //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//renderInContext呈现接受者及其子范围到指定的上下文
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上
       
        UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        
        
//        STDImagetice *imagetice = [[STDImagetice alloc]init];
//        //获取结束时间
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *datetime = [formatter stringFromDate:[NSDate date]];
//        imagetice.EnddateString = datetime;
//        imagetice.data = imageData;
//        [imagetice insertToDb];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//         
//            NSString *message = @"";
//            message = DTLocalizedString(@"Save succeeded",nil);//报村成功
//            [SVProgressHUD showWithStatus:message];
//            [self performSelector:@selector(dismiss) withObject:nil afterDelay:.35];

        });
    });

}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        message = @"Save succeeded";//报村成功
        //下文的图片
        NSData *imageData = UIImagePNGRepresentation(image);
        Notice *notice = [[Notice alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *datetime = [formatter stringFromDate:[NSDate date]];
        notice.EnddateString = datetime;
        notice.data = imageData;
        notice.typeSting = @"image";
        [notice insertToDb];
        
        

        
    } else {
        
        message = @"Save failed";  //保存失败
//        message = [error description];
    }
    [SVProgressHUD showWithStatus:message];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.5];
    NSLog(@"message is %@",message);
}


- (void)dismiss
{

  [SVProgressHUD dismiss];

}

- (void)_popVC
{

    UIGraphicsBeginImageContext(self.view.bounds.size);     //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//renderInContext呈现接受者及其子范围到指定的上下文
     UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上下文的图片
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [AppDelegate GetAppDelegate].ischonglian = YES;
    [AppDelegate GetAppDelegate].image = viewImage;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_bgYXView removeFromSuperview];
    [_bgView removeFromSuperview];
}


#pragma mark ------ ListsViewControllerDelegate -----------
- (void)gotoVC
{

    [self _popVC];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
