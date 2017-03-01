//
//  PlayListViewController.m
//  IOS_Minimotor
//
//  Created by lijiang on 15/10/29.
//  Copyright © 2015年 Viatom. All rights reserved.
//

#import "PlayListViewController.h"
#import "Packge.h"
#import "NSDate+Additional.h"
#import "Battery.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>

#define statusBar_height 20

@interface PlayListViewController ()<UIAlertViewDelegate>
{
    float patient_info_h;
    
    Battery *battery;
   
    NSTimer *_timer;
    int _e;
    
    Notice *_playNotice; //数据model
  
    UIView *_maskView;                          //遮罩视图
    UIImageView *_headerView;                   //头部视图
    LJListTabView *_posterHeaderTableView;//头部视图的海报视图
    
    
    UILabel *_playtitleLabel;//当前播放名
    UILabel *_playandstoplable;//播放和暂停
    UILabel *_playstate;//播放状态
    UILabel *_playtime;//总时长
    
}

@property(nonatomic, strong) WaveInfo *wave_ecg;
@property(nonatomic, strong) WaveInfo *wave_spo2;
@property(nonatomic, strong) WaveInfo *wave_resp;
@property(nonatomic, strong) WaveInfo *wave_art;
@property (nonatomic, strong) UIView *patientInfo;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;


@end

@implementation PlayListViewController

- (void) dealloc
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *array = [Notice allDbObjects];
    NSLog(@"=============数组个数%lu",(unsigned long)array.count);
    NSMutableArray *dataArray = [NSMutableArray new];
    for (int i = 0; i < array.count ; i ++) {
        [dataArray addObject:array[array.count - i - 1]];
    }
    self.noticeArray = dataArray;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Screenshot) name:Noti_Screenshot object:nil];
    
    patient_info_h = 0.0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];  //屏幕长亮
    [AppDelegate GetAppDelegate].ishaveList = NO;
    
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor blackColor];
    DLog(@"width= %.f, heigth = %.f ", CUR_SCREEN_W, CUR_SCREEN_H);
    
    [BTCommunication sharedInstance].playMoviceDelegate = self;
    
    //状态栏
//        [UIApplication sharedApplication].statusBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    }
    _patientInfo = [[UIView alloc] initWithFrame:rect(0, 0, CUR_SCREEN_W, 60)];
    _patientInfo.backgroundColor = RGB(213, 213, 213);
    _patientInfo.alpha = 1;
    [self.view addSubview:_patientInfo];
     patient_info_h = _patientInfo.bounds.size.height - 20;
     _patientInfo.tag = 1000;
    
    UIView *taberView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    taberView.backgroundColor = [UIColor blackColor];
    [_patientInfo addSubview:taberView];

    
    if (_patientInfo) {
        
        UILabel *patientInfo = [[UILabel alloc] initWithFrame:rect(10, 20, 100, 40)];
        patientInfo.font = [UIFont boldSystemFontOfSize:15];
        patientInfo.tag = 100;
        patientInfo.textColor = [UIColor blackColor];
        patientInfo.backgroundColor = [UIColor clearColor];
        patientInfo.userInteractionEnabled = YES;
        patientInfo.textAlignment = NSTextAlignmentLeft;
        patientInfo.text = @"< 返回";
        [_patientInfo addSubview:patientInfo];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapbtuAction:)];
        [patientInfo addGestureRecognizer:tap];
        
        UILabel *patientInfo1 = [[UILabel alloc] initWithFrame:rect((kScreenWidth - 100) / 2.0, 20, 100, 40)];
        patientInfo1.font = [UIFont boldSystemFontOfSize:15];
        patientInfo1.numberOfLines = 0;
        patientInfo1.textColor = [UIColor blackColor];
        patientInfo1.backgroundColor = [UIColor clearColor];
        patientInfo1.userInteractionEnabled = YES;
        patientInfo1.textAlignment = NSTextAlignmentCenter;
        patientInfo1.text = @"播放列表 \n (下拉)";
        [_patientInfo addSubview:patientInfo1];
        
        
        //当前播放名
        _playtitleLabel = [[UILabel alloc] initWithFrame:rect(80 , 20, 220, 40)];
        _playtitleLabel.font = [UIFont boldSystemFontOfSize:15];
        _playtitleLabel.numberOfLines = 0;
        _playtitleLabel.textColor = [UIColor blackColor];
        _playtitleLabel.backgroundColor = [UIColor clearColor];
        _playtitleLabel.userInteractionEnabled = YES;
        _playtitleLabel.textAlignment = NSTextAlignmentLeft;
        _playtitleLabel.text = @"当前播放：暂无";
        [_patientInfo addSubview:_playtitleLabel];
        
        
        _playtime = [[UILabel alloc] initWithFrame:rect( _playtitleLabel.right + 4 , 20, 240, 40)];
        _playtime.font = [UIFont boldSystemFontOfSize:15];
        _playtime.numberOfLines = 0;
        _playtime.textColor = [UIColor blackColor];
        _playtime.backgroundColor = [UIColor clearColor];
        _playtime.userInteractionEnabled = YES;
        _playtime.textAlignment = NSTextAlignmentLeft;
        _playtime.text = @"当前时长：暂无";
        [_patientInfo addSubview:_playtime];
        

        //播放和暂停
        _playandstoplable = [[UILabel alloc] initWithFrame:rect( kScreenWidth - 100 - 10, 20, 100, 40)];
        _playandstoplable.font = [UIFont boldSystemFontOfSize:16];
        _playandstoplable.numberOfLines = 0;
        _playandstoplable.tag = 101;
        _playandstoplable.textColor = [UIColor blackColor];
        _playandstoplable.backgroundColor = [UIColor clearColor];
        _playandstoplable.userInteractionEnabled = YES;
        _playandstoplable.textAlignment = NSTextAlignmentCenter;
