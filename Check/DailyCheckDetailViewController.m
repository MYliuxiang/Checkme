//
//  DailyCheckDetailViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-6.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "DailyCheckDetailViewController.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "ECGWave.h"
#import "BPCheckItem.h"
#import "ECGDetailWave.h"
#import "SIAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import "UAProgressView.h"
#import "SVProgressHUD.h"
#import "FileUtils.h"
#import "Xuser.h"
#import "UserList.h"

#import "DlcEcgAlbumView.h"
#import "AlbumHeader.h"
#import "MobClick.h"
#import "DeviceVersionUtils.h"


@class CBAutoScrollLabel;

@interface DailyCheckDetailViewController ()<EcgWaveViewDelegate, DailyCheckItemDelegate, spotCheckItemDelegate>
@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) Xuser *curXuser;
@property (nonatomic,retain) DailyCheckItem *curDLCInfoItem;
@property (nonatomic,retain) SpotCheckItem *curSPCInfoItem;
@property (nonatomic,retain) ECGDetailWave *ecgDetailWave;
@property (nonatomic,retain) UIView *viewDetailWave;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (nonatomic,retain) UAProgressView* progressView;
@property (nonatomic,retain) ECGWave *ecgWave;
@property (nonatomic, strong) UIButton *rightBtn;  //右侧按钮

@end


@implementation DailyCheckDetailViewController
{
    NSString *curDirName;
    int curUserIndex;
    int curXuserIndex;
    BOOL isLocalVoiceExisted;
    BOOL isSpc;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"DLCdetailPage"];
    
 
//    UIImage *image = [UIImage imageNamed:@"share_black.png"];
//    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _rightBtn.frame = CGRectMake(self.view.bounds.size.width - 33 - 10,  5, 30, 30);
//    [_rightBtn setBackgroundImage:image forState:UIControlStateNormal];
//    _rightBtn.contentMode = UIViewContentModeScaleAspectFit;
//    [_rightBtn addTarget:self action:@selector(onShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:_rightBtn];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    _curDLCInfoItem.dlcDelegate = nil;
    _curSPCInfoItem.spcDelegate = nil;
    [MobClick endLogPageView:@"DLCdetailPage"];
    
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
  
}


-(void)setCurUser:(User*) user andCurItem:(DailyCheckItem*) item
{
    _curUser = user;
    _curDLCInfoItem = item;
    _curDLCInfoItem.dlcDelegate = self;
}

-(void)setCurXuser:(Xuser *)xUser andCurSpcItem:(SpotCheckItem *)spcItem
{
    _curXuser = xUser;
    _curSPCInfoItem = spcItem;
    _curSPCInfoItem.spcDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];//初始化UI控件
    
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
//    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
//
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

//    //隐藏右侧栏按钮
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
//    
//    
//    [self.navigationController.navigationBar addSubview:_rightBtn];
    
//    self.navigationItem.title = nil;
//    UILabel *navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake((CUR_SCREEN_W - 150)*0.5, 0, 150, 40)];
//    navigationLabel.text = DTLocalizedString(@"Detail", nil);
//    navigationLabel.font = [UIFont boldSystemFontOfSize:17];
//    navigationLabel.textColor = [UIColor blackColor];
//    navigationLabel.textAlignment = NSTextAlignmentCenter;
//    [self.navigationController.navigationBar addSubview:navigationLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initUI
{
    if ([UserList instance].isSpotCheck) {
        isSpc = YES;
    } else {
        isSpc = NO;
    }
    
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
    curUserIndex = (int)[userDefaults integerForKey:@"LastUser"];
    curXuserIndex = (int)[userDefaults integerForKey:@"LastXuser"];
//#warning 清除记录 hjz
//    //清除记录
//    [UserDefaults removeObjectForKey:lastCheckmeName];
//    [UserDefaults synchronize];
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >2222222222");
    
    NSString *voiceName = @"";
    if (isSpc) {
        voiceName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][1]];
    } else {
        voiceName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][1]];
    }
    
    if ([FileUtils isFileExist:voiceName inDirectory:curDirName]) {
        isLocalVoiceExisted = YES;
    }else{
        isLocalVoiceExisted = NO;
    }
    
    [self configSummary];
    [self addECGWave];
}

