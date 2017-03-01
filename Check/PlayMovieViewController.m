//
//  PlayMovieViewController.m
//  IOS_Minimotor
//
//  Created by 李江 on 15/11/15.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "PlayMovieViewController.h"
#import "Packge.h"
#import "NSDate+Additional.h"
#import "Battery.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>

#define statusBar_height 20
@interface PlayMovieViewController ()<AVAudioPlayerDelegate>
{
    float patient_info_h;
    
    Battery *battery;
    
    UIView *_btnView;
    NSTimer *_timer;
    NSTimer *_shengyutimer;
    int _e;
    
    int _miao;
    int _min;
    int _h;
    NSString *_dural;
    UIImageView *_luzhiimageView;
    UILabel *_luzhilable;
    UILabel *_titleLbale;
    
    BOOL _isplayEnd;
    
    UIView *_maskView;
    
    float _volume;
    AVAudioPlayer *_player;

}
@property(nonatomic, strong) WaveInfo *wave_ecg;
@property(nonatomic, strong) WaveInfo *wave_spo2;
@property(nonatomic, strong) WaveInfo *wave_resp;
@property(nonatomic, strong) WaveInfo *wave_art;
@property (nonatomic, strong) UIView *patientInfo;

@end

@implementation PlayMovieViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //    （获取当前电池条动画改变的时间）
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
    
    [UIView commitAnimations];
    
    _luzhiimageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 50 + 30 * ration_H, 15 * ration_H, 15 * ration_H)];
    _luzhiimageView.image = [UIImage imageNamed:@"custom_center.png"];
    _luzhiimageView.layer.cornerRadius = 15 * ration_H /2.0;
    _luzhiimageView.layer.masksToBounds = YES;
    _luzhiimageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_luzhiimageView];
    
    _titleLbale = [[UILabel alloc]initWithFrame:CGRectMake(_luzhiimageView.right + 10 * ration_H, _luzhiimageView.top, 300, 15 * ration_H)];
    _titleLbale.textColor = [UIColor whiteColor];
    _titleLbale.text = self.notice.EnddateString;
    _titleLbale.font = [UIFont boldSystemFontOfSize:18.0 * ration_H];
    [self.view addSubview:_titleLbale];
    
    
    _luzhilable = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 200  - 130 * ration_H, _luzhiimageView.top - 5, 200, 25 * ration_H)];
    _luzhilable.textColor = [UIColor whiteColor];
    _luzhilable.font = [UIFont boldSystemFontOfSize:22.0 * ration_H];
    [self.view addSubview:_luzhilable];
    
    [self _initHometime];
    
    
    if (_shengyutimer == nil) {
        _shengyutimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timershengyu:) userInfo:nil repeats:YES];
    }


}

- (BOOL)shouldAutorotate{
    
    return NO;
    
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popVC) name:@"pop" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"UpdateVolume"
                                               object:nil];
    
    _volume = .6;
    
    [self _initView];
}

