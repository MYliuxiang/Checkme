//
//  AlbumView.m
//  Checkme Mobile
//
//  Created by Lq on 14-12-29.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "DlcEcgAlbumView.h"
#import "DlcReportInfoData.h"
#import "ECGReportInfoData.h"
#import "SPCReportInfoData.h"
#import "AlbumHeader.h"
#import "NSDate+Additional.h"
#import "PublicMethods.h"

@interface DlcEcgAlbumView ()
@property (nonatomic, strong) DlcReportInfoData *dlcInfoView;
@property (nonatomic, strong) ECGReportInfoData *ECGInfoView;
@property (nonatomic, strong) SPCReportInfoData *SpcInfoView;

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) Xuser *curXuser;
@property (nonatomic,retain) ECGInfoItem *ecgInfoItem;
@property (nonatomic,retain) SpotCheckItem *spcInfoItem;
// 用来区分是dlc波形还是ecg波形  还是spc波形
@property (nonatomic, copy) NSString *waveType;
@property (nonatomic) BOOL isSpc;
@end

@implementation DlcEcgAlbumView
{
    //  边框4个点
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    CGPoint point4;
}


//
- (id) initWithFrame:(CGRect)frame andUser:(User *)user andEcgInfoItem:(ECGInfoItem *)ecgInfoItem andWaveType:(NSString *)waveType andBPType:(NSArray *)bpArr
{
    self = [super initWithFrame:frame];
    if (self) {
    
        _isSpc = NO;
        _waveType = waveType;
        _curUser = user;
        _ecgInfoItem = ecgInfoItem;
        
        UILabel *report = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding*0.5, padding*2.0, padding*0.5)];
        report.text = DTLocalizedString(@"Report", nil);
        report.textAlignment = NSTextAlignmentLeft;
        report.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:report];
        //logo
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(whole_width - 2.5*padding, padding*0.5, 1.5*padding, padding*0.5)];
        UIImage *logo = [UIImage imageNamed:@"BM logo 2.jpg"];
//        if ([curCountry isEqualToString:@"JP"] && [curLanguage isEqualToString:@"ja"]) {   //如果是日本的
//            logo = [UIImage imageNamed:@"sanrong_logo.png"];
//        }
//        if (isThomson == YES) {  //如果是法国定制版
//            logo = [UIImage imageNamed:@"thomson_logo1.png"];
//        }
//        if (isSemacare == YES) {
//            logo = [UIImage imageNamed:@"semacare_logo1.png"];
//        }
        
        
        imageV.image = logo;
        [self addSubview:imageV];
        
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;
        
        // 属性值
        // date/time
        NSArray *dateArr = [NSDate engDescOfDateComp:_ecgInfoItem.dtcDate];
        NSString *date_time = [NSString stringWithFormat:@"%@ %@", dateArr[0], dateArr[1]];
        //  date/birth
        NSArray *birthArr = [NSDate engDescOfDateComp:_curUser.dtcBirthday];
        NSString *date_birthday = [NSString stringWithFormat:@"%@", birthArr[1]];
        //  other
        NSString *name = _curUser.name;
        NSString *gender = _curUser.gender == kGender_Male?DTLocalizedString(@"Femal", nil):DTLocalizedString(@"Male", nil);
        NSString *HR = [INT_TO_STRING_WITHOUT_ERR_NUM(_ecgInfoItem.innerData.HR) stringByAppendingString:@"/min"];
//        NSString *QRS = [INT_TO_STRING_WITHOUT_ERR_NUM(_ecgInfoItem.innerData.QRS) stringByAppendingString:@"ms"];
        
        //ecg结果描述