//上部诊断结果界面
-(void)configSummary
{
    //ecg
    _hr.text = INT_TO_STRING_WITHOUT_ERR_NUM((isSpc ? _curSPCInfoItem.HR : _curDLCInfoItem.HR));
    _qrs.text = INT_TO_STRING_WITHOUT_ERR_NUM((isSpc ? 0 : _curDLCInfoItem.RR));
    
    int hrValue = [[NSString stringWithFormat:@"%d",_curDLCInfoItem.HR] intValue];
    
    if (hrValue == 0) {
        _hr.text = @"--";
        _ecgStrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    
    else if( 0 < hrValue && hrValue < 50)
    {
        _ecgStrResult.text = DTLocalizedString(@"Heart rate: Low range", nil);
        
    }
    else if( 50 <= hrValue && hrValue <= 100)
    {
        _ecgStrResult.text = DTLocalizedString(@"Heart rate: Medium range", nil);
        
    }
    else if( 100 < hrValue && hrValue < 150)
    {
        _ecgStrResult.text =DTLocalizedString(@"Heart rate: High range", nil);
        
    }
    else {
        
        _ecgStrResult.text = DTLocalizedString(@"Heart rate: Out of range", nil);
    }
    
    _qrs.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCInfoItem.RR);
    
    //ecg结果描述
//    _ecgStrResult.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    NSString *description = ecgResultDescrib(isSpc ? _curSPCInfoItem.ecgResult : _curDLCInfoItem.innerData.ecgResultDescrib);
//    if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
//        NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
//        description = [NSString stringWithFormat:@"%@ %@", strArr[0],strArr[1]];
//    } else { //只有一条描述
//    }
//    _ecgStrResult.text = description;
    
    if (_curSPCInfoItem.isNoHR && isSpc) {
         _hr.text = @"--";
//        _ecgStrResult.text = DTLocalizedString(@"ECG not applicable", nil);
        _ecgStrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    
//    _ecgImgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex: (isSpc ? _curSPCInfoItem.enECG_PassKind : _curDLCInfoItem.ECG_R)]];

    if ([_ecgStrResult.text isEqualToString:@"Unable to analyze, review manual and retry"] && !isSpc) {
        _ecgStrResult.font = [UIFont systemFontOfSize:12];
        _ecgStrResult.numberOfLines = 0;
        CGRect frame = _ecgStrResult.frame;
        frame.origin.y -= 7;
        frame.size.height += 10;
        _ecgStrResult.frame = frame;
    }
    if (_curSPCInfoItem.isNoHR && isSpc) {  //如果没有测量HR
        _hr.text = @"--";
//        _qrs.text = @"--";
//        _ecgStrResult.text = DTLocalizedString(@"ECG not applicable", nil);
        _ecgStrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
        _ecgImgResult.image = nil;
    }
    
    //spo2
    _spo2.text = INT_TO_STRING_WITHOUT_ERR_NUM((isSpc ? _curSPCInfoItem.oxi : _curDLCInfoItem.SPO2));
//    _pi.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM((isSpc ? _curSPCInfoItem.PI : _curDLCInfoItem.PI));
    
    
    int spoValue = [[NSString stringWithFormat:@"%d",_curDLCInfoItem.SPO2] intValue];
    
    if (spoValue == 0) {
        _spo2.text = @"--";
        _spo2StrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    
    else if( 0 < spoValue && spoValue < 60)
    {
        _spo2StrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
        
    }
    else if( 60 <= spoValue && spoValue <= 93)
    {
        _spo2StrResult.text = DTLocalizedString(@"Blood oxygen: Out of range", nil);
        
    }
    else {
        
        _spo2StrResult.text = DTLocalizedString(@"Blood oxygen: Within range", nil);
    }

    if ([_spo2StrResult.text isEqualToString:@"Unable to analyze, review manual and retry"] && !isSpc) {
        _spo2StrResult.font = [UIFont systemFontOfSize: kScreenHeight > 500?14:13];
        _spo2StrResult.numberOfLines = 0;
//        CGRect frame = _spo2StrResult.frame;
//        frame.origin.y -= 9;
//        frame.size.height += 10;
//        _spo2StrResult.frame = frame;
    }
    
//    _spo2StrResult.text = [STR_RESULT_ARRAY objectAtIndex:(isSpc ? _curSPCInfoItem.oxi_R : _curDLCInfoItem.SPO2_R)];
//    _spo2ImgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex: (isSpc ? _curSPCInfoItem.enOxi_PassKind : _curDLCInfoItem.SPO2_R)]];
    if (isSpc) {
        if (_curSPCInfoItem.isNoOxi) { //没有测量血氧
            _spo2.text = @"--";
            _pi.text = @"--";
//            _spo2StrResult.text = DTLocalizedString(@"Spo2 not applicable", nil);
            _spo2StrResult.text = DTLocalizedString(@"Unable to Analyze", nil);
            _spo2ImgResult.image = nil;
        }
    }
    
    //显示声音图标
    _tempVoiceBtn.hidden = YES;  //隐藏声音的按钮图标
//    UIImage *voiceImg;
//    if (isSpc) {
//        if (_curSPCInfoItem.bHaveVoiceMemo) {
//            _tempVoiceBtn.hidden = NO;
//            if (isLocalVoiceExisted) {
//                voiceImg = [UIImage imageNamed:@"voice.png"];
//            }else {
//                voiceImg = [UIImage imageNamed:@"voice_gray.png"];
//            }
//            [_tempVoiceBtn setBackgroundImage:voiceImg forState:UIControlStateNormal];
//            [_tempVoiceBtn addTarget:self action:@selector(willPlayVoice) forControlEvents:UIControlEventTouchUpInside];
//            
//        } else {
//            _tempVoiceBtn.hidden = YES;
//        }
//        
//    } else {
//        if (_curDLCInfoItem.bHaveVoiceMemo){
//            if (isLocalVoiceExisted == YES) {
//                voiceImg = [UIImage imageNamed:@"voice.png"];
//            }else {
//                voiceImg = [UIImage imageNamed:@"voice_gray.png"];
//            }
//            [_bpReVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
//            [_bpReVoice addTarget:self action:@selector(willPlayVoice) forControlEvents:UIControlEventTouchUpInside];
//            
//            [_bpAbsVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
//            [_bpAbsVoice addTarget:self action:@selector(willPlayVoice) forControlEvents:UIControlEventTouchUpInside];
//            
//            [_imageVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
//            [_imageVoice addTarget:self action:@selector(willPlayVoice) forControlEvents:UIControlEventTouchUpInside];
//        }
//    }

    [self setBPStr];
}


//设置BP结果
-(void)setBPStr
{
    if (isSpc) {
        _tempView.hidden = NO;
        if (_curSPCInfoItem.isNoTemp) {  //如果没有测量体温
            CGRect frame = _tempLabel.frame;
            frame.size.width = CUR_SCREEN_W;
            _tempLabel.frame = frame;
            _tempLabel.text = DTLocalizedString(@"Temperature not applicable", nil);
            _tempLabel.font = [UIFont systemFontOfSize:17];
            _tempFaceImg.hidden = YES;
            _tempValue.hidden = YES;
            _tempUnit.hidden = YES;
        } else {
            _tempFaceImg.hidden = NO;
            _tempValue.hidden = NO;
            _tempUnit.hidden = NO;
            _tempFaceImg.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex: _curSPCInfoItem.enTemp_PassKind]];
            
            double temp = _curSPCInfoItem.temp/10.0;
            //温度转换 摄氏度转华氏度  ℉
            NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Termometer"];
            if (!index) {
                index = 0;
            }
            if (index == 0) {
                _tempValue.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(temp);
                _tempUnit.text = @"℃";
            } else if (index == 1){
                double F = temp *1.8 + 32;
                if (temp == 0.0) {
                    F = 0.0;
                }
                _tempValue.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(F);
                _tempUnit.text = @"℉";
            }
        }
        
    } else {
        _bgLJnewView.hidden = NO;
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
////         [userDefaults setInteger:_curUser.ID forKey:@"curUserID"];
//        int urseId = [[userDefaults objectForKey:@"curUserID"] integerValue];
        
       
        
        _lableSbpValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCInfoItem.BP);
        _lableRppValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curDLCInfoItem.RPP);
 
        if(_curDLCInfoItem.BP_Flag == 0)
        {
            _labmmHg.text = @"%";
            _lableSbpValue.text = [NSString stringWithFormat:@"%d",_curDLCInfoItem.BP] ;
            
        }
        else if(_curDLCInfoItem.BP_Flag == -1 || _curDLCInfoItem.BP_Flag == 255)
        {
            
            //确定chart类型
            for (BPCheckItem *item in _curUser.arrBPCheck) {
                if (item.userID == _curUser.ID) {//有校准(re或abs)
                    
                    if (item.rPresure==0||item.cPresure==0) {//re
                        _labmmHg.text = @"%";
                        
                    }
                    else{//abs
                        _labmmHg.text = @"mmHg";
                    }
                }
            }
            
            
        }
        else
        {
            
               _labmmHg.text = @"mmHg";
        }
        
        
        
        if (_curUser.ID  == 1) {
            
            _lableSbpValue.text = @"--";
            _lableSbpValue.text = @"--";
            _labmmHg.text = @" ";
//            _labRPPResult.text = @"Not available for Guest";
            _labRPPResult.text = @"";

        }
        else
        {
            
            int rppValue = [[NSString stringWithFormat:@"%d",_curDLCInfoItem.RPP] intValue];
            
            if (rppValue == 0) {
                //                _lableRppValue.text = @"--";
                //                _lableSbpValue.text = @"--";
                //                _labRPPResult.text = DTLocalizedString(@"Unable to Analyze", nil);
                _labRPPResult.text = @"";
            }
            
            else if( 0 < rppValue && rppValue < 3000)
            {
                //                _labRPPResult.text =  DTLocalizedString(@"Unable to Analyze", nil);
                _labRPPResult.text = @"";
                
            }
            else if( 3000 <= rppValue && rppValue <= 5400) //Rate Pressure Product
            {
                _labRPPResult.text = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Below range", nil):DTLocalizedString(@"RPP: Below range", nil) ;
                
            }
            else if( 5400 < rppValue && rppValue <= 12000)
            {
                _labRPPResult.text = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Medium range", nil):DTLocalizedString(@"RPP: Medium range", nil) ;
                
            }
            else if( 12000 < rppValue && rppValue <= 20000)
            {
                _labRPPResult.text = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: High range", nil) :DTLocalizedString(@"RPP: High range", nil) ;
                
            }
            else {
                
                _labRPPResult.text = kScreenHeight > 500?DTLocalizedString(@"Rate Pressure Product: Above  range", nil) :DTLocalizedString(@"RPP: Above  range", nil) ;
            }
            
            if ([_labRPPResult.text isEqualToString:@"Unable to analyze, review manual and retry"] && !isSpc) {
                _labRPPResult.font = [UIFont systemFontOfSize: kScreenHeight > 500?14:13];
                _labRPPResult.numberOfLines = 0;
                //        CGRect frame = _spo2StrResult.frame;
                //        frame.origin.y -= 9;
                //        frame.size.height += 10;
                //        _spo2StrResult.frame = frame;
            }
            
            
            
            
        }
        

        
        
        
