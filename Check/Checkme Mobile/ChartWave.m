//
//  NewHRWave.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/30.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ChartWave.h"
#import "NSDate+Additional.h"
#import "Colors.h"
#import "PublicMethods.h"

#define Gap_LeftTo_Wave 40.0f
#define Gap_BottomTo_Wave 30.0f
#define Gap_TopTo_Wave 40.0f
#define Gap_RightTo_Wave 20.0f

#define DAY_SAMPLE_NUM 25
#define WEEK_SAMPLE_NUM 7
#define MONTH_SAMPLE_NUM 29
#define YEAR_SAMPLE_NUM 13
#define SECONDS_AN_HOUR 3600
#define SECONDS_A_DAY (3600*24)

#define FILTER_TYPE_DAY 0
#define FILTER_TYPE_WEEK 1
#define FILTER_TYPE_MONTH 2
#define FILTER_TYPE_YEAR 3

@interface ChartWave()

//数据相关
@property (nonatomic,retain) NSArray* drawList;
@property (nonatomic,retain) NSArray* rowList;
@property (nonatomic,assign) int errNum;
@property (nonatomic,assign) int maxVal;
@property (nonatomic,assign) int minVal;
@property (nonatomic,assign) int lineNum;
@property (nonatomic,assign) bool isValsInited;
@property (nonatomic,assign) int curFilterType;
@property (nonatomic,assign) int chartType;

//画图相关
@property (nonatomic,assign) CGRect rectToDrawWave;
@property (nonatomic,assign) float pixPerVal;//每hr，spo2...值 对应的point点数
@property (nonatomic,assign) float pixPerTime;//每个day week month值对应的point点数

//记录上次的时间
@property (nonatomic,retain)NSDate *lastdayDate;
@property (nonatomic,retain)NSDate *lastweekDate;
@property (nonatomic,retain)NSDate *lastmonthDate;
@property (nonatomic,retain)NSDate *lastyearDate;


@end

@implementation ChartWave
{
    int indexDay;
    int indexWeek;
    int indexMon;
    int indexYear;
    
    UIImageView *imgLeft;
    UIImageView *imgRight;
    
    NSString  *swipedirection;
}

- (instancetype)initWithFrame:(CGRect)frame withChartList:(NSArray*) inList chartType:(int)chartType    //  inList元素为chartItem类型   chartItem属性:val,dtcData      chartType:HR、SPO2、BP
{
    self = [super initWithFrame:frame];
    if (self) {
        swipedirection = @"";
        _isValsInited = NO;
        _rowList = inList;
        _chartType = chartType;
        _curFilterType = FILTER_TYPE_WEEK;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        indexDay = 0;
        indexWeek = 0;
        indexMon = 0;
        indexYear = 0;
        
        UISwipeGestureRecognizer *swipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        swipeG.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeG];
        
        UISwipeGestureRecognizer *leftSwipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        leftSwipeG.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:leftSwipeG];
    }
    return self;
}


//初始化各参数
-(void)initParams:(float) maxVal min:(float) minVal lineNum:(int) lineNum errNum:(int) errNum
{
    if (_rowList==nil||_rowList.count==0) {
        return;
    }
    if(maxVal<minVal||lineNum==0){
        return;
    }
    
    _maxVal = maxVal;
    _minVal = minVal;
    _lineNum = lineNum;
    _errNum = errNum;
    _isValsInited = YES;
    
    //绘图参数
    _rectToDrawWave = CGRectMake(Gap_LeftTo_Wave, Gap_TopTo_Wave, self.frame.size.width - Gap_LeftTo_Wave - Gap_RightTo_Wave, self.frame.size.height - Gap_TopTo_Wave - Gap_BottomTo_Wave);
    
    _rowList = [self filterNoErr:_rowList];   //滤除值为0的数据
    
    //获取当前时间
    NSDate* now = [NSDate date];
    _drawList = [self filterWeekList:_rowList withCurDate:now];   //得到周列表
    
    _pixPerVal = _rectToDrawWave.size.height/(_maxVal-_minVal);   //每val值对应的point点数
    _pixPerTime = _rectToDrawWave.size.width/(double)(_drawList.count);    //   得到的是周列表 故有7组数据
}

//去掉列表中无效数据
-(NSArray*)filterNoErr:(NSArray*) inList
{
    if (inList==nil||inList.count==0) {
        return nil;
    }
    NSMutableArray* outList = [[NSMutableArray alloc] initWithCapacity:10];
    for(int i=0;i<[inList count];i++){
        ChartItem* item = [inList objectAtIndex:i];
        if (item.val!=_errNum) {
            [outList addObject:item];
        }
    }
    return outList;
}

//得到天列表
-(NSArray*)filterDayList:(NSArray*) chartList withCurDate:(NSDate *)curDate   // _rowList
{
    if (chartList==nil||chartList.count==0) {
        return nil;
    }
    NSMutableArray* dayList = [[NSMutableArray alloc]init];
    
    for (int i=DAY_SAMPLE_NUM-1;i>=0;i--) {
        //新建24个sampleItem，分辨是最后日期前24小时
        SampleItem* sampleItem = [[SampleItem alloc]init];
        [sampleItem setDtcDate:[NSDate dateWithTimeInterval:-i*SECONDS_AN_HOUR sinceDate:curDate]];
        //遍历inList中item，同小时的全加入当前sampleItem
        for (int j=0; j<chartList.count; j++) {
            ChartItem* chartItem = [chartList objectAtIndex:j];
            //如果chartItem的时间与当前sampleItem的date是同一小时
            if ([self isSameHour:[chartItem dtcDate] curDate:[sampleItem dtcDate]]) {
                [sampleItem addVal:chartItem];
            }
        }
        [dayList addObject:sampleItem];
    }
    return dayList;
}

