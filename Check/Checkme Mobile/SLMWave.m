//
//  SLMWave.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SLMWave.h"
#import "NSDate+Additional.h"
#import "PublicMethods.h"
#import "Colors.h"

#define Gap_LeftTo_Wave 28.0f
#define Gap_BottomTo_Wave 30.0f
#define Gap_TopTo_Wave 5.0f
#define Gap_RightTo_Wave 20.0f
#define SAMPLE_PER_SCREEN 300.0 //一屏最多画300个Sample

@interface SLMWave()
@property (nonatomic,retain) SLMItem *item;

@property (nonatomic,assign) int sample_per_screen;
@property (nonatomic,assign) double sampleStep; //数据抽点距离
@property (nonatomic,assign) double originalStep;
@property (nonatomic,assign) int dataCount;


@property (nonatomic,assign)double leftPointIndex; //屏幕左侧点index
@property (nonatomic, assign) double midPointIndex;
@property (nonatomic,assign)double rightPointIndex; //屏幕右边点index
@property (nonatomic,assign)double minSPO2;//spo2最小值
@property (nonatomic,assign)double maxSPO2;//spo2最大值
@property (nonatomic,assign)double minPR;//PR最小值
@property (nonatomic,assign)double maxPR;//PR最大值

@property (nonatomic,assign)CGRect rectToDrawWave; //画波形区域
@property (nonatomic, assign) CGPoint contentScroll;
@property(nonatomic,retain) UIImageView* pressLine; //动态竖线
@property(nonatomic,retain) UIImageView* valueView; //竖线对应位置的值

@property (nonatomic,strong)NSArray *originalArr;
@property (nonatomic,retain) NSMutableArray* drawArray; //用于画图的Array(抽点后)
@end

@implementation SLMWave

static double Pix_Per_Spo2_Val = 0.0; //spo2每单位对应像素数
static double Pix_Per_Pr_Val = 0.0; //PR每单位对应像素数
static double Pix_Per_Time = 0.0; //每个时间单位对应像素数
static double PIX_Sep_y = 0.0; //每行高度
static double LineNum = 7; //行数

-(id)initWithFrame:(CGRect)frame dataItem:(SLMItem *)item
{
    if (!item.innerData) {
        return nil;
    }
    self = [self initWithFrame:frame];
    if(self)
    {
        self.item = item;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self initParameter];
        [self addGestureRecz];
    }
    return self;
}

//初始化固定参数
-(void)initParameter
{
    _dataCount = _item.innerData.arrOXValue.count;
    if (_dataCount < SAMPLE_PER_SCREEN) {
        _sample_per_screen = _dataCount;
    } else{ //如果点够多，一屏就画300个点
        _sample_per_screen = SAMPLE_PER_SCREEN;
    }
    _sampleStep = _dataCount/_sample_per_screen;
    _originalStep = _sampleStep;
    
    _rectToDrawWave = CGRectMake(Gap_LeftTo_Wave, Gap_TopTo_Wave, self.frame.size.width - Gap_LeftTo_Wave - Gap_RightTo_Wave, self.frame.size.height - Gap_TopTo_Wave - Gap_BottomTo_Wave);
   
    Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取点间隔
    PIX_Sep_y = _rectToDrawWave.size.height/LineNum;
    
    _minSPO2 = 65;
    _maxSPO2 = 100;
    _minPR = 30;
    _maxPR = 240;
    
    Pix_Per_Spo2_Val = _rectToDrawWave.size.height/(_maxSPO2 - _minSPO2);
    Pix_Per_Pr_Val = _rectToDrawWave.size.height/(_maxPR - _minPR);
    
    _viewingDetail = NO;
    
    //获取抽点后的数据
    _originalArr = [self getSampleArray:_item];
    _drawArray = [[self getDrawArray:_originalArr andSampleStep:_sampleStep] mutableCopy];
}
//获取SampleItem为元素的的链表(没有抽点)
-(NSArray*)getSampleArray:(SLMItem*)slmItem
{
    NSMutableArray* sampleArray = [NSMutableArray array];
    NSArray* spo2Array = slmItem.innerData.arrOXValue;
    NSArray* prArray = slmItem.innerData.arrPluseValue;
    
    for (int i=0; i<spo2Array.count; i++) {
        SLMSampleItem* sampleItem = [[SLMSampleItem alloc]initWithSPO2:[[spo2Array objectAtIndex:i] intValue] andPR:[[prArray objectAtIndex:i] intValue]];
        [sampleArray addObject:sampleItem];
    }
    
    return sampleArray;
}
//获取抽点后的sampleItem链表
-(NSArray*)getDrawArray:(NSArray*)inArray andSampleStep:(int)sampleStep
{
    NSMutableArray* outSampleArray = [NSMutableArray array];
    for (int i=0; i<inArray.count; i+=sampleStep) {    // count 48   step 5     inArr = sampleArr(48)
        SLMSampleItem* sampleItem = [self getDrawSample:inArray index:i withStep:sampleStep];
        [outSampleArray addObject:sampleItem];
    }
    return outSampleArray;  // count 10
}
//获取抽点后的sampleItem，spo2取最小，pr取平均
- (SLMSampleItem*) getDrawSample:(NSArray*)inArray index:(int)index withStep:(int)sampleStep{
    int minSPO2 = 0xFF, averagePR = 0;
    int sampleNum = 0;//中间有无效值时用到
    
    for (int i=index; i<MIN((index+sampleStep), inArray.count); i++) {
        SLMSampleItem* curRowSampleItem = [inArray objectAtIndex:i];
        if ([curRowSampleItem errSample]) {//如果输入item是无效值
            continue;
        }else{//正常值,则统计
            minSPO2 = MIN(minSPO2, [curRowSampleItem spo2]);
            averagePR += [curRowSampleItem pr];
            sampleNum ++;
        }
    }
    averagePR = (double)averagePR / (double)(MIN(sampleNum, sampleStep));
    SLMSampleItem* outSampleItem = [[SLMSampleItem alloc]initWithSPO2:minSPO2 andPR:averagePR];
    
    return outSampleItem;
}