//        NSString *description = ecgResultDescrib(_ecgInfoItem.innerData.ecgResultDescrib);
//        if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
//            NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
//            description = [NSString stringWithFormat:@"%@ %@", strArr[0],strArr[1]];
//        } else { //只有一条描述
//        }
        
       // ecg结果描述
        NSString *description;
        int hrValue = [[NSString stringWithFormat:@"%d",_ecgInfoItem.innerData.HR] intValue];
        
        if (hrValue < 30) {
            description = DTLocalizedString(@"Unable to Analyze", nil);
        }
        
        else if( 30 <= hrValue && hrValue < 50)
        {
            description = DTLocalizedString(@"Heart rate: Low range",nil);
            
        }
        else if( 50 <= hrValue && hrValue <= 100)
        {
            description = DTLocalizedString(@"Heart rate: Medium range",nil);
            
        }
        else if( 100 < hrValue && hrValue < 150)
        {
            description = DTLocalizedString(@"Heart rate: High range",nil);
            
        }
        else {
            
            description =DTLocalizedString( @"Heart rate: Out of range",nil);
        }
        
        
        
        
        // 区分波形
        if ([_waveType isEqualToString:@"DailyCheck"]) {   //如果是dlc的波形
            
            _dlcInfoView = [[[NSBundle mainBundle] loadNibNamed:@"DlcReportInfoData" owner:self options:nil] lastObject];
            CGRect rect = _dlcInfoView.frame;
            rect.origin.x = padding;
            rect.origin.y = padding;
            _dlcInfoView.frame = rect;
            [self addSubview:_dlcInfoView];
            
            //  初始化用户数据
            //  设置BP结果
            if (![name isEqualToString:@"Guest"]) {  //不是Guest
                //  删除横线
                [_dlcInfoView.usrName removeFromSuperview];
                [_dlcInfoView.usrGender removeFromSuperview];
                [_dlcInfoView.usrDateBirth removeFromSuperview];
                
                //初始化其他数据
                _dlcInfoView.Name.text = name;
                _dlcInfoView.Gender.text = gender;
                _dlcInfoView.DateBirth.text = date_birthday;
                
            DailyCheckItem *DLCItem = (DailyCheckItem *)_ecgInfoItem;
            int rppValue = [[NSString stringWithFormat:@"%d",DLCItem.RPP] intValue];
            
            _dlcInfoView.RPP.text = INT_TO_STRING_WITHOUT_ERR_NUM(DLCItem.RPP);;
            _dlcInfoView.BP.text =  [NSString stringWithFormat:@"%@ mmHg",INT_TO_STRING_WITHOUT_ERR_NUM(DLCItem.BP)];
                
                
                if(DLCItem.BP_Flag == 0)
                {
                     _dlcInfoView.BP.text =  [NSString stringWithFormat:@"%d %@",DLCItem.BP,@"%"];
                   
                    
                }
                else if(DLCItem.BP_Flag == -1 || DLCItem.BP_Flag == 255)
                {
                    
                    //确定chart类型
                    for (BPCheckItem *item in _curUser.arrBPCheck) {
                        if (item.userID == _curUser.ID) {//有校准(re或abs)
                            
                            if (item.rPresure==0||item.cPresure==0) {//re
                              
                                _dlcInfoView.BP.text =  [NSString stringWithFormat:@"%@ %@",INT_TO_STRING_WITHOUT_ERR_NUM(DLCItem.BP),@"%"];
                            }
                            else{//abs
                                _dlcInfoView.BP.text =  [NSString stringWithFormat:@"%@ mmHg",INT_TO_STRING_WITHOUT_ERR_NUM(DLCItem.BP)];
                              
                            }
                        }
                    }
                    
                    
                }
                
                

                
                
            if (rppValue == 0) {
//                _dlcInfoView.RPP.text = @"--";
//                _dlcInfoView.BP.text = @"-- mmHg";
//                _dlcInfoView.RPPSatur.text = DTLocalizedString(@"Unable to Analyze", nil);
                  _dlcInfoView.RPPSatur.text = @"";
            }
            
            else if( 0 < rppValue && rppValue < 3000)
            {
//                 _dlcInfoView.RPPSatur.text =  DTLocalizedString(@"Unable to Analyze", nil);
                _dlcInfoView.RPPSatur.text = @"";
                
            }
            else if( 3000 <= rppValue && rppValue <= 5400)
            {
                 _dlcInfoView.RPPSatur.text = DTLocalizedString(@"Rate Pressure Product: Below range", nil) ;
                
            }
            else if( 5400 < rppValue && rppValue <= 12000)
            {
                 _dlcInfoView.RPPSatur.text =DTLocalizedString(@"Rate Pressure Product: Medium range", nil) ;
                
            }
            else if( 12000 < rppValue && rppValue <= 20000)
            {
                _dlcInfoView.RPPSatur.text =DTLocalizedString(@"Rate Pressure Product: High range", nil) ;
                
            }
            else {
                
                 _dlcInfoView.RPPSatur.text =DTLocalizedString(@"Rate Pressure Product: Above  range", nil) ;
            }
               
       
    
                
                
//                if (bpArr.count != 0) {  //BP有设置
//                    NSString *str0 = [bpArr objectAtIndex:0];
//                    NSString *str1 = [bpArr objectAtIndex:1];
//                    NSString *str2 = [bpArr objectAtIndex:2];
//                    if ([str0 isEqualToString:@"re"]) {  // re
//                        _dlcInfoView.BP.text = [[NSString stringWithFormat:@"BP  %@%@", str1,@"%"] stringByAppendingFormat:@"   %@", str2];  //str1 str2为前面界面拿过来的值，故不用进行本地化处理  BP不需本地化处理
//                    }else if ([str0 isEqualToString:@"abs"]) {  //abs
//                        NSString *s = [NSString stringWithFormat:@"%@ mmHg", str1];
//                        _dlcInfoView.BP.text = [[NSString stringWithFormat:DTLocalizedString(@"BPsys - %@", nil), name] stringByAppendingFormat:@"  %@",s];
//                    }
//                } else if (bpArr.count == 0) { //无任何BP设置
//                    _dlcInfoView.BP.text = [@"BP --" stringByAppendingFormat:@" %@",DTLocalizedString(@"No BP calibration", nil)];
//                }
            } else {  //是Guest
                _dlcInfoView.RPP.text = @"--";
                _dlcInfoView.BP.text = @"--";
//                _dlcInfoView.RPPSatur.text = @"Not available for Guest";
                _dlcInfoView.RPPSatur.text = @"";
            }
            
            
            _dlcInfoView.MesuringMode.text = DTLocalizedString(@"Daily Check", nil);
            _dlcInfoView.dateTime.text = date_time;
            _dlcInfoView.HeartRate.text = HR;
//            _dlcInfoView.QRS.text = QRS;
            _dlcInfoView.ECG.text = description;
            
            DailyCheckItem *DLCItem = (DailyCheckItem *)_ecgInfoItem;
            //            _dlcInfoView.pi.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(DLCItem.PI);
//             _dlcInfoView.oxySatur.text = [STR_RESULT_ARRAY objectAtIndex:DLCItem.SPO2_R];
            
            _dlcInfoView.spo2.text = [INT_TO_STRING_WITHOUT_ERR_NUM(DLCItem.SPO2) stringByAppendingString:@"%"];
            
            int spoValue = [[NSString stringWithFormat:@"%d",DLCItem.SPO2] intValue];
            
            if (spoValue == 0) {
                 _dlcInfoView.spo2.text = @"-- %";
                 _dlcInfoView.oxySatur.text = DTLocalizedString(@"Unable to Analyze", nil);
            }
            
            else if( 0 < spoValue && spoValue < 60)
            {
               _dlcInfoView.oxySatur.text = DTLocalizedString(@"Unable to Analyze", nil);
                
            }
            else if( 60 <= spoValue && spoValue <= 93)
            {
                _dlcInfoView.oxySatur.text = DTLocalizedString( @"Blood oxygen: Out of range",nil);
                
            }
            else {
                
                _dlcInfoView.oxySatur.text = DTLocalizedString( @"Blood oxygen: Within range",nil);
            }
            
            

           

        } else if ([_waveType isEqualToString:@"ECG_Wave"]){      //如果是ECG波形
            
            _ECGInfoView = [[[NSBundle mainBundle] loadNibNamed:@"ECGReportInfoData" owner:self options:nil] lastObject];
            CGRect rect = _ECGInfoView.frame;
            rect.origin.x = padding;
            rect.origin.y = padding;
            _ECGInfoView.frame = rect;
            [self addSubview:_ECGInfoView];
            
            //  ST值
//            NSString *st = @"";
//            if (_ecgInfoItem.enLeadKind == kLeadKind_Hand || _ecgInfoItem.enLeadKind == kLeadKind_Chest) {
//                _ECGInfoView.stLabel.text = @""; //st标签为空
//                st = @""; //值为空
//            } else {
//                if (_ecgInfoItem.enPassKind == kPassKind_Others) {
//                    st = [NSString stringWithFormat:@"-- mV"];
//                }else {
//                    st = [NSString stringWithFormat:@"%@%@", (_ecgInfoItem.innerData.ST >= 0 ? (@"+") : @""), DOUBLE2_TO_STRING(((double)_ecgInfoItem.innerData.ST)/100.0)];
//                }
//            }
//            
            //初始化用户数据
            _ECGInfoView.MesuringMode.text = DTLocalizedString(@"ECG Recorder", nil);
            _ECGInfoView.DateTime.text = date_time;
            _ECGInfoView.HeartRate.text = HR;
//            _ECGInfoView.QRS.text = QRS;
//            _ECGInfoView.ST.text = st;
            _ECGInfoView.Description.text = description;
//            _ECGInfoView.mesureImage.image = [UIImage imageNamed:[IMG_LEAD_ARRAY objectAtIndex:(_ecgInfoItem.enLeadKind-1)]];
        }
    }
    return self;
}

