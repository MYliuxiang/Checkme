//
//  ECGDetailViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ECGDetailViewController.h"
#import "BTUtils.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "ECGWave.h"
#import "ECGDetailWave.h"
#import "SIAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import "UAProgressView.h"
#import "SVProgressHUD.h"
#import "FileUtils.h"

#import "DlcEcgAlbumView.h"
#import "AlbumHeader.h"
#import "PublicMethods.h"
#import "MobClick.h"
#import "DeviceVersionUtils.h"


@interface ECGDetailViewController ()<EcgWaveViewDelegate, ECGInfoItemDelegate>
@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) ECGInfoItem *curECGInfoItem;
@property (nonatomic,retain) ECGDetailWave *ecgDetailWave;
@property (nonatomic,retain) UIView *viewDetailWave;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (nonatomic,retain) UAProgressView* progressView;
@property (nonatomic,retain) ECGWave *ecgWave;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@end

@implementation ECGDetailViewController
{
    NSString *curDirName;
    BOOL isLocalVoiceExisted;
    UIView *lineview;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   
    _curECGInfoItem.ecgDelegate = self;
    [MobClick beginLogPageView:@"ecgDetailPage"];
    
    if (_curECGInfoItem.dataVoice) {
        [self onECGDetailDataDownloadSuccess:(FileToRead*)_curECGInfoItem.dataVoice];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
      _curECGInfoItem.ecgDelegate = nil;
    [MobClick endLogPageView:@"ecgDetailPage"];
}

-(void)setCurUser:(User*) user andCurItem:(ECGInfoItem*) item
{
    _curUser = user;
    _curECGInfoItem = item;
    _curECGInfoItem.ecgDelegate = self;
    
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];//初始化UI 控件
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
    
//    UIImage *image = [UIImage imageNamed:@"share_black.png"];
//    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _rightBtn.frame = CGRectMake(self.view.bounds.size.width - 33 - 10,  5, 30, 30);
//    [_rightBtn setBackgroundImage:image forState:UIControlStateNormal];
//    _rightBtn.contentMode = UIViewContentModeScaleAspectFit;
//    [_rightBtn addTarget:self action:@selector(onShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:_rightBtn];
//
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
//#warning 清除记录 hjz
//    //清除记录
//    [UserDefaults removeObjectForKey:lastCheckmeName];
//    [UserDefaults synchronize];
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >5555555555");
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
    NSString *voiceName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][1]];
    if ([FileUtils isFileExist:voiceName inDirectory:curDirName]) {
        isLocalVoiceExisted = YES;
    }else{
        isLocalVoiceExisted = NO;
    }
    
    [self configSummary];
    [self addECGWave];
}

//设置诊断结果
-(void)configSummary
{
    _hrValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curECGInfoItem.innerData.HR);
    
    _sanValueimage.x  = _bgValueImage.left - _sanValueimage.width / 2.0  +  _curECGInfoItem.innerData.HR * _bgValueImage.width / 200.00;
    
    lineview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, _bgValueImage.height)];
    lineview.backgroundColor = [UIColor blackColor];
    [_bgValueImage addSubview:lineview];
    lineview.x = _curECGInfoItem.innerData.HR * _bgValueImage.width / 200.00 - 1;
    
    