//添加手势操作
-(void)addGestureRecz
{
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (_viewingDetail) {
        CGPoint point = [recognizer locationOfTouch:0 inView:self];
        [self drawDetailLine:point];
    }
}
//  每次重绘调用
- (void)refreshData
{
    [self removeAllSubViews];
    [self setNeedsDisplay];
}

static int Index = 0;    //静态整型变量Index
//  捏合手势
- (void) pinchAction:(UIGestureRecognizer *)sender
{
    if (!_viewingDetail) {
        CGFloat scale = [(UIPinchGestureRecognizer *)sender scale];
        if (sender.state == UIGestureRecognizerStateChanged) {
            if (scale >= 1.1) {  // 放大手势
                
                if (_sample_per_screen > 10) {  //一屏至少10个点
                    _sample_per_screen -= 3;    //每次放大屏幕的点减少3个
                    
                    //add      测试结果：
                    Index ++;
                    float b = 3*(Index-1)*Pix_Per_Time;
                    Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取点间隔
                    float a = 3*Index*Pix_Per_Time;
                    float c = a-b;   //波形漂移的总长度
                    
                    //求比例
                    float d = _rectToDrawWave.origin.x+_rectToDrawWave.size.width*0.5 - (Pix_Per_Time*0+_contentScroll.x+_rectToDrawWave.origin.x);    //偏移后的距离
                    float e = (_drawArray.count-1)*Pix_Per_Time;
//                    float d1 = e*0.5 - _contentScroll.x;
                    float f = d/e;
                    _contentScroll.x -= c*f ;   //整体左滑一定比例的距离
                    
                    [self refreshData];
                }
                
            }else {  // 缩小手势
                
                if (_dataCount >= SAMPLE_PER_SCREEN && _sample_per_screen < SAMPLE_PER_SCREEN) { // 最大不能大于一屏规定的点数  (数据源大于等于300个点时)
                    _sample_per_screen += 5;
                    if (Index > 0) {
                        Index --;
                    }
                    //add
                    float b = 5*(Index+1)*Pix_Per_Time;
                    Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取取点间隔
                    float a = 5*Index*Pix_Per_Time;
                    float c = b-a;
                    
                    //求比例
//                    float d = _rectToDrawWave.origin.x+_rectToDrawWave.size.width*0.5 - (Pix_Per_Time*0+_contentScroll.x+_rectToDrawWave.origin.x);
                    float e = (_drawArray.count-1)*Pix_Per_Time;
                    float d1 = e*0.5 - _contentScroll.x;
                    float f = d1/e;
                    
                    if (_contentScroll.x >= 0.0) {  //如果波形左边右移到了左边临界点
                        _contentScroll.x = 0.0;
                    }else if (_contentScroll.x < 0.0) {  //如果波形左边还未右移到左边临界点
                        if (_contentScroll.x+(_drawArray.count-1)*Pix_Per_Time+_rectToDrawWave.origin.x > CGRectGetMaxX(_rectToDrawWave)) { //如果波形右边还未左移到右边临界点
                            _contentScroll.x += c*f;  //整体右滑一定比例的距离
                        }else {   //如果波形右边左移到了右边临界点
                            _contentScroll.x += c;
                        }
                    }
                    [self refreshData];
                } else if (_dataCount < SAMPLE_PER_SCREEN && _sample_per_screen < _dataCount) {  // 最大不能大于一屏规定的点数  (数据源不足300个点时)
                    _sample_per_screen += 5;
                    if (Index > 0) {
                        Index --;
                    }
                    //add
                    float b = 5*(Index+1)*Pix_Per_Time;
                    Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;
                    float a = 5*Index*Pix_Per_Time;
                    float c = b-a;
                    
                    //求比例
                    float d = _rectToDrawWave.origin.x+_rectToDrawWave.size.width*0.5 - (Pix_Per_Time*0+_contentScroll.x+_rectToDrawWave.origin.x);
                    float e = (_drawArray.count-1)*Pix_Per_Time;
                    float f = d/e;
                    
                    if (_contentScroll.x >= 0.0) {  //如果波形左边右移到了左边临界点
                        _contentScroll.x = 0.0;
                    }else if (_contentScroll.x < 0.0) {  //如果波形左边还未右移到左边临界点
                        if (_contentScroll.x+(_drawArray.count-1)*Pix_Per_Time+_rectToDrawWave.origin.x > (_rectToDrawWave.origin.x+(_rectToDrawWave.size.width/SAMPLE_PER_SCREEN*_dataCount))) { //如果波形右边还未左移到右边临界点
                            _contentScroll.x += c*f;  //整体右滑一定不利的距离
                        }else {   //如果波形右边左移到了右边临界点
                            _contentScroll.x += c;
                        }
                    }
                    
                    [self refreshData];
                }
            }
        }
    }
}
//  双击手势
- (void)tapAction:(UIGestureRecognizer *)sender
{
    if (!_viewingDetail) {
        DLog(@"双击了！");
        
        if (_dataCount < SAMPLE_PER_SCREEN) { //数据源不足300个时
            if (_sample_per_screen == _dataCount) { //如果是满屏状态
                _sample_per_screen = _dataCount*0.4;  //双击后屏幕的点
                
                //add
                Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取取点间隔
                float b = (_dataCount*0.6)*Pix_Per_Time;
                _contentScroll.x = -b*0.5;
                Index += _dataCount*0.6/2;
                
            } else { //如果是非满屏状态 就变为满屏状态
                _sample_per_screen = _dataCount; //就变为满屏状态
                Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取取点间隔
                _contentScroll.x = 0.0;
                Index = 0;
            }
            [self refreshData];
            
        } else { //数据源大于等于300个时
            if (_sample_per_screen == SAMPLE_PER_SCREEN) {
                _sample_per_screen = SAMPLE_PER_SCREEN*0.4;
                
                //add
                Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取取点间隔
                float b = (SAMPLE_PER_SCREEN*0.6)*Pix_Per_Time;
                _contentScroll.x = -b*0.5;
                Index += SAMPLE_PER_SCREEN*0.6/2;
                
            } else {
                _sample_per_screen = SAMPLE_PER_SCREEN;
                Pix_Per_Time = _rectToDrawWave.size.width/_sample_per_screen;//x间距取取点间隔
                _contentScroll.x = 0.0;
                Index = 0;
            }
            [self refreshData];
        }
    }
}
/**画两条波形*/
-(void)drawWave
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // line1
    CGContextSetLineWidth(context, 1.3);
    CGContextSetStrokeColorWithColor(context, [LIGHT_GREEN CGColor]);
    CGContextBeginPath(context);
    bool preSampleErr = YES;//上一个点是无效点

    for (int i=0; i<_drawArray.count; i++) {
        SLMSampleItem* sampleItem = [_drawArray objectAtIndex:i];
        CGPoint point;
        
        point.x = i * Pix_Per_Time + _contentScroll.x;
        point.x += _rectToDrawWave.origin.x;
        point.y = ([sampleItem spo2] - _minSPO2)*Pix_Per_Spo2_Val;
        point.y = _rectToDrawWave.origin.y +  _rectToDrawWave.size.height - point.y;
        
        //左LBLindex
        if (ABS(point.x-_rectToDrawWave.origin.x)<Pix_Per_Time) {   //  ABS(a) = |a|    即a的绝对值
            _leftPointIndex = i;
        }
        
        if (ABS(point.x-(_rectToDrawWave.origin.x+_rectToDrawWave.size.width*0.5))<=Pix_Per_Time) {   //  ABS(a) = |a|    即a的绝对值
            _midPointIndex = i;
        }
        
        //右LBLindex
        if (ABS(point.x-(_rectToDrawWave.origin.x+_rectToDrawWave.size.width))<=Pix_Per_Time) {
            _rightPointIndex = i;
        }
        
        //判断当前点是否有效
        if ([sampleItem errSample]) {//无效点
            preSampleErr = YES;
            continue;
        }else{//有效点
            if (preSampleErr) {//如果上一个值无效，则点移动到最新有效点
                CGContextMoveToPoint(context, point.x, point.y);
            }else{//如果上一个值有效，从上一个点画到最新有效点
                CGContextAddLineToPoint(context, point.x, point.y);
            }
            preSampleErr = NO;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    // line2
    CGContextSetLineWidth(context, 1.3);
    CGContextSetStrokeColorWithColor(context, [LIGHT_BLUE CGColor]);
    CGContextBeginPath(context);
    preSampleErr = YES;//上一个点是无效点
    
    for (int i=0; i<_drawArray.count; i++) {
        SLMSampleItem* sampleItem = [_drawArray objectAtIndex:i];
        CGPoint point;
        
        //判断当前点是否有效
        if ([sampleItem errSample]) {//无效点
            preSampleErr = YES;
            continue;
        }else{//有效点
            point.x = i * Pix_Per_Time + _contentScroll.x;
            point.x += _rectToDrawWave.origin.x;
            point.y = ([sampleItem pr] - _minPR)*Pix_Per_Pr_Val;
            point.y = _rectToDrawWave.origin.y +  _rectToDrawWave.size.height - point.y;
            if (preSampleErr) {//如果上一个值无效，则点移动到最新有效点
                CGContextMoveToPoint(context, point.x, point.y);
            }else{//如果上一个值有效，从上一个点画到最新有效点
                CGContextAddLineToPoint(context, point.x, point.y);
            }
            preSampleErr = NO;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
}
//画横轴文字
-(void)drawHorizontalLabel
{
    double label_h = 15;
    double label_w = 60;
    
    NSDate* startDate = [[NSCalendar currentCalendar] dateFromComponents:self.item.dtcStartDate];
    //left(-1,warning,debug)!!!
    NSTimeInterval  interval = 2 * _sampleStep * (MAX(_leftPointIndex-1, 0) );//2秒一个点
    NSDate *currentDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    NSDateComponents *leftComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentDate];
    //right
    if((ABS(_contentScroll.x+(Pix_Per_Time*(_item.innerData.arrOXValue.count/(int)_sampleStep)-_rectToDrawWave.size.width))<=1)){
        //不放大或移到最右的时候右lbl为结束时间
        interval = _item.totalTime;
    }else{
        interval = 2 * _sampleStep * (_rightPointIndex-1);
    }
    currentDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    NSDateComponents *rightComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentDate];
    
    //中间时间   liqian add
    NSTimeInterval interval2 = 2 * _sampleStep * (_midPointIndex - 1);
    NSDate *currentDate2 = [NSDate dateWithTimeInterval:interval2 sinceDate:startDate];
    NSDateComponents *midComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentDate2];
    
    //  画label
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(_rectToDrawWave.origin.x -13, _rectToDrawWave.origin.y + _rectToDrawWave.size.height + 5, label_w, label_h)];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.numberOfLines = 0;
    lbl.text  = [NSString stringWithFormat:@"%@",[NSDate engDescOfDateComp:leftComponents][0]];
    lbl.textColor = DARK_BLUE;
    lbl.font = [UIFont systemFontOfSize:10];
    [self addSubview:lbl];
    
    //path足够长才画中间lbl
    if (_item.innerData.arrOXValue.count/(int)_sampleStep*Pix_Per_Time>=_rectToDrawWave.size.width*0.5) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(_rectToDrawWave.origin.x + _rectToDrawWave.size.width*0.5 - label_w*0.5 , _rectToDrawWave.origin.y + _rectToDrawWave.size.height + 5, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.numberOfLines = 0;
        lbl.text  = [NSString stringWithFormat:@"%@",[NSDate engDescOfDateComp:midComponents][0]];
        lbl.textColor = DARK_BLUE;
        lbl.font = [UIFont systemFontOfSize:10];
        [self addSubview:lbl];
    }
    
    //path足够长才画右边lbl
    if (_item.innerData.arrOXValue.count/(int)_sampleStep*Pix_Per_Time>=_rectToDrawWave.size.width) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(_rectToDrawWave.origin.x + _rectToDrawWave.size.width - label_w , _rectToDrawWave.origin.y + _rectToDrawWave.size.height + 5, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.numberOfLines = 0;
        lbl.text  = [NSString stringWithFormat:@"%@",[NSDate engDescOfDateComp:rightComponents][0]];
        lbl.textColor = DARK_BLUE;
        lbl.font = [UIFont systemFontOfSize:10];
        [self addSubview:lbl];
    }
    
    
}