//spotCheck
- (id) initWithFrame:(CGRect)frame andXuser:(Xuser *)xUser andSpcInfoItem:(SpotCheckItem *)spcInfoItem andWaveType:(NSString *)waveType
{
    self = [super initWithFrame:frame];
    if (self) {
        _isSpc = YES;
        _waveType = waveType;
        _curXuser = xUser;
        _spcInfoItem = spcInfoItem;
        
        UILabel *report = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding*0.5, padding*2.0, padding*0.5)];
        report.text = DTLocalizedString(@"Report", nil);
        report.textAlignment = NSTextAlignmentLeft;
        report.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:report];
        //logo
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(whole_width - 2.5*padding, padding*0.5, 1.5*padding, padding*0.5)];
        UIImage *logo = [UIImage imageNamed:@"BM logo 2.jpg"];
//        if ([curCountry isEqualToString:@"JP"] && [curLanguage isEqualToString:@"ja"]) {   //如果是日本的
//            logo = [UIImage imageNamed:@"BM logo 2.jpg"];
//        }
//        if (isThomson == YES) {  //如果是法国定制版
//            logo = [UIImage imageNamed:@"thomson_logo1.png"];
//        }
//        if (isSemacare == YES) {
//            logo = [UIImage imageNamed:@"semacare_logo1.png"];
//        }
        
        imageV.image = logo;  //设置图标logo
        [self addSubview:imageV];
        
        self.backgroundColor = [UIColor whiteColor];//白色背景色
        self.opaque = NO;
        
        _SpcInfoView = [[[NSBundle mainBundle] loadNibNamed:@"SPCReportInfoData" owner:self options:nil] lastObject];
        CGRect rect = _SpcInfoView.frame;
        rect.origin.x = padding;
        rect.origin.y = padding;
        _SpcInfoView.frame = rect;
        [self addSubview:_SpcInfoView];
        
        _SpcInfoView.patientID.text = _curXuser.patient_ID;
        _SpcInfoView.nameL.text = _curXuser.name;
        _SpcInfoView.genderL.text = _curXuser.sex == 1 ? DTLocalizedString(@"Male", nil) : DTLocalizedString(@"Femal", nil);
        _SpcInfoView.ageL.text = [NSString stringWithFormat:@"%d", _curXuser.age];
        _SpcInfoView.modeL.text = DTLocalizedString(@"Spot Check", nil);
        _SpcInfoView.dateTime.text = [NSString stringWithFormat:@"%@ %@", [NSDate engDescOfDateComp:_spcInfoItem.dtcDate][0], [NSDate engDescOfDateComp:_spcInfoItem.dtcDate][1]];
        _SpcInfoView.hrL.text = [INT_TO_STRING_WITHOUT_ERR_NUM(_spcInfoItem.HR) stringByAppendingString:@"/min"];
        _SpcInfoView.qrsL.text = [INT_TO_STRING_WITHOUT_ERR_NUM(_spcInfoItem.QRS) stringByAppendingString:@"ms"];
        
        
        //ecg结果描述
        NSString *description = ecgResultDescrib(_spcInfoItem.ecgResult);
        if ([description rangeOfString:@"\r\n"].length > 0) {  //如果包含/r/n  即有两条描述
            NSArray *strArr = [description componentsSeparatedByString:@"\r\n"];
            description = [NSString stringWithFormat:@"%@ %@", strArr[0],strArr[1]];
        } else { //只有一条描述
        }
        _SpcInfoView.ecgL.text = description;
        if (_spcInfoItem.isNoHR) {
            _SpcInfoView.ecgL.text = DTLocalizedString(@"ECG not applicable", nil);
        }
        
        
        _SpcInfoView.spo2L.text = [INT_TO_STRING_WITHOUT_ERR_NUM(_spcInfoItem.oxi) stringByAppendingString:@"%"];
        _SpcInfoView.piL.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(_spcInfoItem.PI);
        
        //spo2
        _SpcInfoView.Spo2_R.text = [STR_RESULT_ARRAY objectAtIndex:_spcInfoItem.oxi_R];
        if (_spcInfoItem.isNoOxi) {
            _SpcInfoView.Spo2_R.text = DTLocalizedString(@"Spo2 not applicable", nil);
        }
        
        //  temp
        double temp = _spcInfoItem.temp/10.0;
        //温度转换 摄氏度转华氏度  ℉
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Termometer"];
        if (!index) {
            index = 0;
        }
        if (index == 0) {
            _SpcInfoView.tempL.text = [DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(temp) stringByAppendingString:@" ℃"];
        } else if (index == 1){
            double F = temp *1.8 + 32;
            if (temp == 0.0) {
                F = 0.0;
            }
            _SpcInfoView.tempL.text = [DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(F) stringByAppendingString:@" ℉"];
        }
        if (_spcInfoItem.isNoTemp) {
            _SpcInfoView.tempL.text = DTLocalizedString(@"Temperature not applicable", nil);
        }

        
    }
    return self;
}