//得到周列表
-(NSArray*)filterWeekList:(NSArray*) chartList withCurDate:(NSDate *)curDate
{
    if (chartList==nil||chartList.count==0) {
        return nil;
    }
    NSMutableArray* weekList = [[NSMutableArray alloc]init];
    
    for (int i=WEEK_SAMPLE_NUM-1;i>=0;i--) {
        //新建7个sampleItem
        
        SampleItem* sampleItem = [[SampleItem alloc]init];
        [sampleItem setDtcDate:[NSDate dateWithTimeInterval:-i*SECONDS_A_DAY sinceDate:curDate]];  //(3600*24)  一天的秒数
        
        for (int j=0; j<chartList.count; j++) {
            
            ChartItem* chartItem = [chartList objectAtIndex:j];
            
            //如果chartItem的时间与当前sampleItem的date是同一天
            if ([self isSameDay:[chartItem dtcDate] curDate:[sampleItem dtcDate]]) {
                [sampleItem addVal:chartItem];  //注意：内层for循环是针对同一个sampleItem。addVal的作用是：当这一天只测了一次数据，则最大值最小值都是此数据，如果测了多次，就比较来找出最大值与最小值
            }
        }
        [weekList addObject:sampleItem];
    }

    return weekList;   //注意 weekList中有7组数据，包括空数据（空数据即sampleItem的val值为空置）
}

//得到月列表
-(NSArray*)filterMonthList:(NSArray*) chartList withCurDate:(NSDate *)curDate
{
    NSMutableArray* monthList = [[NSMutableArray alloc]init];

    for (int i=MONTH_SAMPLE_NUM-1;i>=0;i--) {
        //新建7个sampleItem，分辨是最后日期前29天
        SampleItem* sampleItem = [[SampleItem alloc]init];
        [sampleItem setDtcDate:[NSDate dateWithTimeInterval:-i*SECONDS_A_DAY sinceDate:curDate]];
        //遍历inList中item，同一天的全加入当前sampleItem
        for (int j=0; j<chartList.count; j++) {
            ChartItem* chartItem = [chartList objectAtIndex:j];
            //如果chartItem的时间与当前sampleItem的date是同一天
            if ([self isSameDay:[chartItem dtcDate] curDate:[sampleItem dtcDate]]) {
                [sampleItem addVal:chartItem];
            }
        }
        [monthList addObject:sampleItem];
    }
    return monthList;
}

//得到年列表
-(NSArray*)filterYearList:(NSArray*) chartList withCurDate:(NSDate *)curDate
{
    NSMutableArray* yearList = [[NSMutableArray alloc]init];
    for (int i=YEAR_SAMPLE_NUM-1;i>=0;i--) {
        //新建7个sampleItem，分辨是最后日期前29天
        SampleItem* sampleItem = [[SampleItem alloc]init];
        [sampleItem setDtcDate:[NSDate dateWithTimeInterval:-i*SECONDS_A_DAY*31 sinceDate:curDate]];
        //遍历inList中item，同一天的全加入当前sampleItem
        for (int j=0; j<chartList.count; j++) {
            ChartItem* chartItem = [chartList objectAtIndex:j];
            //如果chartItem的时间与当前sampleItem的date是同一天
            if ([self isSameMonth:[chartItem dtcDate] curDate:[sampleItem dtcDate]]) {
                [sampleItem addVal:chartItem];
            }
        }
        [yearList addObject:sampleItem];
    }
    return yearList;
}

//判断两个sample是否属于同一个小时
-(bool)isSameHour:(NSDate*) preDate curDate:(NSDate*)curDate
{
    if (preDate==nil||curDate==nil) {
        return NO;
    }
    //转换成comps方便比较
    NSDateComponents* preComps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:preDate];
    NSDateComponents* curComps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit |NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:curDate];
    
    if ([preComps hour]==[curComps hour]&&[preComps day]==[curComps day]&&[preComps month]==[curComps month]&&[preComps year] == [curComps year]) {
        return YES;
    }else{
        return NO;
    }
}

//判断两个sample是否属于同一天
-(bool)isSameDay:(NSDate*) preDate curDate:(NSDate*)curDate
{
    if (preDate==nil||curDate==nil) {
        return NO;
    }
    //转换成comps方便比较
    NSDateComponents* preComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:preDate];
    NSDateComponents* curComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:curDate];
    
    if ([preComps day]==[curComps day]&&[preComps month]==[curComps month]&&[preComps year] == [curComps year]) {
        return YES;
    }else{
        return NO;
    }
}

//判断两个sample是否属于同一月
-(bool)isSameMonth:(NSDate*) preDate curDate:(NSDate*)curDate
{
    if (preDate==nil||curDate==nil) {
        return NO;
    }
    //转换成comps方便比较
    NSDateComponents* preComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:preDate];
    NSDateComponents* curComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:curDate];
    
    if ([preComps month]==[curComps month]&&[preComps year] == [curComps year]) {
        return YES;
    }else{
        return NO;
    }
}