//        _BPstrArr = [NSMutableArray array];
//        for (BPCheckItem *item in _curUser.arrBPCheck) {   // 从BPCheck中找值
//            if (item.userID == _curUser.ID) {//有校准(re或abs)
//                if (item.rPresure==0||item.cPresure==0) {//为re
//                    if (_curDLCInfoItem.BP_Flag==0) {//Re有效
//                        _bpReView.hidden = NO;
//                        _bpReValue.text = [NSString stringWithFormat:@"%@%@",(_curDLCInfoItem.BP>=0?(@"+"):@""),INT_TO_STRING(_curDLCInfoItem.BP)];  //第一个值确定正负号，第二个是bp的实际值
//                        _bpReResult.text = [NSString stringWithFormat:DTLocalizedString(@"refer to %@", nil), [NSDate engDescOfDateComp:item.dtcDate][1]];   //参考日期
//                        
//                        NSString *str0 = @"re";
//                        NSString *str1 = _bpReValue.text;
//                        NSString *str2 = _bpReResult.text;
//                        if (!self.BPstrArr.count == 0) {
//                            [self.BPstrArr removeAllObjects];
//                        }
//                        [self.BPstrArr addObject:str0];
//                        [self.BPstrArr addObject:str1];
//                        [self.BPstrArr addObject:str2];
//                    }else{
//                        //只要无效值就什么都不显示
//                    }
//                }else{//为abs
//                    if(_curDLCInfoItem.BP_Flag!=0xFF){//abs有效
//                        _bpAbsView.hidden = NO;
//                        _bpAbsValue.text = INT_TO_STRING_WITHOUT_ERR_NUM(self.curDLCInfoItem.BP);     //mmHg的值
//                        _bpAbsResult.text = [NSString stringWithFormat:@"- %@", _curUser.name];     //收缩压后面那个字符串 表示当前测试者的名子
//                        
//                        NSString *str0 = @"abs";
//                        NSString *str1 = _bpAbsValue.text;
//                        NSString *str2 = _bpAbsResult.text;
//                        if (!self.BPstrArr.count == 0) {
//                            [self.BPstrArr removeAllObjects];
//                        }
//                        [self.BPstrArr addObject:str0];
//                        [self.BPstrArr addObject:str1];
//                        [self.BPstrArr addObject:str2];
//                    }else{  //abs无效
//                        //只要无效值就什么都不显示
//                    }
//                }
//            } else{
//                //无校准
//            }
//        }
        
    }
}