//获取一段PR值中平均值，
-(int)getAveragePRValue:(int)index withStep:(int)sampleStep{
    int average = 0, dumpNum = 0;
    for (int i=index; i<(index+sampleStep); i++) {
        if (0xFF!=[[self.item.innerData.arrPluseValue objectAtIndex:i] intValue]) { // 0xFF(16)    1111 1111(2) = 256(10)
            average += [[self.item.innerData.arrPluseValue objectAtIndex:i] intValue];
        }else{
            dumpNum ++;
        }
    }
    if (dumpNum==sampleStep)
        return 0xFF;
    else
        return average/(sampleStep-dumpNum);
}

-(void)drawAxisLine
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, .5);
    CGContextSetStrokeColorWithColor(context, [LIGHT_GREY CGColor]);
    
    //绘制横向分割线
    for(double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height; y >= _rectToDrawWave.origin.y-5; )
    {
        CGContextBeginPath(context);
        double x = 0;
        x = _rectToDrawWave.origin.x;
        CGContextMoveToPoint(context, x, y);
        x = _rectToDrawWave.origin.x + _rectToDrawWave.size.width;
        CGContextAddLineToPoint(context, x, y);
        CGContextDrawPath(context, kCGPathStroke);
        y -= PIX_Sep_y;
        if(y <= _rectToDrawWave.origin.y)
        {
            y =  _rectToDrawWave.origin.y;
            CGContextBeginPath(context);
            double x = 0;
            x = _rectToDrawWave.origin.x;
            CGContextMoveToPoint(context, x, y);
            x = _rectToDrawWave.origin.x + _rectToDrawWave.size.width;
            CGContextAddLineToPoint(context, x, y);
            CGContextDrawPath(context, kCGPathStroke);
            break;
            
        }
    }
}