//    _qrsValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curECGInfoItem.innerData.QRS);
//    if (_curECGInfoItem.enLeadKind==kLeadKind_Hand||_curECGInfoItem.enLeadKind==kLeadKind_Chest) {
//        //                                                            0x01                                                                                  0x02
//        _st.text = @"";
//        _stValue.text = @"";
//        _stUnit.text = @"";
//    }else{
//        if (_curECGInfoItem.enPassKind==kPassKind_Others) {
//            _stValue.text = @"--";
//        }else{
//          _stValue.text = [NSString stringWithFormat:@"%@%@",(_curECGInfoItem.innerData.ST>=0?(@"+"):@""),DOUBLE2_TO_STRING(((double)_curECGInfoItem.innerData.ST)/100.0)];
//        }
//    }
//    [_imgLead setImage: [UIImage imageNamed:[IMG_LEAD_ARRAY objectAtIndex:(_curECGInfoItem.enLeadKind-1)]]];
//    [_imgResult setImage:[UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curECGInfoItem.enPassKind]]];
    
    
    //ecg结果描述
    int hrValue = [[NSString stringWithFormat:@"%d",_curECGInfoItem.innerData.HR] intValue];
    if (hrValue < 30) {
        _sanValueimage.hidden = YES;
        _hrValue.text = @"--";
        lineview.hidden = YES;
        _strResult.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    
    
    
    else if( 30 <= hrValue && hrValue < 50)//心率值的判断
    {
        
        _strResult.text = DTLocalizedString(@"Heart rate: Low range", nil);
        
    }
    else if( 50 <= hrValue && hrValue <= 100)
    {
        _strResult.text = DTLocalizedString(@"Heart rate: Medium range", nil);
        
    }
    else if( 100 < hrValue && hrValue < 150)
    {
        _strResult.text =DTLocalizedString(@"Heart rate: High range", nil);
        
    }
    else {
        
        _strResult.text = DTLocalizedString(@"Heart rate: Out of range", nil);
    }
    
    
//    NSString *description = ecgResultDescrib(_curECGInfoItem.innerData.ecgResultDescrib);
//    if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
//        NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
//        description = [NSString stringWithFormat:@"%@ %@", strArr[0],strArr[1]];
//    } else { //只有一条描述
//    }
//    _strResult.text = description;
//    if ([_strResult.text isEqualToString:@"Contraction cardiaque prématurée suspectée, consultez un mèdecin"]) {
//        _strResult.font = [UIFont systemFontOfSize:15];
//    }
    
    
    
//    // 设置声音图标
//    if (_curECGInfoItem.bHaveVoiceMemo) {
//        //
//        if (isLocalVoiceExisted) { // 本地有录音数据
//            [_voiceImg setBackgroundImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
//        }
//        [_voiceImg addTarget:self action:@selector(willPlayVoice) forControlEvents:UIControlEventTouchUpInside];
//    }else { //如果没有声音
//        _voiceImg.hidden = YES;
//        //原图片下移
//        CGRect rect1 = _imgLead.frame;
//        rect1.origin.y += 10;
//        _imgLead.frame = rect1;
//        //
//        CGRect rect2 = _imgResult.frame;
//        rect2.origin.y += 15;
//        _imgResult.frame = rect2;
//    }
}

//添加ECG波形
-(void)addECGWave
{
    //只显示4行，剩下的滑入
    double ecgLineH = _waveView.frame.size.height/4;
    
    UIScrollView *sclv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _waveView.frame.size.width, _waveView.frame.size.height)];
    sclv.backgroundColor = [UIColor clearColor];

    //改动
    int lineNum = _curECGInfoItem.innerData.timeLength/5;   //5s每行
    
    _ecgWave = [[ECGWave alloc] initWithFrame:CGRectMake(0, 0, _waveView.frame.size.width, ecgLineH*lineNum) user:_curUser ecgItem:(ECGInfoItem *)_curECGInfoItem callerType:_curECGInfoItem.enLeadKind delegate:self];
   
    NSString *DeviceStr = [DeviceVersionUtils getDeviceVersion];
    sclv.contentSize = CGSizeMake(_ecgWave.frame.size.width, _ecgWave.frame.size.height + ([DeviceStr hasPrefix:@"iPad"]? 90 : 0));//ipad 设备
    
    [sclv addSubview:_ecgWave];

    [_waveView addSubview:sclv];
}

//导航栏分享
- (IBAction)onShareButtonClicked:(id)sender
{
    //使用第三方的 SIAlertView (貌似有点像iOS9中的 UIAlertController 的功能)
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Choose a way to share", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Save to Album", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andUser:_curUser andEcgInfoItem:(ECGInfoItem *)_curECGInfoItem andWaveType:@"ECG_Wave" andBPType:nil];
                              UIImage *image = [albumV captureView];
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                              
                          }];
    [alertView addButtonWithTitle:DTLocalizedString(@"Share", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andUser:_curUser andEcgInfoItem:(ECGInfoItem *)_curECGInfoItem andWaveType:@"ECG_Wave" andBPType:nil];
                              UIImage *image = [albumV captureView];
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImage *img = [UIImage imageWithData:imageData];
                              NSString *msgBody = [NSString stringWithFormat:DTLocalizedString(@"Name:%@\nMeasure Time:%@\nMeasurement:%@\nReports:See file attached\n", nil),_curUser.name,[NSDate engDescOfDateComp:_curECGInfoItem.dtcDate][2],DTLocalizedString(@"ECG Recorder", nil)];
                              [self shareByActivity:img shareText:msgBody];
                          }];
#warning 点击 取消按钮 Cancel   hjzXx
    [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];
}

-(void)shareByActivity:(UIImage*)shareImg shareText:(NSString*)shareText
{
    NSArray *activityItems;
    if (shareImg != nil) {
        activityItems = @[shareText, shareImg];
    } else {
        activityItems = @[shareText];
    }
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypePrint,UIActivityTypeAirDrop,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){//失败
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Save failed, please check your system's privacy settings.", nil) duration:3];
    }
    else{//成功
        [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Save succeeded", nil)];//提示信息(使用第三方的 SVProgressHUD)
    }
}


//隐藏状态栏和导航栏
-(void)hideBars
{
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    [self.navigationController setNavigationBarHidden:YES];
}

//显示状态栏和导航栏
-(void)showBars
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