//添加ECG波形
-(void)addECGWave
{
    UIScrollView *sclv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _waveView.frame.size.width, _waveView.frame.size.height)];
    sclv.backgroundColor = [UIColor clearColor];
    
    //只显示4行，剩下的滑入
    double ecgLineH = _waveView.frame.size.height/4;
    //每行5秒，自动适应总长度
    if (isSpc) {
        if (_curSPCInfoItem.innerData) {  //如果有HR
            _ecgWave = [[ECGWave alloc] initWithFrame:CGRectMake(0, 0, _waveView.frame.size.width,  ecgLineH*_curSPCInfoItem.innerData.timeLength/5.0) xUser:_curXuser spcItem:_curSPCInfoItem callerType:0 delegate:self];
        } else { // 如果没有
            _waveView.backgroundColor = COLOR_RGB(239,239,239,1.0);
            UILabel *noDataL = [[UILabel alloc] initWithFrame:CGRectMake(0, _waveView.bounds.size.height*0.5-50*0.5, CUR_SCREEN_W, 50.0f)];
            noDataL.font = [UIFont systemFontOfSize:30];
            if ([curLanguage isEqualToString:@"ja"]) {
                noDataL.font = [UIFont systemFontOfSize:20];;
            }
            noDataL.alpha = 0.6;
            noDataL.textAlignment = NSTextAlignmentCenter;
            noDataL.text = DTLocalizedString(@"No data", nil);
            [_waveView addSubview:noDataL];
            sclv.hidden = YES;
        }

    }else {
        _ecgWave = [[ECGWave alloc] initWithFrame:CGRectMake(0, 0, _waveView.frame.size.width,  ecgLineH*_curDLCInfoItem.innerData.timeLength/5.0) user:_curUser ecgItem:(ECGInfoItem *)_curDLCInfoItem callerType:0 delegate:self];
    }
    NSString *DeviceStr = [DeviceVersionUtils getDeviceVersion];
    sclv.contentSize = CGSizeMake(_ecgWave.frame.size.width, _ecgWave.frame.size.height + ([DeviceStr hasPrefix:@"iPad"]? 90 : 0));
    
    [sclv addSubview:_ecgWave];
    [_waveView addSubview:sclv];
}