//画纵坐标
-(void)drawVerticalLabel
{
    //画方块，遮住path
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGRect rect = CGRectMake(0, 0, Gap_LeftTo_Wave, _rectToDrawWave.size.height+5);
    CGContextAddRect(ctx, rect);
    CGContextFillRect(ctx, rect);
    CGContextStrokeRect(ctx, rect);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    rect = CGRectMake(_rectToDrawWave.origin.x + _rectToDrawWave.size.width, 0, Gap_RightTo_Wave, _rectToDrawWave.size.height + 5);
    CGContextAddRect(ctx, rect);
    CGContextFillRect(ctx, rect);
    CGContextStrokeRect(ctx, rect);
    
    //左侧spo2坐标
    double label_h = 10;
    double label_w = Gap_LeftTo_Wave - 1;
    int val = 0;
    int i=0;
    for(double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height; y >= _rectToDrawWave.origin.y-5 ; )
    {
        double x = _rectToDrawWave.origin.x - label_w;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x -2 , y - label_h/2.0, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        if(i == 0)
            val = _minSPO2;
        else
            val += 5;
        lbl.text  = [NSString stringWithFormat:@"%d%%",val];
        lbl.textColor = LIGHT_GREEN;
        lbl.font = [UIFont systemFontOfSize:9];
        [self addSubview:lbl];
        
        y -= PIX_Sep_y,++i;
    }
    
    //右侧pr坐标
    i=0;
    val = 0;
    label_w = Gap_RightTo_Wave - 2;
    for(double y = _rectToDrawWave.origin.y + _rectToDrawWave.size.height; y >= _rectToDrawWave.origin.y-5 ; )
    {
        double x = _rectToDrawWave.origin.x + _rectToDrawWave.size.width;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x - 2 , y - label_h/2.0, label_w, label_h)];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.backgroundColor = [UIColor clearColor];
        if(i == 0)
            val = _minPR;
        else
            val += 30;
        lbl.text  = [NSString stringWithFormat:@"%d",val];
        lbl.textColor = LIGHT_BLUE;
        lbl.font = [UIFont systemFontOfSize:9];
        [self addSubview:lbl];
        y -= PIX_Sep_y,++i;
    }
}



