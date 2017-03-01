//
//  SLMAlbumView.m
//  Checkme Mobile
//
//  Created by Lq on 15-1-7.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SLMAlbumView.h"
#import "AlbumHeader.h"
#import "SleepMonitorInfoData.h"
#import "NSDate+Additional.h"

@interface SLMAlbumView ()
@property (nonatomic, strong) SLMItem *slmItem;
@property (nonatomic, strong) SleepMonitorInfoData *slmInfoView;
@end

@implementation SLMAlbumView
{
    CGRect referenceRect;  //整个画图部分的参考坐标
    CGRect spo2Rect;  //spo2部分
    CGRect prRect;   //pr部分
    CGSize UnitLabelSize;   // 纵坐标单位
    CGSize y_axis_labelSize;   // 纵坐标
    CGSize x_axis_labelSize;   //横坐标
    
    float x_space;   //横坐标两点的间距
    float y_space;  //纵坐标两根线的间距
    int line_leftPoint_x;   //横线最左侧点x坐标
    float line_rightPoint_x;  //横线最右侧点x坐标
    float points_per_second;   //1s对应的point点数
    
    int multiples;  //抽点倍数
    NSMutableArray *new_pr_contentArr;   //抽点后的pr数据
    
    CGPoint Spo2PointMax;
    CGPoint Spo2PointMin;
    CGPoint prPointMax;
    CGPoint prPointMin;
}

- (id) initWithFrame:(CGRect)frame andSLMItem:(SLMItem *)item
{
    self = [super initWithFrame:frame];
    if (self) {
        _slmItem = item;
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;

        [self initLogo];
        [self initSLMInfoView];
        [self initPrameter];
    }
    return self;
}

//ssh  三大框架  struts+spring+hibernate   struts2 （java语言） spring   hibernate
//logo 图标的显示
- (void) initLogo
{
    UILabel *report = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding*0.5, padding*2.0, padding*0.5)];
    report.text = DTLocalizedString(@"Report", nil);
    report.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:report];
    //logo
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(whole_width - 2.5*padding, padding*0.5, 1.5*padding, padding*0.5)];
    UIImage *logo = [UIImage imageNamed:@"viatom_logo.png"];
    if ([curCountry isEqualToString:@"JP"] && [curLanguage isEqualToString:@"ja"]) {   //如果是日本的
        logo = [UIImage imageNamed:@"sanrong_logo.png"];
    }
    if (isThomson == YES) {  //如果是法国定制版
        logo = [UIImage imageNamed:@"thomson_logo1.png"];
    }
    if (isThomson == YES) {  //如果是法国定制版
        logo = [UIImage imageNamed:@"semacare_logo1.png"];
    }
    
    imageV.image = logo;
    [self addSubview:imageV];
}
- (void) initSLMInfoView
{
    _slmInfoView = [[[NSBundle mainBundle] loadNibNamed:@"SleepMonitorInfoData" owner:self options:nil] lastObject];
    CGRect rect = _slmInfoView.frame;
    rect.origin.x = padding;
    rect.origin.y = padding;
    _slmInfoView.frame = rect;
    
    _slmInfoView.measuringMode.text = DTLocalizedString(@"Sleep Monitor", nil);//睡眠
    
    // date/time
    NSArray *startDateArr = [NSDate engDescOfDateComp:_slmItem.dtcStartDate];
    // laterDate
    //开始时间
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:_slmItem.dtcStartDate];
    //结束时间
    NSDate *endDate = [NSDate dateWithTimeInterval:+_slmItem.totalTime sinceDate:startDate];
    NSDateComponents *com = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:endDate];
    NSArray *laterDateArr  = [NSDate engDescOfDateComp:com];
    _slmInfoView.dateTime.text = [NSString stringWithFormat:@"%@ %@ ~%@ %@", startDateArr[1], startDateArr[0], laterDateArr[1], laterDateArr[0]];
    
    // totalTime
    //时间值的转换
    int h = _slmItem.totalTime/3600;
    int m = (_slmItem.totalTime%3600)/60;
    int s = (_slmItem.totalTime%3600)%60;
    if (h==0) {
        _slmInfoView.totalDur.text = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
    }else {
        _slmInfoView.totalDur.text = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
    }
    
    NSString *drop;
    NSString *dropTime;
    drop = [INT_TO_STRING(_slmItem.LO2Count) stringByAppendingString:DTLocalizedString(@"drop", nil)];
    //跌落时间
    h = _slmItem.LO2Time/3600;
    m = (_slmItem.LO2Time - h*3600)/60;
    s = _slmItem.LO2Time - m*60 - h*3600;
    if (h==0) {
        dropTime = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
    }else {
        dropTime = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
    }
    _slmInfoView.sata.text = [NSString stringWithFormat:@"%@, %@", drop, dropTime];
    _slmInfoView.average.text = [INT_TO_STRING_WITHOUT_ERR_NUM(_slmItem.AverageSpo2) stringByAppendingString:@"%"];
    _slmInfoView.lowest.text = [INT_TO_STRING_WITHOUT_ERR_NUM(_slmItem.LO2Value) stringByAppendingString:@"%"];
    //诊断结果
    if(_slmItem.LO2Count!=0){
        _slmInfoView.info.text = DTLocalizedString(@"Blood Oxygen drops detected", nil);
    }else if(_slmItem.enPassKind==kPassKind_Pass){
        _slmInfoView.info.text = DTLocalizedString(@"No abnormalities detected", nil);
    }else{
        _slmInfoView.info.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    
    [self addSubview:_slmInfoView];
}
- (void) initPrameter
{
    referenceRect = CGRectMake(padding, CGRectGetMaxY(_slmInfoView.frame) + padding*0.5, wave_width, whole_height - CGRectGetMaxY(_slmInfoView.frame) - padding*1.5);
    spo2Rect = CGRectMake(padding, referenceRect.origin.y, wave_width, referenceRect.size.height*0.5-padding*0.25);
    prRect = CGRectMake(padding, CGRectGetMaxY(spo2Rect)+padding*0.5, wave_width, spo2Rect.size.height);
    UnitLabelSize = CGSizeMake(padding, padding*0.38);
    y_axis_labelSize = CGSizeMake(padding*0.42, padding*0.2);
    x_axis_labelSize = CGSizeMake(padding*0.4, padding*0.38);
}