//导航栏分享
- (IBAction)onShareButtonClicked:(id)sender
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Choose a way to share", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Save to Album", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                              UIImage *image = nil;
                              if (isSpc) {
                                  DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andXuser:_curXuser andSpcInfoItem:_curSPCInfoItem andWaveType:@"SPC_Wave"];
                                  image = [albumV captureView];
                              } else {
                                  DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andUser:_curUser andEcgInfoItem:(ECGInfoItem *)_curDLCInfoItem andWaveType:@"DailyCheck" andBPType:self.BPstrArr];
                                  image = [albumV captureView];
                              }
                              
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

                          }];
    [alertView addButtonWithTitle:DTLocalizedString(@"Share", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                              UIImage *image = nil;
                              NSString *msgBody = nil;
                              if (isSpc) {
                                  DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andXuser:_curXuser andSpcInfoItem:_curSPCInfoItem andWaveType:@"SPC_Wave"];
                                  image = [albumV captureView];
                                  msgBody = [NSString stringWithFormat:DTLocalizedString(@"PatientID:%@  Name:%@\nMeasure Time:%@\nMeasurement:%@\nReports:See file attached\n", nil),_curXuser.patient_ID,_curXuser.name,[NSDate engDescOfDateComp:_curSPCInfoItem.dtcDate][2],DTLocalizedString(@"Spot Check", nil)];
                              } else {
                                  DlcEcgAlbumView *albumV = [[DlcEcgAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andUser:_curUser andEcgInfoItem:(ECGInfoItem *)_curDLCInfoItem andWaveType:@"DailyCheck" andBPType:self.BPstrArr];
                                  image = [albumV captureView];
                                  msgBody = [NSString stringWithFormat:DTLocalizedString(@"Name:%@\nMeasure Time:%@\nMeasurement:%@\nReports:See file attached\n", nil),_curUser.name,[NSDate engDescOfDateComp:_curDLCInfoItem.dtcDate][2],DTLocalizedString(@"Daily Check", nil)];
                              }
    
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImage *img = [UIImage imageWithData:imageData];
                              
                              [self shareByActivity:img shareText:msgBody];
                          }];