-(void)removeAllSubViews
{
    for (UIView * view in [self subviews]) {
        [view removeFromSuperview];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_viewingDetail){
        CGPoint location = [[touches anyObject] locationInView:self];
        [self drawDetailLine:location];
    }else{
        CGPoint touchLocation=[[touches anyObject] locationInView:self];
        CGPoint prevouseLocation=[[touches anyObject] previousLocationInView:self];
        float xDiffrance=touchLocation.x-prevouseLocation.x;
        float yDiffrance=touchLocation.y-prevouseLocation.y;
        
        _contentScroll.x+=xDiffrance;
        _contentScroll.y+=yDiffrance;
        
        if (_contentScroll.x >0) {
            _contentScroll.x=0;
        }
        
        
        if (_dataCount < SAMPLE_PER_SCREEN && _sample_per_screen == _dataCount) {
            _contentScroll.x = 0.0;
        }
        if (_dataCount >= SAMPLE_PER_SCREEN && _sample_per_screen == SAMPLE_PER_SCREEN) {
            _contentScroll.x = 0.0;
        }
        if (-_contentScroll.x>(Pix_Per_Time*(_item.innerData.arrOXValue.count/(int)_sampleStep)-_rectToDrawWave.size.width)) {
            _contentScroll.x=-(Pix_Per_Time*(_item.innerData.arrOXValue.count/(int)_sampleStep)-_rectToDrawWave.size.width);
        }
        [self removeAllSubViews];
        [self setNeedsDisplay];
    }
}