//画外框
- (void) drawRectangle
{
    if ([_waveType isEqualToString:@"DailyCheck"]) {
        point1 = CGPointMake(padding, CGRectGetMaxY(_dlcInfoView.frame) + padding*0.5);
        point2 = CGPointMake(CGRectGetMaxX(_dlcInfoView.frame), point1.y);
    } else if ([_waveType isEqualToString:@"ECG_Wave"]) {
        point1 = CGPointMake(padding, CGRectGetMaxY(_ECGInfoView.frame) + padding*0.5);
        point2 = CGPointMake(CGRectGetMaxX(_ECGInfoView.frame), point1.y);
    } else if ([_waveType isEqualToString:@"SPC_Wave"]) {
        point1 = CGPointMake(padding, CGRectGetMaxY(_SpcInfoView.frame) + padding*0.5);
        point2 = CGPointMake(CGRectGetMaxX(_SpcInfoView.frame), point1.y);
    }
    point3 = CGPointMake(point2.x, whole_height - padding*0.5);
    
    // 去掉半格
    int y_y_space = point3.y-point1.y;
    int five_mm = 5*point_per_mm;
    if (y_y_space % five_mm != 0) {
        int index = (point3.y - point1.y)/five_mm;
        point3.y = index * 5*point_per_mm + point1.y;
    }
    point4 = CGPointMake(point1.x, point3.y);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point1];
    
    [[UIColor lightGrayColor] setStroke];
    path.lineWidth = thickLine;
    [path stroke];
}
//画细线
- (void) drawThinLines
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //纵细线
    for (float i = point1.x; i <= point2.x; i += point_per_mm) {
        CGPoint verticalPointStart = CGPointMake(i, point1.y);
        CGPoint verticalPointEnd = CGPointMake(verticalPointStart.x, point3.y);
        [path moveToPoint:verticalPointStart];
        [path addLineToPoint:verticalPointEnd];
    }
    //横细线
    for (float i = point1.y; i <= point4.y; i += point_per_mm) {
        CGPoint horizonPointStart = CGPointMake(point1.x, i);
        CGPoint horizonPointEnd = CGPointMake(point2.x, horizonPointStart.y);
        [path moveToPoint:horizonPointStart];
        [path addLineToPoint:horizonPointEnd];
    }
    
    path.lineWidth = thinLine;
    [[UIColor colorWithRed:255.0/255 green:210.0/255 blue:240.0/255 alpha:1.0] setStroke];
    [path stroke];
}
//画粗线
- (void) drawThickLines
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    //纵粗线
    for (float i = point1.x; i <= point2.x; i += 5 * point_per_mm) {
        CGPoint verticalPointStart = CGPointMake(i, point1.y);
        CGPoint verticalPointEnd = CGPointMake(verticalPointStart.x, point3.y);
        [path moveToPoint:verticalPointStart];
        [path addLineToPoint:verticalPointEnd];
    }
    //横粗线
    for (float i = point1.y; i <= point4.y; i += 5 * point_per_mm) {
        CGPoint horizonPointStart = CGPointMake(point1.x, i);
        CGPoint horizonPointEnd = CGPointMake(point2.x, horizonPointStart.y);
        [path moveToPoint:horizonPointStart];
        [path addLineToPoint:horizonPointEnd];
    }
    
    path.lineWidth = thickLine;
    [[UIColor colorWithRed:255.0/255 green:170.0/255 blue:220.0/255 alpha:1.0] setStroke];
    [path stroke];
}