#warning 点击 取消按钮 Cancel   hjzXx
    [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];

}

//保存图片失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){//失败
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Save failed, please check your system's privacy settings.", nil) duration:3];
    }
    else{//成功
        [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Save succeeded", nil)];
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


//选中波形
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
    
    
    ECGDetailWave *waveDetail;
    if (isSpc) {
        waveDetail = [[ECGDetailWave alloc] initWithMinFrame:CGRectMake(0, 0, sclv.frame.size.width, sclv.frame.size.height) spcInnerData:_curSPCInfoItem.innerData];
    }else {
        waveDetail = [[ECGDetailWave alloc] initWithMinFrame:CGRectMake(0, 0, sclv.frame.size.width, sclv.frame.size.height) ecgInnerData:_curDLCInfoItem.innerData];
    }
    
    sclv.contentSize = waveDetail.frame.size ;
    _ecgDetailWave = waveDetail;
    [sclv addSubview: waveDetail];
    CGRect rect = [waveDetail rectForDisplayStart:startSecond end:endSecond fatherViewFrame:sclv.frame];
    [sclv scrollRectToVisible:rect animated:NO];
    [viewDetailWave addSubview:sclv];
    
    
    
    UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 44)];
    [btnOK setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    btnOK.transform = CGAffineTransformMakeRotation(M_PI/2);
    btnOK.frame = CGRectMake(viewDetailWave.frame.size.width - btnOK.frame.size.width, 0, btnOK.frame.size.width, btnOK.frame.size.height);
    [btnOK addTarget:self action:@selector(onDetailWave_OK:) forControlEvents:UIControlEventTouchUpInside];
    [viewDetailWave addSubview:btnOK];
    
    [self.view addSubview: viewDetailWave];
    [self.view bringSubviewToFront:viewDetailWave];
    _viewDetailWave = viewDetailWave;
    
}