//判断两个sample是否属于同一年
-(bool)isSameYear:(NSDate*) preDate curDate:(NSDate*)curDate
{
    if (preDate==nil||curDate==nil) {
        return NO;
    }
    //转换成comps方便比较
    NSDateComponents* preComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:preDate];
    NSDateComponents* curComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:curDate];
    
    if ([preComps year] == [curComps year]) {
        return YES;
    }else{
        return NO;
    }
}




//日趋势中根据最新date生成一个date(hour=24:00)
-(NSDate*)makeLastDate:(NSDate*)date
{
    if(date==nil)
        return nil;
     NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    comps.hour = 24;
    comps.minute = 0;
    comps.second = 0;
    
    NSCalendar *defaultCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* outDate = [defaultCalender dateFromComponents:comps];
    return outDate;
}

//计算很坐标文字间隔
-(int)calAxisXStep
{
    switch (_curFilterType) {
        case FILTER_TYPE_DAY:
            return 12;
        case FILTER_TYPE_WEEK:
            return 1;
        case FILTER_TYPE_MONTH:
            return 7;
        case FILTER_TYPE_YEAR:
            return 3;
        default:
            return 1;
    }
}

//生成横坐标文字
-(NSString*)makeAxisXStr:(NSDate*) preDate curDate:(NSDate*) curDate
{
    NSArray *monthNameList;
    
//    if ([curLanguage isEqualToString:@"zh-Hans"]) { //如果是简体中文
//        monthNameList = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",nil];
//    }else if([curLanguage isEqualToString:@"ja"]) {  //如果是日语
//        monthNameList = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",nil];
//    }else if ([curLanguage isEqualToString:@"fr"]) {  //法文
//        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Avr",@"Mai",@"Juin",@"Juil",@"Aou",@"Sep",@"Oct",@"Nov",@"Déc",nil];
//    }else if ([curLanguage isEqualToString:@"de"]) {   //德文
//        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mär",@"Apr",@"Mai",@"Jun",@"Jul",@"Aug",@"Sep",@"Okt",@"Nov",@"Dez",nil];
//    }else if ([curLanguage isEqualToString:@"hu"]) {   //匈牙利文
//        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Febr",@"Márc",@"Ápr",@"Május",@"Jún",@"Júl",@"Aug",@"Szept",@"Okt",@"Nov",@"Dec",nil];
//    }else { //英文 或其他
//        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
//    }
    
    if ([curLanguage isEqualToString:@"es-CN"]) { //如果是简体中文
        monthNameList = [NSArray arrayWithObjects:@"Ene",@"Feb",@"Mar",@"Abr",@"May",@"Jun",@"Jul",@"Ago",@"Sept",@"Oct",@"Nov",@"Dic",nil];
    }else{
        //因为只有英文，所以写出来
        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
    }
    

    
    NSDateComponents* curComps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:curDate];
    
    NSString* str;
    if (_curFilterType == FILTER_TYPE_DAY) {
        if (preDate==nil) {
            str = [NSString stringWithFormat:DTLocalizedString(@"(%@ %ld) 12AM", nil),[monthNameList objectAtIndex:curComps.month-1], (long)curComps.day,(long)curComps.hour];
        }else{
               str = @"12PM";
//            str = [NSString stringWithFormat:@" %ld",(long)curComps.hour];
            if ([[NSString stringWithFormat:@" %ld",(long)curComps.hour] isEqualToString:@" 0"]) {
//                str = @" 24";
                str = @"12AM";
            }
        }
    }else if (_curFilterType == FILTER_TYPE_WEEK||_curFilterType == FILTER_TYPE_MONTH) {
        if (preDate==nil) {//第一个 显示月
            str = [NSString stringWithFormat:DTLocalizedString(@"%@ %ld", nil),[monthNameList objectAtIndex:curComps.month-1], (long)curComps.day];
        }else{
            if ([self isSameMonth:preDate curDate:curDate]) {//同一个月，只写日期
                str = [NSString stringWithFormat:@" %ld",(long)curComps.day];
            }else{
                str = [NSString stringWithFormat:DTLocalizedString(@"%@ %ld", nil),[monthNameList objectAtIndex:curComps.month-1], (long)curComps.day];
            }
        }
    }else if(_curFilterType == FILTER_TYPE_YEAR){
        if (preDate==nil) {
            //  判断语言
            if ([curLanguage isEqualToString:@"zh-Hans"]) {
                str = [NSString stringWithFormat:@"%ld-%@",(long)curComps.year, [monthNameList objectAtIndex:curComps.month-1]];
            }else if ([curLanguage isEqualToString:@"ja"]) {
                str = [NSString stringWithFormat:@"%ld/%@",(long)curComps.year, [monthNameList objectAtIndex:curComps.month-1]];
            }else {
                str = [NSString stringWithFormat:@"%@ %ld", [monthNameList objectAtIndex:curComps.month-1], (long)curComps.year];
            }
            //因为只有英文，所以写出来
            str = [NSString stringWithFormat:@"%@ %ld", [monthNameList objectAtIndex:curComps.month-1], (long)curComps.year];
            
        }else{
            if ([self isSameYear:preDate curDate:curDate]) {
                str = [NSString stringWithFormat:@"%@",[monthNameList objectAtIndex:curComps.month-1]];
            }else{
                //  判断语言
                if ([curLanguage isEqualToString:@"zh-Hans"]) {
                    str = [NSString stringWithFormat:@"%ld-%@",(long)curComps.year, [monthNameList objectAtIndex:curComps.month-1]];
                }else if ([curLanguage isEqualToString:@"ja"]) {
                    str = [NSString stringWithFormat:@"%ld/%@",(long)curComps.year, [monthNameList objectAtIndex:curComps.month-1]];
                }else {
                    str = [NSString stringWithFormat:@"%@ %ld",[monthNameList objectAtIndex:curComps.month-1],(long)curComps.year];
                }
                //因为只有英文，所以写出来
                str = [NSString stringWithFormat:@"%@ %ld",[monthNameList objectAtIndex:curComps.month-1],(long)curComps.year];
            }
        }
    }
    return str;
}