//画spo2坐标轴
- (void) drawSpO2CoordinateAxis
{
    line_leftPoint_x = padding+y_axis_labelSize.width;
    line_rightPoint_x = CGRectGetMaxX(_slmInfoView.frame);
    x_space = (line_rightPoint_x - line_leftPoint_x)/10;
    points_per_second = x_space/(60.0*60);
    
    Spo2PointMax = CGPointMake(line_leftPoint_x, spo2Rect.origin.y+UnitLabelSize.height+y_axis_labelSize.height*0.5);
    Spo2PointMin = CGPointMake(Spo2PointMax.x, CGRectGetMaxY(spo2Rect)-x_axis_labelSize.height);   //
    y_space = (Spo2PointMin.y - Spo2PointMax.y)/7;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    int index = 0;
    for (float i = Spo2PointMin.y; i > Spo2PointMax.y-(y_space*0.05); i -= y_space) {
        //画坐标线
        [path moveToPoint:CGPointMake(Spo2PointMin.x, i)];
        [path addLineToPoint:CGPointMake(line_rightPoint_x, i)];
        
        // 添加y轴纵坐标值
        UILabel *yLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, i-y_axis_labelSize.height*0.5, y_axis_labelSize.width, y_axis_labelSize.height)];
        
        yLabel.text = [[NSString stringWithFormat:@"%d", 65 + index*5] stringByAppendingString:@"%"];
        yLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:yLabel];
        index ++;
    }
    path.lineWidth = 0.8;
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
    
    //添加spo2单位
    UILabel *spo2Unit = [[UILabel alloc] initWithFrame:CGRectMake(padding, spo2Rect.origin.y, UnitLabelSize.width, UnitLabelSize.height)];
    spo2Unit.text = @"SPO2(%)";
    spo2Unit.font = [UIFont systemFontOfSize:9];
    [self addSubview:spo2Unit];
    
    //添加x轴坐标标注值
    [self addXaxisWithPointy:Spo2PointMin.y];
}
//画PR坐标轴
- (void) drawPRCoordinateAxis
{
    prPointMax = CGPointMake(line_leftPoint_x, CGRectGetMaxY(spo2Rect)+padding*0.5+UnitLabelSize.height-y_axis_labelSize.height*0.5);
    prPointMin = CGPointMake(prPointMax.x, CGRectGetMaxY(prRect) - x_axis_labelSize.height);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    int index = 0;
    for (float i = prPointMin.y; i > prPointMax.y - (y_space*0.05); i -= y_space) {
        //画坐标线
        [path moveToPoint:CGPointMake(prPointMin.x, i)];
        [path addLineToPoint:CGPointMake(line_rightPoint_x, i)];
        
        //  添加y轴纵坐标间隔值
        UILabel *yLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, i-y_axis_labelSize.height*0.5, y_axis_labelSize.width, y_axis_labelSize.height)];
        
        yLabel.text = [NSString stringWithFormat:@"%d", 30 + index*30];
        yLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:yLabel];
        index ++;
    }
    path.lineWidth = 0.8;
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
    
    //添加pr单位
    UILabel *prUnit = [[UILabel alloc] initWithFrame:CGRectMake(padding, prRect.origin.y, UnitLabelSize.width, UnitLabelSize.height)];
    prUnit.text = @"PR(min)";
    prUnit.font = [UIFont systemFontOfSize:9];
    [self addSubview:prUnit];
    
    //添加x轴标注值
    [self addXaxisWithPointy:prPointMin.y];
}