- (void)_initView
{

    
    patient_info_h = 0.0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];  //屏幕长亮
     [AppDelegate GetAppDelegate].ishaveList = NO;
    
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor blackColor];
    DLog(@"width= %.f, heigth = %.f ", CUR_SCREEN_W, CUR_SCREEN_H);
    
       [BTCommunication sharedInstance].playMoviceDelegate = self;
    //状态栏
    //    [UIApplication sharedApplication].statusBarHidden = YES;
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
        
        UILabel *patientInfo = [[UILabel alloc] initWithFrame:rect(10, 0, CUR_SCREEN_W, 30)];
        patientInfo.font = font(16);
        patientInfo.textColor = [UIColor blackColor];
        patientInfo.textAlignment = NSTextAlignmentLeft;
        patientInfo.text = @"Patient A, NO. 1";
        //        [_patientInfo addSubview:patientInfo];
        
        
        // 电池电量显示
        battery = [[[NSBundle mainBundle] loadNibNamed:@"Battery" owner:self options:nil] lastObject];
        battery.frame = rect(CUR_SCREEN_W - 50 - 10, 5, 48, 20);
        battery.batteryType = Battery_display_typeDigital;
        battery.batteryValue = @"--";
        [_patientInfo addSubview:battery];
    }
    
    
    int count = 1;   //波形区的个数
    float unWaveAreaHeight = patient_info_h + statusBar_height;   //非波形区的高度
    float singleWaveAreaHeight = (CUR_SCREEN_H-unWaveAreaHeight)/count;   //单个波形区的高度
    // ECG波形
    _wave_ecg = [[WaveInfo alloc] initWithFrame:CGRectMake(0, unWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_ECG];
    _wave_ecg.tag = 1;
    [self.view addSubview:_wave_ecg];
    
    //  SpO2波形
    _wave_spo2 = [[WaveInfo alloc] initWithFrame:CGRectMake(0, unWaveAreaHeight + singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_SpO2];
    _wave_spo2.tag = 2;
    [self.view addSubview:_wave_spo2];
    
    
    // RESP波形
    //    _wave_resp = [[WaveInfo alloc] initWithFrame:rect(0, unWaveAreaHeight + 2*singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_RESP];
    //    _wave_resp.tag = 3;
    //    [self.view addSubview:_wave_resp];
    
    //    //  ART波形
    //    _wave_art = [[WaveInfo alloc]initWithFrame:rect(0, unWaveAreaHeight + 2*singleWaveAreaHeight, CUR_SCREEN_W, singleWaveAreaHeight) andType:Wave_type_ART];
    //    _wave_art.tag = 4;
    //    [self.view addSubview:_wave_art];
    
    _isplayEnd = NO;
    
    
    [self _inittimet];
  
    [self _initBtnView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEumd)];
    [self.view addGestureRecognizer:tap];

}
//获取总时间
- (void)_initHometime
{

    //获取播放数据
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:_notice.StardateString];
    NSDate *date2 = [formatter dateFromString:_notice.EnddateString];
    //时间间隔
    NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
        if(aTimer > 15)
        {
            aTimer = aTimer - 2;
        } else {
            aTimer = aTimer - 1;
        }
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
  
    _dural = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hour, minute,second];
    _luzhilable.text = _dural;

}

//创建定时器
- (void)_inittimet
{
    //定时器
    _e = 0;
    _miao = 0;
    _min = 0;
    _h = 0;
    
    if (_isplayEnd == YES) {
        
        if (_wave_ecg != nil && _wave_spo2 != nil) {
            [_wave_ecg _shujuqingling];
            [_wave_spo2 _shujuqingling];
        }
    }
    _isplayEnd = NO;
   
    if (_shengyutimer == nil) {
        _shengyutimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timershengyu:) userInfo:nil repeats:YES];
    }
    if(_timer == nil){
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.040 target:self selector:@selector(timerFireMeThod:) userInfo:nil repeats:YES];
    }
   
}

//点击屏幕的操作
- (void)tapEumd
{
    if (_isplayEnd == NO) {
        //关闭定时器
        [_timer setFireDate:[NSDate distantFuture]];
        [_shengyutimer setFireDate:[NSDate distantFuture]];
    }
    _maskView.alpha = .5;
    _btnView.hidden = NO;

}

//创建按钮
- (void)_initBtnView
{
    
    //创建遮罩视图
 
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    _maskView.backgroundColor = [UIColor grayColor];
    _maskView.alpha = 0;
    [self.view addSubview:_maskView];
        

    
    _btnView = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth - 250 * ration_H) / 2.0, (kScreenHeight  - 140 * ration_H) / 2.0 , 250 * ration_H, 140 * ration_H)];
    _btnView.backgroundColor = [UIColor clearColor];
    _btnView.hidden = YES;
    [self.view addSubview:_btnView];
    
    NSArray *array = @[@"backimage",@"playimage",];
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((_btnView.width - 80 * ration_H * array.count) / (array.count + 1) * (i + 1) + i * 80 * ration_H, 30, 80 * ration_H, 80 * ration_H)];
//        button.backgroundColor = RGB(225, 225, 225);
        [button setImage:[UIImage imageNamed:array[i]] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnView addSubview:button];
    }
    
    
}