//  常量
#define general_ms_per_val 1.0    //   传输协议中指定2ms给一个val点
#define ms_per_mm 40.0   // 心电图标准  1mm为40ms
#define mm_per_ms (1.0/40)    //1ms为1/40mm
//   1毫米为40ms 2ms一个val点 那么正常来说1毫米就有20个val点

//   自定义 取点
#define new_vals_per_mm 2.0    //  自定义每毫米放2个val点
#define multiples ((40/2)/new_vals_per_mm)    //抽点倍数        对于从数组取值来说 正常状态一次抽出一个点 现在一次抽出 multiples（目前为10） 个点   可创建新数组
#define points_per_val (point_per_mm / new_vals_per_mm)    //每个val点对应的point点
#define upper_limit 15 * point_per_mm //一行波形上限值为15毫米（3大格）   (单位:point)
#define lower_limit 10 * point_per_mm //一行波形下限值为10毫米（2大格）   (单位:point)

//画标尺
- (void) drawScaleplate
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint startPoint = CGPointMake(point1.x, point1.y + upper_limit);
    CGPoint Point2 = CGPointMake(startPoint.x + 5 * point_per_mm, startPoint.y);
    CGPoint Point3 = CGPointMake(Point2.x, point1.y + 5 * point_per_mm);
    CGPoint Point4 = CGPointMake(Point3.x + 5 * point_per_mm, Point3.y);
    CGPoint Point5 = CGPointMake(Point4.x, startPoint.y);
    CGPoint endPoint = CGPointMake(point1.x + 15 * point_per_mm, startPoint.y);
    [path moveToPoint:startPoint];
    [path addLineToPoint:Point2];
    [path addLineToPoint:Point3];
    [path addLineToPoint:Point4];
    [path addLineToPoint:Point5];
    [path addLineToPoint:endPoint];

    path.lineWidth = thickLine;
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    //标尺文字
    UILabel *mVlabel = [[UILabel alloc] initWithFrame:CGRectMake((whole_width-padding)-wave_width, point3.y, wave_width, 5 * point_per_mm)];
    NSString *waveWide = _isSpc ? @"" : [self waveWidth];