//添加x轴坐标值
- (void) addXaxisWithPointy:(float)pointy
{
    NSDate *firstDate ;   //第一个标注值的时间
    float firstPoint_x;  // 第一个标注值的x坐标
    int y = _slmItem.dtcStartDate.year;
    int mon = _slmItem.dtcStartDate.month;
    int d = _slmItem.dtcStartDate.day;
    int h = _slmItem.dtcStartDate.hour;
    int m = _slmItem.dtcStartDate.minute;
    int s = _slmItem.dtcStartDate.second;
    
    if (m == 0 && s == 0) { //如果开始时间是整点
        firstPoint_x = line_leftPoint_x;
        firstDate = [[NSCalendar currentCalendar] dateFromComponents:_slmItem.dtcStartDate];
    }else {  // 不是整点
        if ([self isLastDayInThisMonthWithDay:d month:mon andYear:y]) { //如果是这个月最后一天
            if (mon != 12 && h == 23) { //非12月份最后一个小时
                mon = mon + 1;
                d = 1;
                h = 0;
            } else if (mon == 12 && h == 23) { //一年最后一个月 即12月份
                y = y + 1;
                mon = 1;
                d = 1;
                h = 0;
            }
        }else {  //其他任何不是整点的时段
            h = (h+1)==24?0:(h+1);
        }
        //整点的时间
        NSString *dateStr = [NSString stringWithFormat:@"%d-%d-%d %d:00:00", y, mon, d, h];
        NSDate *interalDate = [NSDate dateFromString:dateStr formatterStr:@"yyyy-MM-dd HH:mm:ss"];
        //起始的时间
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:_slmItem.dtcStartDate];
        //间隔的时间
        int secondsInteval = [interalDate timeIntervalSinceDate:startDate];    // 起始时间到第一个整点的秒数
        float interalPoint_x = line_leftPoint_x + secondsInteval *points_per_second;   //第一个整点的x坐标值
        firstPoint_x = interalPoint_x;
        firstDate = interalDate;  //画第一个整点的时间qv
    }
    
    int index = 0;
    for (float i = firstPoint_x; i < line_rightPoint_x; i += x_space) {
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(i, pointy - 2, 1, 2.8)];
        pointLabel.backgroundColor = [UIColor blackColor];
        [self addSubview:pointLabel];

        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(i, pointy, x_axis_labelSize.width, x_axis_labelSize.height)];
        CGRect rect = xAxisLabel.frame;
        if (CGRectGetMaxX(rect) > line_rightPoint_x) {
            rect.origin.x -= (CGRectGetMaxX(rect) - line_rightPoint_x);
            xAxisLabel.frame = rect;
        }
        xAxisLabel.text = [self dateStrFromDate:firstDate WithTimeinterval:index * (60*60)];
        xAxisLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:xAxisLabel];
        index ++;
    }
}
//   时间转字符串
- (NSString *) dateStrFromDate:(NSDate *)startDate WithTimeinterval:(NSTimeInterval)timeInterval
{
    NSDate *laterDate = [NSDate dateWithTimeInterval:+timeInterval sinceDate:startDate];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"HH:mm"];
    return [formater stringFromDate:laterDate];
}
//   判断当前日是否是该月最后一天
- (BOOL) isLastDayInThisMonthWithDay:(int)d month:(int)mon andYear:(int)y
{
    BOOL isLastDay = NO;
    
    if (mon == 1 || mon == 3 || mon == 5 || mon == 7 || mon == 8 || mon == 10 || mon == 12) {
        if (d == 31) {
            isLastDay = YES;
        }
    }
    
    if (mon == 4 || mon == 6 || mon == 9 || mon == 11) {
        if (d == 30) {
            isLastDay = YES;
        }
    }
    
    if (mon == 2) {  //如果是2月
        if (y % 400 == 0 || (y % 4 == 0 && y % 100 != 0)) {// 如果是闰年
            if (d == 29) {
                isLastDay = YES;
            }
        } else {  //平年
            if (d == 28) {
                isLastDay = YES;
            }
        }
    }
    return isLastDay;
}