/************画图相关**************/

-(void)drawRect:(CGRect)rect
{
    if (!_isValsInited) {
        DLog(@"chart参数未初始化");
        [self drawNoData];
        
        return;
    }
    if(_drawList==nil||_drawList.count==0){
        DLog(@"drawList为空");
        [self drawNoData];
        
        return;
    }
    
    [self drawSwipeImg];
    [self drawAxisLine];
    [self drawVerticalLabel];
    [self drawHorizontalLabel];
    [self drawWave:_drawList];
}



- (void) drawSwipeImg
{
    if (!imgLeft) {
        imgLeft = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth  -  100, CGRectGetHeight(self.frame)/2 + 5, 40, 25)];
        imgLeft.image = [UIImage imageNamed:@"previous.png"];
//        imgLeft.hidden = YES;
        imgLeft.alpha = 0;
        [self.superview.superview addSubview:imgLeft];
    }
    
    if (!imgRight) {
        imgRight = [[UIImageView alloc] initWithFrame:CGRectMake(100, CGRectGetHeight(self.frame)/2 + 5, 40,25)];
        imgRight.image = [UIImage imageNamed:@"next.png"];
//        imgRight.hidden = YES;
        imgRight.alpha = 0;
        [self.superview.superview  addSubview:imgRight];
    }
    
    if ([swipedirection isEqualToString:@"left"]) {
       
        if ((_curFilterType == FILTER_TYPE_DAY && indexDay == 0) || (_curFilterType == FILTER_TYPE_MONTH && indexMon == 0) || (_curFilterType == FILTER_TYPE_WEEK && indexWeek == 0) || (_curFilterType == FILTER_TYPE_YEAR && indexYear == 0)) {
            
            swipedirection = @"";
            
        } else {
            
            swipedirection = @"left";
            
            
        }

    }
    

    
    if ([swipedirection isEqualToString:@"left"]) {
        
        imgLeft.x = kScreenWidth -  100;
//        imgLeft.hidden = NO;
         imgLeft.alpha = 5;
        [UIView animateWithDuration:1.0 // 动画时长
                              delay:0.0 // 动画延迟
             usingSpringWithDamping:1.0 // 类似弹簧振动效果 0~1
              initialSpringVelocity:0.3 // 初始速度
                            options:UIViewAnimationOptionCurveLinear // 动画过渡效果
                         animations:^{
                             // code...
//                             imgLeft.hidden = NO;
                             
                              CGPoint point = imgLeft.center;
                              point.x -= 130;
                              imgLeft.alpha -= 5;
                             [imgLeft setCenter:point];
                            
                         } completion:^(BOOL finished) {
                             // 动画完成后执行
                             // code...
                               imgLeft.alpha = 0;

                         }];
   
    } else if ([swipedirection isEqualToString:@"right"]) {
    
        imgRight.x = 100;
//        imgRight.hidden = NO;
        imgRight.alpha = 5;
        [UIView animateWithDuration:1.0 // 动画时长
                              delay:0.0 // 动画延迟
             usingSpringWithDamping:1.0 // 类似弹簧振动效果 0~1
              initialSpringVelocity:0.3 // 初始速度
                            options:UIViewAnimationOptionCurveLinear // 动画过渡效果
                         animations:^{
                             // code...
//                             imgRight.hidden = NO;
                             
                             CGPoint point = imgRight.center;
                             point.x +=   130 ;
//                             imgRight.alpha -= (point.x  - ((kScreenWidth - 40) / 2.0  - 40 )) / 120;
                             imgRight.alpha -= 5;
                             [imgRight setCenter:point];
                         } completion:^(BOOL finished) {
                             // 动画完成后执行
                
                             imgRight.alpha = 0;
                         }];
    

    }
//
    
    

}



-(void)drawAxisLine
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, .5);
    CGContextSetStrokeColorWithColor(context, [LIGHT_GREY CGColor]);
    
    //绘制横向分割线
    for(double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height; y >= _rectToDrawWave.origin.y-5; )//-5,向上多画一点，避免最大值不画
    {
        CGContextBeginPath(context);
        double x = 0;
        x = _rectToDrawWave.origin.x;
        CGContextMoveToPoint(context, x, y);
        x = _rectToDrawWave.origin.x + _rectToDrawWave.size.width;
        CGContextAddLineToPoint(context, x, y);
        CGContextDrawPath(context, kCGPathStroke);
        y -= (_maxVal-_minVal)/(_lineNum-1)*_pixPerVal;
    }
}