//    mVlabel.text = [@"10mm/mV 25mm/s  " stringByAppendingString:waveWide];
    mVlabel.text = @"10mm/mV 25mm/s";
    mVlabel.font = [UIFont systemFontOfSize:11];
    mVlabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:mVlabel];
}

#define filter_wide 1
#define filter_normal 0
- (NSString *)waveWidth    //计算带宽
{
    NSString *waveWidthStr = @"";
    U8 leadKind = _ecgInfoItem.innerData.enLeadKind;
    int filterKind;
    if (_ecgInfoItem.innerData.enFilterKind == kFilterKind_Normal) {
        filterKind = 0;
    } else {
        filterKind = 1;
    }
    
//    if (leadKind == kLeadKind_Chest || leadKind == kLeadKind_Hand) {
//        if (filterKind == filter_wide) {  //正常
//            waveWidthStr = @"0.57Hz - 21Hz";
//        }else if (filterKind == filter_normal) {   //加强
//            waveWidthStr = @"1.15Hz - 16Hz";
//        } else {
//            waveWidthStr = DTLocalizedString(@"Unknown bandwidth", nil);
//        }
//    }else if (leadKind == kLeadKind_Wire || leadKind == kLeadKind_Wire12) {
//        if (filterKind == filter_wide) {  //正常
//            waveWidthStr = @"0.05Hz - 41Hz";
//        }else if (filterKind == filter_normal) {   //加强
//            waveWidthStr = @"0.57Hz - 21 Hz";
//        } else {
//            waveWidthStr = DTLocalizedString(@"Unknown bandwidth", nil);
//        }
//    }else {
//        waveWidthStr = DTLocalizedString(@"Unknown bandwidth", nil);
//    }
    
    if (filterKind == filter_wide) {
        waveWidthStr = [DTLocalizedString(@"bandwidth", nil) stringByAppendingString:DTLocalizedString(@"Wide", nil)];
    } else if (filterKind == filter_normal){
        waveWidthStr = [DTLocalizedString(@"bandwidth", nil) stringByAppendingString:DTLocalizedString(@"Normal", nil)];
    } else {
        waveWidthStr = DTLocalizedString(@"Unknown bandwidth", nil);
    }
    
    return waveWidthStr;
}