#define seconds_per_value 2.0     // 系统每2秒给一个值
#define newSeconds_per_value 100.0    //自定义每100秒取一个值

// 画spo2波形
- (void) drawSPO2Wave
{
    multiples = newSeconds_per_value/seconds_per_value;  // 抽点倍数
    NSMutableArray *spo2_contentArr = [_slmItem.innerData.arrOXValue mutableCopy];
    NSMutableArray *pr_contentArr = [_slmItem.innerData.arrPluseValue mutableCopy];
    
    NSMutableArray *new_spo2_contentArr = [NSMutableArray array];
    new_pr_contentArr = [NSMutableArray array];
    
    
    //找出spo2最小的那个值  和它对应的PR值
    while (spo2_contentArr.count >= multiples) {
        int index = 0;
        for (int i = 0; i < multiples; i ++) {
            if ([spo2_contentArr[index] integerValue] > [spo2_contentArr[i] integerValue]) {
                index = i;
            }
        }
        [new_spo2_contentArr addObject:spo2_contentArr[index]];
        [new_pr_contentArr addObject:pr_contentArr[index]];
        
        [spo2_contentArr removeObjectsInRange:NSMakeRange(0, multiples)];
        [pr_contentArr removeObjectsInRange:NSMakeRange(0, multiples)];
    }
    //比较剩下的不足 multiples个的元素
    if (spo2_contentArr.count != 0) {
        int index2 = 0;
        for (int i = 0; i < spo2_contentArr.count; i ++) {
            if ([spo2_contentArr[index2] integerValue] > [spo2_contentArr[i] integerValue]) {
                index2 = i;
            }
        }
        [new_spo2_contentArr addObject:spo2_contentArr[index2]];
        [new_pr_contentArr addObject:pr_contentArr[index2]];
        [spo2_contentArr removeAllObjects];
        [pr_contentArr removeAllObjects];
    }

    
    
    

    UIBezierPath *path = [UIBezierPath bezierPath];
    float points_per_val = y_space/5;     //两根线的间隔值为5      纵坐标一个值对应的point点数

    // 新画线方法
    BOOL err_Value = YES;      //无效值
    for (int i = 0; i < new_spo2_contentArr.count; i ++) {
        CGPoint point;
        point.x = Spo2PointMin.x + (multiples*seconds_per_value*points_per_second) * i;
        point.y = Spo2PointMin.y - ([new_spo2_contentArr[i] integerValue])*points_per_val + 65*points_per_val;
        
        if ([new_spo2_contentArr[i] integerValue] == 0xff) {  //如果数组中的点为无效值
            err_Value = YES;
            continue;
        } else {  //如果数组中的点为有效值
            if (err_Value == YES) { //如果前一个点为无效值
                [path moveToPoint:point];
            }else { //如果前一个值是有效值
                [path addLineToPoint:point];
            }
            err_Value = NO;
        }
    }
    
    path.lineWidth = 0.8;
    [[UIColor blackColor] setStroke];
    [path stroke];
}
// 画PR波形     加入无效值辨别 无效则不画
- (void) drawPRWave
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    float points_per_val = y_space/30;
    BOOL err_Value = YES;
    for (int i = 0; i < new_pr_contentArr.count; i ++) {
        CGPoint point ;
        point.x = prPointMin.x + (multiples*seconds_per_value*points_per_second) * i;
        point.y = prPointMin.y - ([new_pr_contentArr[i] integerValue])*points_per_val + 30 * points_per_val;
        
        if ([new_pr_contentArr[i] integerValue] == 0xff) {
            err_Value = YES;
            continue;
        } else { //为有效值
            if (err_Value == YES) { // 前一个点为无效值
                [path moveToPoint:point];
            } else { //前一个值是有效值
                [path addLineToPoint:point];
            }
            err_Value = NO;
        }
    }
    
    path.lineWidth = 0.8;
    [[UIColor blackColor] setStroke];
    [path stroke];
}


- (void) drawRect:(CGRect)rect
{
    [self drawSpO2CoordinateAxis];
    [self drawPRCoordinateAxis];
    [self drawSPO2Wave];
    [self drawPRWave];
}

@end