//        _playandstoplable.text = @"暂 停";
        [_patientInfo addSubview:_playandstoplable];
        UITapGestureRecognizer *palyanndstoptap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapbtuAction:)];
        [_playandstoplable addGestureRecognizer:palyanndstoptap];
        
        
        //播放状态
        _playstate = [[UILabel alloc] initWithFrame:rect( kScreenWidth - 100 - 10 - 170, 20, 170, 40)];
        _playstate.font = [UIFont boldSystemFontOfSize:15];
        _playstate.numberOfLines = 0;
        _playstate.textColor = [UIColor blackColor];
        _playstate.backgroundColor = [UIColor clearColor];
        _playstate.userInteractionEnabled = YES;
        _playstate.textAlignment = NSTextAlignmentLeft;
//        _playstate.text = @"播放状态：播放中...";
        [_patientInfo addSubview:_playstate];
       

//        // 电池电量显示
//        battery = [[[NSBundle mainBundle] loadNibNamed:@"Battery" owner:self options:nil] lastObject];
//        battery.frame = rect(CUR_SCREEN_W - 50 - 10, 5, 48, 20);
//        battery.batteryType = Battery_display_typeDigital;
//        battery.batteryValue = @"--";
//        [_patientInfo addSubview:battery];
    }
    
    
    int count = 2;   //波形区的个数
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
    
    
    //创建遮罩视图
    [self _initMaskView];
    
    //创建头部视图
    [self _initHeaderView];
    
    //3.创建灯光视图
    [self _initLightView];
    
    [self.view addSubview:_patientInfo];
    
    //添加下啦手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downHeaderView)];
    //轻扫方向
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipe];

    
}

#pragma mark ----------------------- 头部列表的创建 ----------------------------------
//创建遮罩视图
- (void)_initMaskView
{
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0;
    [self.view addSubview:_maskView];
    
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upHeaderView)];
    [_maskView addGestureRecognizer:tap];
    
    
    //添加一个上拉事件
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upHeaderView)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [_maskView addGestureRecognizer:swipe];
    
}

//创建头部视图
- (void)_initHeaderView
{
    _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -70, kScreenWidth, 155)];
    //事件开启
    _headerView.userInteractionEnabled = YES;
    //设置背景图片
    UIImage *image = [UIImage imageNamed:@"headerbg"];
    //设置图片的拉伸位置
    image = [image stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    _headerView.image = image;
    [self.view addSubview:_headerView];
    
    //---------------创建子视图-------------------
    //1.列表视图
    _posterHeaderTableView = [[LJListTabView alloc] initWithFrame:CGRectMake(0, 10 , kScreenWidth, 120) style:UITableViewStylePlain];
    _posterHeaderTableView.LJListdelegate = self;
    _posterHeaderTableView.dataList = self.noticeArray;
    [_headerView addSubview:_posterHeaderTableView];
    
    //2.创建一个按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((kScreenWidth - 60)/2.0, 130, 60, 30);
    button.tag = 123;
    [button setImage:[UIImage imageNamed:@"downimg"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(exchangeShowHeaderView) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:button];
    
}
//3.创建灯光视图
- (void)_initLightView
{
    //124 * 204
    //创建左侧灯光视图
    UIImageView *leftLightView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2.0 - 35 , 5, 120, 150)];
    leftLightView.backgroundColor = [UIColor clearColor];
    leftLightView.image = [UIImage imageNamed:@"lightdeng"];
    [_headerView addSubview:leftLightView];
   
    
    //创建右侧灯光视图
    UIImageView *rightLightView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2.0 + 35 , 5, 120, 150)];