//画纵坐标
-(void)drawVerticalLabel
{
    //绘制纵坐标label
    double label_h = 10;
    double label_w = Gap_LeftTo_Wave;
    float val = 0;
    int i=0;
    for(double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height; y >= _rectToDrawWave.origin.y-5 ; )//-5,向上多画一点，避免最大值不画
    {
        double x = _rectToDrawWave.origin.x - label_w;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x -2 , y - label_h/2.0, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
//        lbl.textColor = TRANSPARENT_WHITE;
        lbl.textColor = Colol_lableft;
        lbl.font = [UIFont systemFontOfSize:9];
        if(i == 0)
            val = _minVal;
        else
            val += (_maxVal-_minVal)/(_lineNum-1);
        
        switch (_chartType) {
            case CHART_TYPE_HR:
                lbl.text = [NSString stringWithFormat:@"%.f",val];
                break;
            case CHART_TYPE_SPO2:
                lbl.text = [NSString stringWithFormat:@"%.f%%",val];
                break;
            case CHART_TYPE_BP_RE:
                if(val>0)
                    lbl.text = [NSString stringWithFormat:@"+%.f%%",val];
                else
                    lbl.text = [NSString stringWithFormat:@"%.f%%",val];
                break;
            case CHART_TYPE_BP_ABS:
                lbl.text = [NSString stringWithFormat:@"%.f",val];
                break;
            case CHART_TYPE_PI:
                  lbl.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(val);
                break;
            case CHART_TYPE_Relaxaction:
                lbl.text = [NSString stringWithFormat:@"%.f",val];
                break;
            default:
                break;
        }
        
        [self addSubview:lbl];
        y -= (_maxVal-_minVal)/(_lineNum-1)*_pixPerVal,++i;
    }
    
    //图例
    float legendH = 18;
    UILabel *legend = [[UILabel alloc] initWithFrame:CGRectMake(2 , _rectToDrawWave.origin.y/2-legendH/2, 200, legendH)];
    legend.textAlignment = NSTextAlignmentLeft;
    legend.textColor = Colol_lableft;
    legend.font = [UIFont systemFontOfSize:15];
    switch (_chartType) {
        case CHART_TYPE_HR:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Heart Rate", nil)];
            break;
        case CHART_TYPE_SPO2:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Oxygen Saturation", nil)];
            break;
        case CHART_TYPE_BP_RE:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Systolic Blood Pressure", nil)];
            break;
        case CHART_TYPE_BP_ABS:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Systolic Blood Pressure", nil)];
            break;
        case CHART_TYPE_PI:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Rate Pressure Product", nil)];
            break;
        case CHART_TYPE_Relaxaction:
            legend.text = [NSString stringWithFormat:@"%@",DTLocalizedString(@"Relaxation Index", nil)];
            break;
    
            
        default:
            break;
    }
    
    [self addSubview:legend];
    
    
    //曲线额度
//    float legendH = 18;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - Gap_RightTo_Wave,Gap_TopTo_Wave, Gap_RightTo_Wave - 9, _rectToDrawWave.size.height)];
    bgView.backgroundColor = [UIColor clearColor];
    float sizeheight =  (float) _rectToDrawWave.size.height / (_maxVal - _minVal);
    
    UIView *bgView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bgView.width, bgView.height)];
    UIView *bgView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bgView.width, bgView.height)];
    UIView *bgView3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bgView.width, bgView.height)];
    UIView *bgView4 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bgView.width, bgView.height)];
    
    switch (_chartType) {
        case CHART_TYPE_HR:
            bgView1.height = (_maxVal - 150)  *  sizeheight;
            bgView1.y = 0;
            bgView1.backgroundColor = COLOR_RGB(221, 0, 32, 1);
            [bgView addSubview:bgView1];
            bgView2.height = (150 - 100) *  sizeheight;
            bgView2.y = bgView1.bottom;
            bgView2.backgroundColor = COLOR_RGB(234, 113, 21, 1);
            [bgView addSubview:bgView2];
            bgView3.height = (100 - 50) *  sizeheight;
            bgView3.y = bgView2.bottom;
            bgView3.backgroundColor = COLOR_RGB(18, 141, 59, 1);
            [bgView addSubview:bgView3];
            bgView4.height = (50 - _minVal) *  sizeheight;
            bgView4.y = bgView3.bottom;
            bgView4.backgroundColor = COLOR_RGB(18, 143, 227, 1);
            [bgView addSubview:bgView4];
            
            break;
        case CHART_TYPE_SPO2:
            bgView1.height = (_maxVal - 93)  *  sizeheight;
            bgView1.y = 0;
            bgView1.backgroundColor = COLOR_RGB(18, 141, 59, 1);
            [bgView addSubview:bgView1];
            bgView2.height = (93 - _minVal) *  sizeheight;
            bgView2.y = bgView1.bottom;
            bgView2.backgroundColor = COLOR_RGB(18, 143, 227, 1);
            [bgView addSubview:bgView2];

            
            break;
        case CHART_TYPE_BP_RE:
            
            break;
        case CHART_TYPE_BP_ABS:
            bgView2.height = (_maxVal - 140) *  sizeheight;
            bgView2.y = 0;
            bgView2.backgroundColor = COLOR_RGB(234, 113, 21, 1);
            [bgView addSubview:bgView2];
            bgView3.height = (140 - 90) *  sizeheight;
            bgView3.y = bgView2.bottom;
            bgView3.backgroundColor = COLOR_RGB(18, 141, 59, 1);
            [bgView addSubview:bgView3];
            bgView4.height = (90 - _minVal) *  sizeheight;
            bgView4.y = bgView3.bottom;
            bgView4.backgroundColor = COLOR_RGB(18, 143, 227, 1);
            [bgView addSubview:bgView4];

            
            break;
        case CHART_TYPE_PI:
            bgView1.height = (_maxVal - 20000)  *  sizeheight;
            bgView1.y = 0;
            bgView1.backgroundColor = COLOR_RGB(221, 0, 32, 1);
            [bgView addSubview:bgView1];
            bgView2.height = (20000 - 12000) *  sizeheight;
            bgView2.y = bgView1.bottom;
            bgView2.backgroundColor = COLOR_RGB(234, 113, 21, 1);
            [bgView addSubview:bgView2];
            bgView3.height = (12000 - 5400) *  sizeheight;
            bgView3.y = bgView2.bottom;
            bgView3.backgroundColor = COLOR_RGB(18, 141, 59, 1);
            [bgView addSubview:bgView3];
            bgView4.height = (5400 - _minVal) *  sizeheight;
            bgView4.y = bgView3.bottom;
            bgView4.backgroundColor = COLOR_RGB(18, 143, 227, 1);
            [bgView addSubview:bgView4];
            break;
        case CHART_TYPE_Relaxaction:
            bgView2.height = (_maxVal - 75) *  sizeheight;
            bgView2.y = 0;
            bgView2.backgroundColor = COLOR_RGB(234, 113, 21, 1);
            [bgView addSubview:bgView2];
            bgView3.height = (75 - 25) *  sizeheight;
            bgView3.y = bgView2.bottom;
            bgView3.backgroundColor = COLOR_RGB(18, 141, 59, 1);
            [bgView addSubview:bgView3];
            bgView4.height = (25 - _minVal) *  sizeheight;
            bgView4.y = bgView3.bottom;
            bgView4.backgroundColor = COLOR_RGB(18, 143, 227, 1);
            [bgView addSubview:bgView4];
            break;
            
            
        default:
            break;
    }
    [self addSubview:bgView];
   
}