/******画波形*****/
- (void) drawEcgWave
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //新数组 从原数组抽点而来
    NSArray *vals_content = _isSpc ? _spcInfoItem.innerData.arrEcgContent : _ecgInfoItem.innerData.arrEcgContent;
    NSMutableArray *new_vals_content = [NSMutableArray array];
    for (int i = 0; i < vals_content.count; i += multiples) {
        NSNumber *val = [vals_content objectAtIndex:i];
        [new_vals_content addObject:val];
    }
    
    // x轴时间点两点间距
    float x_space = point_per_mm/new_vals_per_mm;  // (point)    //
    
    
    
    //画第一行
    int count_line1 = (seconds_leftToRight * mm_per_second - 15) * new_vals_per_mm;
    float x_axis = point1.y + upper_limit;   //第一行波形的原点y坐标
    //取得第一行的画线所需的点值
    NSMutableArray *firstLineVals_Arr = [NSMutableArray array];;
    for (int i = 0; i <= count_line1; i ++) {
        [firstLineVals_Arr addObject:new_vals_content[i]];
    }
    
    BOOL err_Value = YES;
    for (int i = 0; i < firstLineVals_Arr.count; i ++) {
        CGPoint point;
        point.x = point1.x + 15 * point_per_mm + x_space * i;
        point.y = x_axis - ([[firstLineVals_Arr objectAtIndex:i] floatValue] * points_per_mV);
        
        if (point.y < point1.y) {  //超出部分  无效点
            if (err_Value == NO) {  //如果上一个点是有效点
                [path addLineToPoint:CGPointMake(point.x, point1.y)];
            }
            err_Value = YES;
            continue;
        } else if(point.y >= point1.y) {   //当数值点的y坐标大于或等于上限外框点的y坐标时
            if (err_Value == YES) {  //如果上一个点是无效点
                if (point.y == point1.y) {  //当这个点恰好位于上限外框时
                    [path moveToPoint:point];
                } else if (point.y > point1.y && i != 0) {  //当这个点和上个点位于上限外框下上两侧时 且这个点不是第一个点(即上一个点一定存在)
                    [path moveToPoint:CGPointMake(point.x, point1.y)];
                } else if (point.y > point1.y && i == 0) { //当这个点不是第一个点时
                    [path moveToPoint:point];
                }
            } else { //如果上一个点是有效点
                [path addLineToPoint:point];
            }
            err_Value = NO;
        }
        
    }

    //删除数组中第一次取过后的点
    [new_vals_content removeObjectsInRange:NSMakeRange(0, count_line1)];
    int count_line = (seconds_leftToRight * mm_per_second) * new_vals_per_mm;    //一行的val点数
    int whole_lines = new_vals_content.count / count_line;  //完整的行数  （除第一行和最后一行）
    //创建一个数组来装剩下的每行的数据 数组中元素的个数为剩下的行数   (限完整行)
    NSMutableArray *lines_content_arr = [NSMutableArray array];
    for (int i = 0; i < whole_lines; i ++) {
        // 完整行的数据放到数组中
        NSMutableArray *arr = [NSMutableArray array];
        for (int j = 0; j < count_line; j ++) {
            [arr addObject:[new_vals_content objectAtIndex:j]];
        }
        [new_vals_content removeObjectsInRange:NSMakeRange(0, count_line)];
        [lines_content_arr addObject:arr];
    }
    //最后一行的数据 另放到一个数组
    NSMutableArray *last_line_arr = [NSMutableArray array];
    for (NSNumber *num in new_vals_content) {
        [last_line_arr addObject:num];
    }
    
    //画完整行
    CGPoint referrnce_point = {point1.x, (point1.y + 2 * upper_limit + lower_limit)};   //第二行画线的原点 做为参考点
    int debugeIndex = _isSpc ? 6 : 7;   //目前 如果是spc就最多画6行 否则7行(完整行)
    int lines = (lines_content_arr.count >= debugeIndex) ? debugeIndex : lines_content_arr.count;
    for (int a = 0; a < lines; a ++) {
        NSMutableArray *line_arr = [lines_content_arr objectAtIndex:a];
        CGPoint pointStart = CGPointMake(referrnce_point.x, referrnce_point.y + a*(upper_limit + lower_limit));
        [path moveToPoint:pointStart];
        for (float i = pointStart.x, j = 0; j < line_arr.count; i += x_space, j ++) {
            int index = j;
            float y_mV = [[line_arr objectAtIndex:index] floatValue];
            float y = pointStart.y - (y_mV * points_per_mV);
            [path addLineToPoint:CGPointMake(i, y)];
        }
    }
    
    //画最后一行
    if (lines_content_arr.count >= debugeIndex) {  // 目前如果完整行多于debugeIndex行  则最后一行不画
        
    }else {  //完整行小于等于debugeIndex-1行时
        CGPoint lastLinePointStart = {point1.x, referrnce_point.y + (lines_content_arr.count * (upper_limit + lower_limit))};
        [path moveToPoint:lastLinePointStart];
        for (float i = lastLinePointStart.x, j = 0; j < last_line_arr.count; i += x_space, j ++) {
            int index = j;
            float y_mV = [[last_line_arr objectAtIndex:index] floatValue];
            float y = lastLinePointStart.y - (y_mV * points_per_mV);
            [path addLineToPoint:CGPointMake(i, y)];
        }
    }


    path.lineWidth = thickLine*0.8;
    [[UIColor blackColor] setStroke];
    [path stroke];
}


- (void) drawRect:(CGRect)rect
{
    if (_isSpc && !_spcInfoItem.innerData) {   //如果spc没有测量心电
        return;
    }
    [self drawRectangle];
    [self drawThinLines];
    [self drawThickLines];
    [self drawScaleplate];    //画标尺
    [self drawEcgWave];
}

@end