- (void)btnAction:(UIButton *)btn
{
    _btnView.hidden = YES;
    _maskView.alpha = 0;
    //返回
    if (btn.tag == 100) {
        [_timer invalidate];
        _timer = nil;
        [_shengyutimer invalidate];
        _shengyutimer = nil;
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    
    //播放 / 重新播放
    if (btn.tag == 101) {
        if (_isplayEnd == NO) {
            //开启定时器
            [_timer setFireDate:[NSDate distantPast]];
            [_shengyutimer setFireDate:[NSDate distantPast]];
           
        }
        if (_isplayEnd == YES) {

            [self _inittimet];
        }
        
    }


}


- (void)_popVC
{
    [_timer invalidate];
    _timer = nil;
    [_shengyutimer invalidate];
    _shengyutimer = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
    [_PlayMovieVCDelegate gotoVC];
}

- (void)timershengyu:(NSTimer *)dt
{

    NSString *starstring = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",_h,_min,_miao];
    //获取播放数据
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:starstring];
    NSDate *date2 = [formatter dateFromString:_dural];
    //时间间隔
    NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
    _luzhilable.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hour, minute,second];
    if (hour == 0 && minute == 0 && second == 0) {
        [_shengyutimer setFireDate:[NSDate distantFuture]];
    }
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

-(void)timerFireMeThod:(NSTimer *) dt
{
    if (_e >=  _notice.PkArray.count) {
        [_timer invalidate];
        _timer = nil;
        [_shengyutimer invalidate];
        _shengyutimer = nil;
        _btnView.hidden = NO;
        _isplayEnd = YES;
        _maskView.alpha = .5;
         _luzhilable.text = [NSString stringWithFormat:@"00:00:00"];
        
        NSLog(@"播放状态：播放结束") ;
       
        
    } else {
//        NSLog(@"计算次数--%d",_e);
        NSString *dataString = _notice.PkArray[_e];
        NSData *data = [self initwith16dataString:dataString];
        [[BTCommunication sharedInstance] didReceivePlayMoviceData:data];
        _e ++;
    }
}

//16进制数－>Byte数组
- (NSData *)initwith16dataString:(NSString *)hexString
{
    
    ///// 将16进制数据转化成Byte 数组
    int j=0;
    Byte bytes[128];
    ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        //        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:44];
    //    NSLog(@"newData=%@",newData);
    return newData;
}


// 一包数据过来，刷新
- (void)realTimeCallBackWithPlaymovicePack:(Packge *)playmovicePack
{
    
    //ECG
    _wave_ecg.ecg_info.HRValue.text = (playmovicePack.HR == 0xff || playmovicePack.HR == 0) ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.HR];
    [_wave_ecg refreshWaveWithDataArr:playmovicePack.ECG_Dis];
    
    //SpO2
    _wave_spo2.spo2_info.spo2Value.text = (playmovicePack.Oxi == 0xff || playmovicePack.Oxi == 0) ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.Oxi];
    _wave_spo2.spo2_info.prValue.text = playmovicePack.Oxi_PR == 0xff ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.Oxi_PR];
    _wave_spo2.spo2_info.piValue.text = (playmovicePack.Oxi_PI == 0xff || playmovicePack.Oxi_PI == 0) ? @"--" : [NSString stringWithFormat:@"%.1f", playmovicePack.Oxi_PI/10.0];
    [_wave_spo2 refreshWaveWithDataArr:playmovicePack.Oxi_Dis];
    
    
    
//    if (![_wave_ecg.ecg_info.HRValue.text isEqualToString:@"--"]) {
//        
//        if (playmovicePack.HRIdentity == 1) {
//            
//            [self playSpO2VoiceWithVoiceID:@"ECG"];
//        }
//        
//    } else {
//        
//        if(playmovicePack.SpO2Identity == 1)
//        {
//            if(![_wave_spo2.spo2_info.spo2Value.text isEqualToString:@"--"]){
//                [self playSpO2VoiceWithVoiceID:_wave_spo2.spo2_info.spo2Value.text];
//            }
//
//            
//        }
//    }
//    
    //电量
    battery.batteryValue = [NSString stringWithFormat:@"%d", playmovicePack.Battery];
}


- (void)playSpO2VoiceWithVoiceID:(NSString *)VoiceID
{
//    //1.获得音效文件的全路径
//    NSString *Voicestr = [NSString stringWithFormat:@"%@.wav",VoiceID];
//    NSURL *url=[[NSBundle mainBundle]URLForResource:Voicestr withExtension:nil];
//    
//    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
//    if([VoiceID isEqualToString:@"ECG"])
//    {
//        VoiceID = @"1000";
//    }
//    SystemSoundID soundID= [VoiceID intValue];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//    
//    //把需要销毁的音效文件的ID传递给它既可销毁
//    //    AudioServicesDisposeSystemSoundID(soundID);
//    
//    //3.播放音效文件
//    //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
//    //    AudioServicesPlayAlertSound(soundID);
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