//画横坐标
-(void)drawHorizontalLabel
{
    double label_h = 25;
    double label_w = 100;
    //取点间隔距离，总点数除以（可以画下label个数/2)
    int stepDis = [self calAxisXStep];
    
    for (int i=0; i<_drawList.count; i+=stepDis) {
        double x = _rectToDrawWave.origin.x + i*_pixPerTime;
        double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height;
        
        //文字坐标
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x - label_w/2.0, y + 1, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.numberOfLines = 0;
        
        if (i==0) {//第一个坐标默认写详细
            lbl.text  = [NSString stringWithFormat:@"%@",[self makeAxisXStr:nil curDate:(NSDate*)[[_drawList objectAtIndex:i] dtcDate]]];
        }else{
            lbl.text  = [NSString stringWithFormat:@"%@",[self makeAxisXStr:(NSDate*)[[_drawList objectAtIndex:i-stepDis] dtcDate] curDate:(NSDate*)[[_drawList objectAtIndex:i] dtcDate]]];
        }
//        lbl.textColor = TRANSPARENT_WHITE;
        lbl.textColor = Colol_lableft;
        lbl.font = [UIFont systemFontOfSize:11];
        [self addSubview:lbl];
    }
}


-(void)drawWave:(NSArray*)drawList
{
    double bigR = 5, smallR = 2;
    
    for (int i=0; i<drawList.count; i++) {
        SampleItem* item = [drawList objectAtIndex:i];
        if ([item isNilVal]) {
            continue;
        }else if ([item isMultiVal]){
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextBeginPath(context);
            CGRect rect;
            float y1 = ([item maxVal] - _minVal) * _pixPerVal;//高度
            y1 = _rectToDrawWave.origin.y + _rectToDrawWave.size.height - y1;//y坐标
            y1 -= bigR/2;//使点位于中心位置
            float y2 = ([item minVal] - _minVal) * _pixPerVal;//高度
            y2 = _rectToDrawWave.origin.y + _rectToDrawWave.size.height - y2;//y坐标
            y2 -= bigR/2;//使点位于中心位置
            
            //竖线,大小值点,两点距离足够大时才画
            if (y2-y1>=bigR) {
                CGContextSetAlpha(context, 0.5);
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime,y1+bigR/2,bigR,y2-y1);
                CGContextAddRect(context, rect);
                CGContextFillPath(context);
                
                //最大值点
                CGContextSetAlpha(context, 1);
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime,y1,bigR,bigR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime+bigR/2-smallR/2,y1+bigR/2-smallR/2,smallR,smallR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);
                
                //最小值点
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime,y2,bigR,bigR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime+bigR/2-smallR/2,y2+bigR/2-smallR/2,smallR,smallR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);

            }else{//两点求平均
                float y = (([item maxVal]+[item minVal])/2 - _minVal) * _pixPerVal;
                y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height - y;
                y -= bigR/2;
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime,y,bigR,bigR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);
                CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
                rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime+bigR/2-smallR/2,y+bigR/2-smallR/2,smallR,smallR);
                CGContextAddEllipseInRect(context, rect);
                CGContextFillPath(context);
            }
           
            
        }else{
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context,[Colol_lableft  CGColor]);
            CGContextBeginPath(context);
            float y = ([item minVal] - _minVal) * _pixPerVal;//高度
            y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height - y;//y坐标
            y -= bigR/2;
            CGRect rect;
            
            CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
            rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime,y,bigR,bigR);
            CGContextAddEllipseInRect(context, rect);
            CGContextFillPath(context);
            CGContextSetFillColorWithColor(context,[Colol_lableft CGColor]);
            rect = CGRectMake(_rectToDrawWave.origin.x + i*_pixPerTime+bigR/2-smallR/2,y+bigR/2-smallR/2,smallR,smallR);
            CGContextAddEllipseInRect(context, rect);
            CGContextFillPath(context);
        }

    }
    
}