//    rightLightView.right = kScreenWidth - 15;
    rightLightView.backgroundColor = [UIColor clearColor];
    rightLightView.image = [UIImage imageNamed:@"lightdeng"];
    [_headerView addSubview:rightLightView];
    
}

#pragma mark - 收起或者放下头视图
- (void)exchangeShowHeaderView
{
    if (_headerView.top == 60) {
        //当前状态是放下的状态(执行收起操作)
        
        //添加动画
        [UIView animateWithDuration:.35 animations:^{
            _headerView.top = - 70;
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            //获取头视图里面的按钮
            UIButton *button = (UIButton *)[_headerView viewWithTag:123];
            button.imageView.transform = CGAffineTransformIdentity;
        }];
        
    } else if (_headerView.top == -70) {
        //执行放下操作
        //添加动画
        [UIView animateWithDuration:.35 animations:^{
            _headerView.top = 60;
            _maskView.alpha = .5;
        } completion:^(BOOL finished) {
            //获取头视图里面的按钮
            UIButton *button = (UIButton *)[_headerView viewWithTag:123];
            button.imageView.transform = CGAffineTransformMakeRotation(M_PI);;
        }];
    }
}

//收起头视图
- (void)upHeaderView
{
    //添加动画
    [UIView animateWithDuration:.35 animations:^{
        _headerView.top = -70;
        _maskView.alpha = 0;
    } completion:^(BOOL finished) {
        //获取头视图里面的按钮
        UIButton *button = (UIButton *)[_headerView viewWithTag:123];
        button.imageView.transform = CGAffineTransformIdentity;
    }];
}

//放下头视图
- (void)downHeaderView
{
    //添加动画
    [UIView animateWithDuration:.35 animations:^{
        _headerView.top = 60;
        _maskView.alpha = .5;
    } completion:^(BOOL finished) {
        //获取头视图里面的按钮
        UIButton *button = (UIButton *)[_headerView viewWithTag:123];
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI);;
    }];
}

#pragma maek ------- LJListdelegate方法 -------------------
- (void)gotoPlayMoviceselectedIndexPath:(NSIndexPath *)selected
{
    //定时器
    _e = 0;
    if(_timer != nil){
        //关闭定时器
        [_timer setFireDate:[NSDate distantFuture]];

    }

    [self dismiss];
    
    _playandstoplable.text = @"暂 停";
    _playstate.text = @"播放状态：播放中...";
    
    [self upHeaderView];
   
    _selectedIndexPath = selected;
  
    if (_wave_ecg != nil && _wave_spo2 != nil) {
        [_wave_ecg _shujuqingling];
        [_wave_spo2 _shujuqingling];
    }
    
    //获取播放数据
    _playNotice = _noticeArray[_selectedIndexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:_playNotice.StardateString];
    NSDate *date2 = [formatter dateFromString:_playNotice.EnddateString];
    //时间间隔
    NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
    NSString *dural = [NSString stringWithFormat:@"%d时%d分%d秒", hour, minute,second];
    
    //当前播放ming
    _playtitleLabel.text = [NSString stringWithFormat: @"当前播放：%@",_playNotice.NameString];
    
    _playtime.text = [NSString stringWithFormat: @"当前时长：%@",dural];
    if(_timer == nil){
       _timer = [NSTimer scheduledTimerWithTimeInterval:0.040 target:self selector:@selector(timerFireMeThod:) userInfo:nil repeats:YES];
    } else {
        //开启定时器
        [_timer setFireDate:[NSDate distantPast]];
    
    }
}