//选中ECG波形
-(void)didChoiceWaveDuringStart:(double)startSecond end:(double)endSecond
{
    [self hideBars];
    UIView *viewDetailWave = nil;
    if([UIDevice currentDevice].systemVersion.doubleValue >= 7.0)
    {
        viewDetailWave = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CUR_SCREEN_W, CUR_SCREEN_H)];
    }
    else
    {
        viewDetailWave = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CUR_SCREEN_W, CUR_SCREEN_H)];
    }
    
    viewDetailWave.backgroundColor = COLOR_RGB(239, 239, 239, 1);//[UIColor whiteColor];
    
    UIScrollView *sclv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewDetailWave.frame.size.width, viewDetailWave.frame.size.height)];
    sclv.backgroundColor = [UIColor clearColor];

    
    ECGDetailWave *waveDetail = [[ECGDetailWave alloc] initWithMinFrame:CGRectMake(0, 0, sclv.frame.size.width, sclv.frame.size.height) ecgInnerData:_curECGInfoItem.innerData];
    sclv.contentSize = waveDetail.frame.size;
    _ecgDetailWave = waveDetail;
    [sclv addSubview: waveDetail];
    CGRect rect = [waveDetail rectForDisplayStart:startSecond end:endSecond fatherViewFrame:sclv.frame];
    [sclv scrollRectToVisible:rect animated:NO];
    [viewDetailWave addSubview:sclv];
    
    
    
    UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 51, 44)];
    [btnOK setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    btnOK.transform = CGAffineTransformMakeRotation(M_PI/2); //图形绘制
    btnOK.frame = CGRectMake(viewDetailWave.frame.size.width - btnOK.frame.size.width, 0, btnOK.frame.size.width, btnOK.frame.size.height);
    [btnOK addTarget:self action:@selector(onDetailWave_OK:) forControlEvents:UIControlEventTouchUpInside];
    [viewDetailWave addSubview:btnOK];
    
    [self.view addSubview: viewDetailWave];
    [self.view bringSubviewToFront:viewDetailWave];
    _viewDetailWave = viewDetailWave;
    
}

-(void)onDetailWave_OK:(id)sender
{
    if(_viewDetailWave.superview == self.view)
        [_viewDetailWave removeFromSuperview];
    _viewDetailWave = nil;
    _ecgDetailWave = nil;
    [self showBars];
}



//voice
-(void)willPlayVoice
{
    if(_curECGInfoItem.bHaveVoiceMemo)
    {
        //打开本地文件
        NSString *fileName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME,_curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][1]];
        NSData *fileData = [FileUtils readFile:fileName inDirectory:curDirName];
        _curECGInfoItem.dataVoice = [fileData mutableCopy];
        if(!_curECGInfoItem.dataVoice)
        {
            if ([AppDelegate GetAppDelegate].isOffline) {
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
            }else{
                
                if(![[BTCommunication sharedInstance] bLoadingFileNow])
                {
                    if(!_curECGInfoItem.bDownloadIng)
                    {
                        [_curECGInfoItem beginDownloadVoice];
                    }
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
                }
                
            }
        }
        else
        {
            [self palyVoiceWithData : _curECGInfoItem.dataVoice];
        }
    }
    
}

- (void)onECGDetailDataDownloadProgress:(double)progress
{
    if (!_progressView) {
        _voiceImg.hidden = YES;
        CGRect bond = _voiceImg.frame;
        _progressView = [[UAProgressView alloc] initWithFrame:bond];
        [_progressView setBackgroundColor:[UIColor clearColor]];
        [_resultView addSubview:_progressView];
    }

    [_progressView setProgress:progress animated:YES];
}

- (void)onECGDetailDataDownloadTimeout
{
    [_progressView removeFromSuperview];
    [_ecgWave showVoiceBtn];
}

- (void)onECGDetailDataDownloadSuccess:(FileToRead *)fileData
{
    _curECGInfoItem.ecgDelegate = nil;
    [_progressView removeFromSuperview];
    //下载成功 换成蓝色图标
    _voiceImg.hidden = NO;
    [_voiceImg setBackgroundImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
    
    NSString *fileName = [NSString stringWithFormat:ECG_VOICE_DATA_USER_TIME_FILE_NAME,_curUser.medical_id ,[NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curECGInfoItem.dtcDate][1]];
    [FileUtils saveFile:fileName FileData: _curECGInfoItem.dataVoice withDirectoryName:curDirName];
    
    if(_curECGInfoItem.dataVoice.length > 0)
        [self palyVoiceWithData : _curECGInfoItem.dataVoice];
    
    _curECGInfoItem.dataVoice = nil;
}

-(void)palyVoiceWithData:(NSData *)voiceData
{
    if([self.audioPlayer isPlaying])
    {
        [self.audioPlayer stop];
    }
    self.audioPlayer = nil;
    AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    tmpPlayer.volume = 0.8;
    self.audioPlayer = tmpPlayer;
    [self.audioPlayer play];
}

@end