-(void)drawDetailLine:(CGPoint) location
{
    //限制范围
    if (location.x > _rectToDrawWave.origin.x+MIN(_contentScroll.x+_drawArray.count*Pix_Per_Time, _rectToDrawWave.size.width)) {
        location.x = _rectToDrawWave.origin.x+MIN(_contentScroll.x+_drawArray.count*Pix_Per_Time, _rectToDrawWave.size.width);
    }else if(location.x < _rectToDrawWave.origin.x){
        location.x = _rectToDrawWave.origin.x;
    }
    //找到所在点
    int pressIndex;
    if (ABS(location.x-_rectToDrawWave.origin.x)<=1){
        pressIndex = _leftPointIndex;
    }else if(ABS(location.x-(_rectToDrawWave.origin.x+_rectToDrawWave.size.width))<=1){
        pressIndex = _rightPointIndex;
    }else{
        pressIndex = (location.x - _rectToDrawWave.origin.x - _contentScroll.x)/(_drawArray.count*Pix_Per_Time)*(_drawArray.count);
    }
    pressIndex = pressIndex > (_drawArray.count-1) ? (_drawArray.count-1) :pressIndex;
    DLog(@"pressIndex:%d",pressIndex);
    
    //画线
    [_pressLine removeFromSuperview];
    _pressLine = [[UIImageView alloc]initWithFrame:CGRectMake(location.x-1, _rectToDrawWave.origin.y, 1, _rectToDrawWave.size.height)];
    _pressLine.image = [UIImage imageNamed:@"press_line"];
    [_pressLine setAlpha:0.7];
    [self addSubview:_pressLine];
    //画label View
    [_valueView removeFromSuperview];
    double valueViewWidth = 50,valueViewHeight = 40;
    if (location.x -  valueViewWidth < 0) {//左边放不下则放右边
        _valueView = [[UIImageView alloc]initWithFrame:CGRectMake(location.x, _rectToDrawWave.origin.y, valueViewWidth, valueViewHeight)];
    }else{
        _valueView = [[UIImageView alloc]initWithFrame:CGRectMake(location.x-valueViewWidth, _rectToDrawWave.origin.y, valueViewWidth, valueViewHeight)];
    }
    //spo2
    UILabel* lblSPO2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, valueViewWidth, valueViewHeight/3)];
    lblSPO2.textColor = LIGHT_GREEN;
    lblSPO2.textAlignment = NSTextAlignmentCenter;
    lblSPO2.font = [UIFont systemFontOfSize:10];
    NSString* spo2Str;
    if ([(SLMSampleItem*)[_drawArray objectAtIndex:pressIndex] errSample]) {
        spo2Str = @"--";
    }else{
        spo2Str = [NSString stringWithFormat:@"%d%%",[(SLMSampleItem*)[_drawArray objectAtIndex:pressIndex] spo2]];
    }
    lblSPO2.text = spo2Str;
    [_valueView addSubview:lblSPO2];
    [self addSubview:_valueView];
    //pr
    UILabel* lblPR = [[UILabel alloc]initWithFrame:CGRectMake(0, 1*valueViewHeight/3, valueViewWidth,valueViewHeight/3)];
    lblPR.textColor = LIGHT_BLUE;
    lblPR.textAlignment = NSTextAlignmentCenter;
    lblPR.font = [UIFont systemFontOfSize:10];
    NSString* prStr;
    if ([(SLMSampleItem*)[_drawArray objectAtIndex:pressIndex] errSample]) {
        prStr = @"--";
    }else{
        prStr = [NSString stringWithFormat:@"%d/min",[(SLMSampleItem*)[_drawArray objectAtIndex:pressIndex] pr]];
    }
    lblPR.text = prStr;
    [_valueView addSubview:lblPR];
    [self addSubview:_valueView];
    //time 计算当前点时间
    NSCalendar *defaultCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* startDate = [defaultCalender dateFromComponents:self.item.dtcStartDate];
    NSTimeInterval  interval;
    if (pressIndex==_drawArray.count-1) {//右边强制显示与横坐标lbl一样
        //            NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:_item.dtcEndDate];
        //            interval = [endDate timeIntervalSinceDate:startDate];
        interval = _item.totalTime;
    }else{
        //-1,warning,debug!!!
        interval = 2 * _sampleStep * MAX((pressIndex -1), 0);//2秒一个点
    }
    
    NSDate *currentDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    NSDateComponents *pressComponents = [defaultCalender components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentDate];
    //time label
    UILabel* lblTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*valueViewHeight/3, valueViewWidth,valueViewHeight/3)];
    lblTime.textColor = DARK_BLUE;
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.font = [UIFont systemFontOfSize:10];
    NSString* timeStr = [NSDate engDescOfDateComp:pressComponents][0];
    lblTime.text = timeStr;
    [_valueView addSubview:lblTime];
    [self addSubview:_valueView];

}

/*
 *画图部分
 */
-(void) drawRect:(CGRect)rect
{
    [self drawAxisLine];
    [self drawWave];
    [self drawVerticalLabel];
    [self drawHorizontalLabel];
}

-(void)viewDetail
{
    _viewingDetail = YES;
    CGPoint point = CGPointMake(_rectToDrawWave.origin.x + _rectToDrawWave.size.width/2, 0);
    [self drawDetailLine:point];
}

-(void)hideDetail
{
    _viewingDetail = NO;
    [self removeAllSubViews];
    [self setNeedsDisplay];
}

-(void)onBnViewDetailClicked
{
    if (_viewingDetail) {
        [self hideDetail];
    }else{
        [self viewDetail];
    }
}

@end

@implementation SLMSampleItem

- (instancetype)initWithSPO2:(int)spo2 andPR:(int)pr
{
    self = [super init];
    if (self) {
        _spo2 = spo2;
        _pr = pr;
        if (spo2==0xFF || pr==0xFF) {
            _errSample = YES;
        }else{
            _errSample = NO;
        }
    }
    return self;
}

@end