//返回 暂停 播放 事件
- (void)tapbtuAction:(UITapGestureRecognizer *)tap
{
    //返回上个界面
    if (tap.view.tag == 100) {
        [_timer invalidate];
        _timer = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if(tap.view.tag == 101){
        if ([_playandstoplable.text isEqualToString:@"暂 停"]) {
            //关闭定时器
            [_timer setFireDate:[NSDate distantFuture]];
            _playandstoplable.text = @"播 放";
            _playstate.text = @"播放状态：已暂停";
            NSString *message = @"";
            message = DTLocalizedString(@"暂停中...",nil);
            [SVProgressHUD showWithStatus:message];
    
        } else {
            //开启定时器
            [_timer setFireDate:[NSDate distantPast]];
            _playandstoplable.text = @"暂 停";
            _playstate.text = @"播放状态：播放中...";
            [self dismiss];
           
        }
    
    }
}

-(void)timerFireMeThod:(NSTimer *) dt
{
    if (_e >=  _playNotice.PkArray.count) {
        [_timer invalidate];
        _timer = nil;
        _playstate.text = @"播放状态：播放结束";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"播放结束" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新播放",@"播放下一个", nil];
        [alert show];
        
    } else {
       NSLog(@"计算次数--%d",_e);
        NSString *dataString = _playNotice.PkArray[_e];
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
    
      NSLog(@"===============================================");

    //ECG
    _wave_ecg.ecg_info.HRValue.text = (playmovicePack.HR == 0xff || playmovicePack.HR == 0) ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.HR];
    [_wave_ecg refreshWaveWithDataArr:playmovicePack.ECG_Dis];
    
    //SpO2
    _wave_spo2.spo2_info.spo2Value.text = (playmovicePack.Oxi == 0xff || playmovicePack.Oxi == 0) ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.Oxi];
    _wave_spo2.spo2_info.prValue.text = playmovicePack.Oxi_PR == 0xff ? @"--" : [NSString stringWithFormat:@"%d", playmovicePack.Oxi_PR];
    _wave_spo2.spo2_info.piValue.text = (playmovicePack.Oxi_PI == 0xff || playmovicePack.Oxi_PI == 0) ? @"--" : [NSString stringWithFormat:@"%.1f", playmovicePack.Oxi_PI/10.0];
    [_wave_spo2 refreshWaveWithDataArr:playmovicePack.Oxi_Dis];
    

    
    if (![_wave_ecg.ecg_info.HRValue.text isEqualToString:@"--"]) {
        
        if (playmovicePack.HRIdentity == 1) {
            
            [self playSpO2VoiceWithVoiceID:@"ECG"];
        }
        
    } else {
        
        if(playmovicePack.SpO2Identity == 1)
        {
            [self playSpO2VoiceWithVoiceID:_wave_spo2.spo2_info.spo2Value.text];
            
        }
    }
    
    //电量
//    battery.batteryValue = [NSString stringWithFormat:@"%d", pkg.Battery];
}


- (void)playSpO2VoiceWithVoiceID:(NSString *)VoiceID
{
    //1.获得音效文件的全路径
    NSString *Voicestr = [NSString stringWithFormat:@"%@.wav",VoiceID];
    NSURL *url=[[NSBundle mainBundle]URLForResource:Voicestr withExtension:nil];
    
    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
    if([VoiceID isEqualToString:@"ECG"])
    {
        VoiceID = @"1000";
    }
    SystemSoundID soundID= [VoiceID intValue];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    
    //把需要销毁的音效文件的ID传递给它既可销毁
    //    AudioServicesDisposeSystemSoundID(soundID);
    
    //3.播放音效文件
    //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
    //    AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(soundID);
    
    
    
    
}

//截屏保存相册
- (void)Screenshot
{
    
    UIGraphicsBeginImageContext(self.view.bounds.size);     //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//renderInContext呈现接受者及其子范围到指定的上下文
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上下文的图片
    UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    
    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        message = DTLocalizedString(@"Save succeeded",nil);//报村成功
        
        
    }else
    {
        message = DTLocalizedString(@"Save failed",nil);  //保存失败
        //        message = [error description];
    }
    [SVProgressHUD showWithStatus:message];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.35];
    NSLog(@"message is %@",message);
}

#pragma mark --------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //重新播放
    if (buttonIndex == 1) {
        
        [self gotoPlayMoviceselectedIndexPath:_selectedIndexPath];
        
    }
    //播放下一个
    if (buttonIndex == 2) {
        
        if (_selectedIndexPath.row + 1 < _noticeArray.count) {
            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row + 1 inSection:0];
            [self gotoPlayMoviceselectedIndexPath:_selectedIndexPath];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"暂无视频" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
}
- (void)dismiss
{
    
    [SVProgressHUD dismiss];
    
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