//退出ECG详情
-(void)onDetailWave_OK:(id)sender
{
    if(_viewDetailWave.superview == self.view)
        [_viewDetailWave removeFromSuperview];
    _viewDetailWave = nil;
    _ecgDetailWave = nil;
    [self showBars];
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

//下载和播放录音
-(void)willPlayVoice
{
    if (isSpc) {
        if (_curSPCInfoItem.bHaveVoiceMemo) {
            //打开本地文件
            NSString *fileName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][1]];
            NSData *fileData = [FileUtils readFile:fileName inDirectory:curDirName];
            _curSPCInfoItem.dataVoice = [fileData mutableCopy];
            if(!_curSPCInfoItem.dataVoice)
            {
                if ([AppDelegate GetAppDelegate].isOffline) {
                    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
                }else{
                    if(!_curSPCInfoItem.bDownloadIng)
                    {
                        [_curSPCInfoItem beginDownloadVoice];
                    }
                }
            }else {
                [self palyVoiceWithData : _curSPCInfoItem.dataVoice];
            }
        }
        
    }else {
        if (_curDLCInfoItem.bHaveVoiceMemo) {
            //打开本地文件
            NSString *fileName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][1]];
            NSData *fileData = [FileUtils readFile:fileName inDirectory:curDirName];
            _curDLCInfoItem.dataVoice = [fileData mutableCopy];
            if(!_curDLCInfoItem.dataVoice)
            {
                if ([AppDelegate GetAppDelegate].isOffline) {
                    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not download in Offline mode", nil) duration:2];
                }else{
                    if(!_curDLCInfoItem.bDownloadIng)
                    {
                        [_curDLCInfoItem beginDownloadVoice];
                    }
                }
            }else {
                [self palyVoiceWithData : _curDLCInfoItem.dataVoice];
            }

        }
    }
}

//录音下载进度更新
- (void)onDlcDetailDataDownloadProgress:(double)progress
{
    if (!_progressView) {
        _imageVoice.hidden = YES;
        _bpAbsVoice.hidden = YES;
        _bpReVoice.hidden = YES;
        
        if (isSpc) {
            _tempVoiceBtn.hidden = YES;
            CGRect bond = _tempVoiceBtn.frame;
            _progressView = [[UAProgressView alloc] initWithFrame:bond];
            [_progressView setBackgroundColor:[UIColor clearColor]];
            [_tempView addSubview:_progressView];
        } else {
            CGRect bond = _imageVoice.frame;
            _progressView = [[UAProgressView alloc] initWithFrame:bond];
            [_progressView setBackgroundColor:[UIColor clearColor]];
            [_dataResultView addSubview:_progressView];
        }
    }
    [_progressView setProgress:progress animated:YES];
}

//录音下载超时
- (void)onDlcDetailDataDownloadTimeout
{
    [_progressView removeFromSuperview];
    
    _imageVoice.hidden = NO;
    _bpAbsVoice.hidden = NO;
    _bpReVoice.hidden = NO;
    _tempVoiceBtn.hidden = NO;
}

//录音下载完成
- (void)onDlcDetailDataDownloadSuccess:(FileToRead *)fileData
{
    [_progressView removeFromSuperview];
    
    UIImage *voiceImg = [UIImage imageNamed:@"voice.png"];

    //通知前面页面cell刷新
    if (isSpc) {
    
        _tempVoiceBtn.hidden = NO;
        [_tempVoiceBtn setBackgroundImage:voiceImg forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSPCInfoItem.dtcDate][1]];
        // 把录音存储到本地
        NSMutableData *data = fileData.fileData;
        [FileUtils saveFile:fileName FileData:data withDirectoryName:curDirName];
        
        if(_curSPCInfoItem.dataVoice.length > 0)
            [self palyVoiceWithData : _curSPCInfoItem.dataVoice];
    }else {
        
        _curDLCInfoItem.dlcDelegate = nil;
        _imageVoice.hidden = NO;
        [_imageVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
        _bpAbsVoice.hidden = NO;
        [_bpAbsVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
        _bpReVoice.hidden = NO;
        [_bpReVoice setBackgroundImage:voiceImg forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:DLC_VOICE_DATA_USER_TIME_FILE_NAME, _curUser.medical_id, [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curDLCInfoItem.dtcDate][1]];
        // 存储到本地
        NSMutableData *data = fileData.fileData;
        [FileUtils saveFile:fileName FileData:data withDirectoryName:curDirName];
        
        if(_curDLCInfoItem.dataVoice.length > 0)
            [self palyVoiceWithData : _curDLCInfoItem.dataVoice];
    }
}

//播放录音
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