-(void)drawNoData
{
    float lblWith = 260;
    float lblHeight = 80;
    float x = self.frame.size.width/2 - lblWith/2;
    float y = self.frame.size.height/2 - lblHeight/2;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, lblWith, lblHeight)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.numberOfLines = 0;
    lbl.text = DTLocalizedString(@"No data", nil);
    lbl.alpha = 0.6;
    lbl.textColor = Colol_labtishi;
    lbl.font = [UIFont systemFontOfSize:35];

    if ([curLanguage isEqualToString:@"ja"]) {
        lbl.font = [UIFont systemFontOfSize:20];;
    }
    [self addSubview:lbl];

}

/*****************动态调整****************/

-(void)switchScale:(U8)scale
{
    
    swipedirection = @"";
    
    if (!_isValsInited||_rowList==nil||_drawList==nil) {
        return;
    }
    if (scale>FILTER_TYPE_YEAR) {
        return;
    }
    //scale从0开始，与宏Filter_Type对应
    _curFilterType = scale;
    
    switch (_curFilterType) {
        case FILTER_TYPE_DAY:
        {
            if(indexDay == 0)
            {
                _lastdayDate = [self makeLastDate:[NSDate date]];
            
            }

//            NSDate* lastDate = [self makeLastDate:[NSDate date]];
            _drawList = [self filterDayList:_rowList withCurDate:_lastdayDate];
        }
            break;
        case FILTER_TYPE_WEEK:
            if (indexWeek == 0) {
                _lastweekDate = [NSDate date];
            }
            
            _drawList = [self filterWeekList:_rowList withCurDate:_lastweekDate];
            break;
        case FILTER_TYPE_MONTH:
        {
            if (indexMon == 0) {
                _lastmonthDate = [NSDate date];
            }
            
            _drawList = [self filterMonthList:_rowList withCurDate:_lastmonthDate];
        }
            break;
        case FILTER_TYPE_YEAR:
        {
            if (indexYear == 0) {
                _lastyearDate = [NSDate date];
            }
            _drawList = [self filterYearList:_rowList withCurDate:_lastyearDate];
        }
            break;
            
        default:
            break;
    }
    
//    indexDay = 0;
//    indexWeek = 0;
//    indexMon = 0;
//    indexYear = 0;
    _pixPerTime = _rectToDrawWave.size.width/(double)(_drawList.count);
    
    [self removeAllSubViews];
    [self setNeedsDisplay];
}


// 手势操作
-(void)swipeGesture:(id)sender
{
    UISwipeGestureRecognizer *swipe = sender;
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {  //向左滑
        
        swipedirection = @"left";
        
        switch (_curFilterType) {
            case FILTER_TYPE_DAY:
            {
                if (indexDay > 0) {
                    indexDay --;
                    NSDate* lastDate = [self makeLastDate:[NSDate date]];
                    _lastdayDate = [NSDate dateWithTimeInterval:(-indexDay * SECONDS_A_DAY) sinceDate:lastDate];
                    _drawList = [self filterDayList:_rowList withCurDate:_lastdayDate];
//                    NSDate *curDate = [NSDate dateWithTimeInterval:(-indexDay * SECONDS_A_DAY) sinceDate:lastDate];
//                    _drawList = [self filterDayList:_rowList withCurDate:curDate];
                }
            }
                break;
            case FILTER_TYPE_WEEK:
            {
                if (indexWeek > 0) {
                    indexWeek --;
                    NSDate *now = [NSDate date];
                    _lastweekDate = [NSDate dateWithTimeInterval:(-WEEK_SAMPLE_NUM*indexWeek*SECONDS_A_DAY) sinceDate:now];
                     _drawList = [self filterWeekList:_rowList withCurDate:_lastweekDate];
//                    NSDate *curDate = [NSDate dateWithTimeInterval:(-WEEK_SAMPLE_NUM*indexWeek*SECONDS_A_DAY) sinceDate:now];
//                    _drawList = [self filterWeekList:_rowList withCurDate:curDate];   //得到周列表
                }
            }
                break;
            case FILTER_TYPE_MONTH:
            {
                if (indexMon > 0) {
                    indexMon --;
                    NSDate* lastDate = [NSDate date];
                    _lastmonthDate = [NSDate dateWithTimeInterval:(-MONTH_SAMPLE_NUM*indexMon * SECONDS_A_DAY) sinceDate:lastDate];
                    _drawList = [self filterMonthList:_rowList withCurDate:_lastmonthDate];
                    
//                    NSDate *curDate = [NSDate dateWithTimeInterval:(-MONTH_SAMPLE_NUM*indexMon * SECONDS_A_DAY) sinceDate:lastDate];
//                    _drawList = [self filterMonthList:_rowList withCurDate:curDate];
                }
            }
                break;
            case FILTER_TYPE_YEAR:
            {
                if (indexYear > 0) {
                    indexYear --;
                    NSDate* lastDate = [NSDate date];
                    NSDateComponents *dtc = [NSDate dateCompFromDate:lastDate];
                    int y = dtc.year;
                    int sample_year;
                    if (y % 400 == 0 || (y % 4 == 0 && y %100 != 0)) { //如果是闰年
                        sample_year = 366;
                    } else sample_year = 365;
                     _lastyearDate = [NSDate dateWithTimeInterval:(-sample_year*indexYear * SECONDS_A_DAY) sinceDate:lastDate];
                    _drawList = [self filterYearList:_rowList withCurDate:_lastyearDate];
//                    NSDate *curDate = [NSDate dateWithTimeInterval:(-sample_year*indexYear * SECONDS_A_DAY) sinceDate:lastDate];
//                    _drawList = [self filterYearList:_rowList withCurDate:curDate];
                }
            }
                break;
                
            default:
                break;
        }
        
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {  //向右滑
        
          swipedirection = @"right";
//        if (imgLeft.hidden == NO) {
//            [UIView animateWithDuration:1.0 animations:^{
//                imgLeft.hidden = YES;
//            } completion:^(BOOL finished) {
//                imgLeft.hidden = NO;
//            }];
//        }
        
        switch (_curFilterType) {
            case FILTER_TYPE_DAY:
            {
                indexDay ++;
                NSDate* lastDate = [self makeLastDate:[NSDate date]];
                _lastdayDate = [NSDate dateWithTimeInterval:(-indexDay * SECONDS_A_DAY) sinceDate:lastDate];
                _drawList = [self filterDayList:_rowList withCurDate:_lastdayDate];
//                NSDate *curDate = [NSDate dateWithTimeInterval:(-indexDay * SECONDS_A_DAY) sinceDate:lastDate];
//                _drawList = [self filterDayList:_rowList withCurDate:curDate];
            }
                break;
            case FILTER_TYPE_WEEK:
            {
                indexWeek ++;
                NSDate *now = [NSDate date];
                _lastweekDate = [NSDate dateWithTimeInterval:(-WEEK_SAMPLE_NUM*indexWeek*SECONDS_A_DAY) sinceDate:now];
                _drawList = [self filterWeekList:_rowList withCurDate:_lastweekDate];
//                NSDate *curDate = [NSDate dateWithTimeInterval:(-WEEK_SAMPLE_NUM*indexWeek*SECONDS_A_DAY) sinceDate:now];
//                _drawList = [self filterWeekList:_rowList withCurDate:curDate];   //得到周列表
            }
                break;
            case FILTER_TYPE_MONTH:
            {
                indexMon ++;
                NSDate* lastDate = [NSDate date];
                _lastmonthDate = [NSDate dateWithTimeInterval:(-MONTH_SAMPLE_NUM*indexMon * SECONDS_A_DAY) sinceDate:lastDate];
                _drawList = [self filterMonthList:_rowList withCurDate:_lastmonthDate];
//                NSDate *curDate = [NSDate dateWithTimeInterval:(-MONTH_SAMPLE_NUM*indexMon * SECONDS_A_DAY) sinceDate:lastDate];
//                _drawList = [self filterMonthList:_rowList withCurDate:curDate];
            }
                break;
            case FILTER_TYPE_YEAR:
            {
                indexYear ++;
                NSDate* lastDate = [NSDate date];
                NSDateComponents *dtc = [NSDate dateCompFromDate:lastDate];
                int y = dtc.year;
                int sample_year;
                if (y % 400 == 0 || (y % 4 == 0 && y %100 != 0)) { //如果是闰年
                    sample_year = 366;
                } else sample_year = 365;
                _lastyearDate = [NSDate dateWithTimeInterval:(-sample_year*indexYear * SECONDS_A_DAY) sinceDate:lastDate];
                _drawList = [self filterYearList:_rowList withCurDate:_lastyearDate];
//                NSDate *curDate = [NSDate dateWithTimeInterval:(-sample_year*indexYear * SECONDS_A_DAY) sinceDate:lastDate];
//                _drawList = [self filterYearList:_rowList withCurDate:curDate];
            }
                break;
                
            default:
                break;
        }
        
    }
    
    [self removeAllSubViews];
    [self setNeedsDisplay];
}

-(void)removeAllSubViews
{
    for (UIView * view in [self subviews]) {
        [view removeFromSuperview];
    }
}


@end


@implementation SampleItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMultiVal = NO;
        _isNilVal = YES;
    }
    return self;
}

- (void)addVal:(ChartItem*) item{  //如果是周列表，在前某天如果只有一个值的话就会进入if，如果有多次测量，即有多个值，则代码一定在else中进行,可以找到最大值与最小值，中间值不取
    if (_isNilVal) {
        _minVal = item.val;
        _maxVal = item.val;
        _isNilVal = NO;
    }else{
        _minVal = MIN(_minVal, item.val);      //找最小值
        _maxVal = MAX(_maxVal, item.val);   //找最大值
        _isMultiVal = YES;
    }
}


@end

