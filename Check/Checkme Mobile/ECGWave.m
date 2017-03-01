//
//  ECGWave.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-7.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "ECGWave.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "ECGDetailWave.h"

//标尺
#define Ruler_Width_Top_Pix 5
#define Ruler_Width_Middle_Pix 10
#define Ruler_Width_Total_Pix (Ruler_Width_Middle_Pix + 2.0*Ruler_Width_Top_Pix)

@interface ECGWave()

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) ECGInfoItem *ecgItem;

@property (nonatomic,retain) Xuser *curXuser;
@property (nonatomic,retain) SpotCheckItem *spcItem;
@property (nonatomic) BOOL isSpc;

@property (nonatomic,assign) id<EcgWaveViewDelegate> delegate;

//红色选中框
@property (nonatomic,retain) UILabel *lblCubic_L;
@property (nonatomic,retain) UILabel *lblCubic_U;
@property (nonatomic,retain) UILabel *lblCubic_R;
@property (nonatomic,retain) UILabel *lblCubic_B;

@property (nonatomic,retain) UIButton *btnVoice;
@property (nonatomic,retain) UILabel *lblUserName;
@end

@implementation ECGWave

//全局静态变量
double PIX_per_mv = 0;
double X_axis_from_top = 0;
double Pix_Per_second_Row_First = (320.0 - 2.0*Ruler_Width_Top_Pix - Ruler_Width_Middle_Pix)/5.0;
double Pix_Per_second_Row_Others = (320.0)/5.0;
double average_wave_h_pix = 0;
double pix_val_h;
double rulerScale;//标尺等级
int samplePerNum = 5;//抽点距离
int callerType = -1;
double minValue=0,maxValue=0;

@synthesize curUser = _curUser;
@synthesize ecgItem = _ecgItem;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame user:(User *)aUser ecgItem:(ECGInfoItem *)aItem callerType:(int)type delegate:(id<EcgWaveViewDelegate>)del
{
    self = [self initWithFrame:frame];
    if(self)
    {
        _curUser = aUser;
        _ecgItem = aItem;
        _isSpc = NO;
        
        _delegate = del;
        callerType = type;
        [self addGestureRec];
        [self initParameter];
        self.backgroundColor = COLOR_RGB(239,239,239,1.0);
        self.opaque = NO;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame xUser:(Xuser *)xUser spcItem:(SpotCheckItem *)spcItem callerType:(int)type delegate:(id<EcgWaveViewDelegate>)del
{
    self = [self initWithFrame:frame];
    if (self) {
        _curXuser = xUser;
        _spcItem = spcItem;
        _isSpc = YES;
        
        _delegate = del;
        callerType = type;
        [self addGestureRec];
        [self initParameter];
        self.backgroundColor = COLOR_RGB(239,239,239,1.0);
        self.opaque = NO;
    }
    return self;
}

/**
 *  添加手势监听
 */
-(void)addGestureRec
{
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
    rec.numberOfTapsRequired = 1;
    [self addGestureRecognizer:rec];
}

/**
 *  初始化参数
 */
-(void)initParameter
{
    [self calMinAndMax];
    [self calRulerScale:maxValue minVal:minValue];
    average_wave_h_pix = self.frame.size.height/(_isSpc ? (_spcItem.innerData.timeLength/5.0) : (_ecgItem.innerData.timeLength/5.0));
    PIX_per_mv = average_wave_h_pix*0.7/rulerScale; //每个毫伏对应的像素数,每行占0.7
    double val_h_mv = 0,x_axis_y_mv_fromtop = 0;//波形高度,毫伏距顶距离
    if(maxValue>=0 && minValue>=0)
    {
        val_h_mv = maxValue;
        //x轴在最底端
        x_axis_y_mv_fromtop = average_wave_h_pix;
    }
    else if(maxValue>0 && minValue<0)
    {
        val_h_mv = maxValue + -1*(minValue);
        //x轴在max_val处
        x_axis_y_mv_fromtop = maxValue;
    }
    else if(maxValue<0 && minValue<0)
    {
        val_h_mv = -1*(minValue);
        //x轴在最顶端
        x_axis_y_mv_fromtop = 0;
    }
    //坐标距顶距离（下移，不顶行）
    X_axis_from_top = x_axis_y_mv_fromtop*PIX_per_mv+0.2*average_wave_h_pix;
    //波形像素高度
    pix_val_h = val_h_mv*PIX_per_mv;
}

/**
 *  计算最大最小值
 */
-(void)calMinAndMax
{
    [PublicMethods findMaxVal:&maxValue minVal:&minValue inArr:(_isSpc ? _spcItem.innerData.arrEcgContent : _ecgItem.innerData.arrEcgContent)];
    //超出范围去范围值
    maxValue = maxValue>2 ? 2 : maxValue;
    minValue = minValue<-2 ? -2 :minValue;
}

/**
 *  计算标尺等级
 *
 *  @param max
 *  @param min
 */
- (void)calRulerScale:(double)max minVal:(double)min{
    double waveHeight = max - min;

    if (waveHeight <1){
        rulerScale = 1;
    }else if (waveHeight<2){
        rulerScale = 2;
    }else{
        rulerScale = 4;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect waveRect;
    NSArray *arrDraw;
    NSRange range = NSMakeRange(0, 0);
    
    //时间，带宽信息
    double lblWidth;
    UILabel *lbl;
    //时间
    lblWidth = 180;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - (lblWidth),self.frame.size.height-20.0, lblWidth, 20.0)];
    lbl.textAlignment = NSTextAlignmentRight;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor grayColor];
    lbl.font = [UIFont systemFontOfSize:13];
    NSString *strTime = [NSString stringWithFormat:@"%@ %@",[NSDate engDescOfDateComp:(_isSpc ? _spcItem.dtcDate : _ecgItem.dtcDate)][0],[NSDate engDescOfDateComp:(_isSpc ? _spcItem.dtcDate : _ecgItem.dtcDate)][1]];
    lbl.text = strTime;
    [self addSubview:lbl];
    
    //每行分割线
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [COLOR_RGB(192, 192, 192, 1.0) CGColor]);
    for(int i=0;i<(_isSpc ? (_spcItem.innerData.timeLength/5.0) : _ecgItem.innerData.timeLength/5.0);++i)//每行5s
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context,0,i*average_wave_h_pix);
        CGContextAddLineToPoint(context, CUR_SCREEN_W, i*average_wave_h_pix);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    //标尺
    double rulerPixOffset = 20;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, average_wave_h_pix - rulerPixOffset);
    CGContextAddLineToPoint(context, Ruler_Width_Top_Pix, average_wave_h_pix - rulerPixOffset);
    CGContextAddLineToPoint(context, Ruler_Width_Top_Pix, average_wave_h_pix - rulerPixOffset - 1*PIX_per_mv );
    CGContextAddLineToPoint(context, Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix, average_wave_h_pix - rulerPixOffset - 1*PIX_per_mv );
    CGContextAddLineToPoint(context, Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix, average_wave_h_pix - rulerPixOffset);
    CGContextAddLineToPoint(context,  2.0*Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix, average_wave_h_pix - rulerPixOffset);
    CGContextDrawPath(context, kCGPathStroke);
    
    //标尺文字
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,average_wave_h_pix-20,40, 20.0)];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor grayColor];
    lbl.font = [UIFont systemFontOfSize:11];
    lbl.text = [NSString stringWithFormat:@"%dmV",1];
    [self addSubview:lbl];
    
    //波形,画第一行
    int total_data_num = _isSpc ? _spcItem.innerData.arrEcgContent.count : _ecgItem.innerData.arrEcgContent.count;
    int left  =  total_data_num;
    int num_each_time = 0;
    int first_time_num = 0;
    first_time_num = num_each_time = (int)(total_data_num * (5.0/(_isSpc ? _spcItem.innerData.timeLength : _ecgItem.innerData.timeLength)));
    int length = 0 ;
    int index_l =  0;
    length = num_each_time;
    length = MIN(length, total_data_num);
    left -= length;
    range = NSMakeRange(index_l, length);
    arrDraw = [(_isSpc ? _spcItem.innerData.arrEcgContent : _ecgItem.innerData.arrEcgContent) subarrayWithRange:range];
    waveRect = CGRectMake(2.0*Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix, 0, CUR_SCREEN_W-(2.0*Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix), pix_val_h);
    [self drawWaveInContext:context rect:waveRect  pixPerSecond:Pix_Per_second_Row_First  x_axis_pos:X_axis_from_top valueArr:arrDraw];
    
    //画剩余的行
    for(int i = 0;i<(_isSpc ? _spcItem.innerData.timeLength : _ecgItem.innerData.timeLength)/5.0-1 && left > 0;i++)
    {
        num_each_time = (int)(total_data_num * (5.0/(_isSpc ? _spcItem.innerData.timeLength : _ecgItem.innerData.timeLength)));
        
        index_l = first_time_num + i * num_each_time ;
        length = num_each_time;
        range = NSMakeRange(index_l,length);
        arrDraw = [(_isSpc ? _spcItem.innerData.arrEcgContent : _ecgItem.innerData.arrEcgContent) subarrayWithRange:range];
        waveRect = CGRectMake(0,(i+1)*average_wave_h_pix, CUR_SCREEN_W, pix_val_h);
        [self drawWaveInContext:context rect:waveRect pixPerSecond:Pix_Per_second_Row_Others x_axis_pos:X_axis_from_top valueArr:arrDraw];
    }
}

/**
 *  波形绘制
 *
 *  @param context
 *  @param rect
 *  @param pixPerSecond
 *  @param x_axis_pos
 *  @param valueArr
 */
-(void)drawWaveInContext:(CGContextRef)context rect:(CGRect)rect pixPerSecond:(double)pixPerSecond x_axis_pos:(double)x_axis_pos valueArr:(NSArray *)valueArr
{
    if(valueArr.count <= 0)
        return;
    CGContextBeginPath(context);
    NSNumber *num = [valueArr objectAtIndex:0];
    double val = num.doubleValue;
    CGContextMoveToPoint(context,rect.origin.x ,rect.origin.y + x_axis_pos - val*PIX_per_mv);
    
    int totalDrawSampleNum = valueArr.count/samplePerNum;
    CGPoint *pointList =  (CGPoint *)malloc(sizeof(CGPoint) * totalDrawSampleNum);
    
    if(NULL == pointList)
    {
        DBG(@"pointList Memory Fail");
        return;
    }
    
    for(int i = 0,j=0;j<totalDrawSampleNum;i+=samplePerNum,j++)
    {
        num = [valueArr objectAtIndex:i];
        val = num.doubleValue;
        double x = rect.origin.x + ((i)/ECG_DATA_COLLECT_HZ)*pixPerSecond;
        double y = rect.origin.y + x_axis_pos - val*PIX_per_mv;
        pointList[j].x = x;
        pointList[j].y = y;
        
    }
    CGContextAddLines(context, pointList, totalDrawSampleNum);
    free(pointList);
    CGContextDrawPath(context, kCGPathStroke);
}

//画红色选中框
-(void)drawCubicAtStart:(double)startSecod end:(double)endSecond row:(int)rowIndex
{
    double base_x = 0;
    double base_y = 0;
    double offset_y = 0;
    double line_width = 1.0;
    
    double line_length_l = average_wave_h_pix - offset_y*2.0;
    double line_length_u = (endSecond - startSecod)*(rowIndex == 0?Pix_Per_second_Row_First :Pix_Per_second_Row_Others);
    double line_length_r = line_length_l;
    double line_length_b = line_length_u;
    
    double o_x=0,o_y=0;
    base_y = rowIndex*average_wave_h_pix ;
    o_y = base_y + offset_y;
    if(rowIndex == 0)
    {
        base_x = Ruler_Width_Total_Pix;
        o_x = base_x + startSecod*Pix_Per_second_Row_First;
    }
    else
    {
        base_x = 0;
        o_x = base_x + startSecod*Pix_Per_second_Row_Others;
    }
    
    if(_lblCubic_B.superview)
        [_lblCubic_B removeFromSuperview];
    if(_lblCubic_U.superview)
        [_lblCubic_U removeFromSuperview];
    if(_lblCubic_L.superview)
        [_lblCubic_L removeFromSuperview];
    if(_lblCubic_R.superview)
        [_lblCubic_R removeFromSuperview];
    
    self.lblCubic_L = [[UILabel alloc] initWithFrame:CGRectMake(o_x, o_y, line_width, line_length_l)];
    self.lblCubic_L.backgroundColor = [UIColor redColor];
    [self addSubview:self.lblCubic_L];
    
    self.lblCubic_R = [[UILabel alloc] initWithFrame:CGRectMake(o_x + line_length_u-line_width, o_y, line_width, line_length_r)];
    self.lblCubic_R.backgroundColor = [UIColor redColor];
    [self addSubview:self.lblCubic_R];
    
    self.lblCubic_U = [[UILabel alloc] initWithFrame:CGRectMake(o_x, o_y, line_length_u, line_width)];
    self.lblCubic_U.backgroundColor = [UIColor redColor];
    [self addSubview:self.lblCubic_U];
    
    self.lblCubic_B = [[UILabel alloc] initWithFrame:CGRectMake(o_x, o_y + line_length_l - line_width, line_length_b, line_width)];
    self.lblCubic_B.backgroundColor = [UIColor redColor];
    [self addSubview:self.lblCubic_B];
    
}

-(void)onTapView:(UITapGestureRecognizer *)tapGr
{
    CGPoint location = [tapGr locationInView:self];
    double x = location.x;
    double y = location.y;
    
    int rowIndex = (int)((int)y/(int)average_wave_h_pix);
    double second_start = 0;
    double second_end = 0;

    double second_base = 0.0 ;
    double second_offset = 0.0;
    if(rowIndex == 0)
    {
        if(x < Ruler_Width_Total_Pix)
        {
            second_base = -1;
            second_offset = -1;
        }
        else
        {
            second_base = 0;
            second_offset = (x - Ruler_Width_Total_Pix)/Pix_Per_second_Row_First;
        }
    }
    else
    {
        DBG(@"(x)/Pix_Per_second ;: %f",(x)/Pix_Per_second_Row_Others);
        second_base = (rowIndex - 1)*5.0 + 5.0;
        second_offset = (x)/Pix_Per_second_Row_Others;
    }
    
    
#define ABSF(f) ((f)<0?-(f):(f))
    double secondMax = [ECGDetailWave secondsCanBeDisplayOneScreen];
    double s_l=0,s_r = 0;
    if(rowIndex == 0)
    {
        secondMax = MIN(5.0, secondMax);
        double s_half = secondMax/2.0;
        
        s_l = second_offset - s_half;
        s_r = second_offset + s_half;
        if(s_l < 0)
        {
            
            s_r += ABSF(s_l);
            s_l = 0;
            s_r = MIN(s_r, 5.0);
        }
        if(s_r > 5.0)
        {
            s_l -= ABSF(s_r - 5.0);
            s_l = MAX(0,s_l);
            s_r = 5.0;
        }
        
    }
    else
    {
        secondMax = MIN(5.0, secondMax);
        double s_half = secondMax/2.0;
        s_l = second_offset - s_half;
        s_r = second_offset + s_half;
        if(s_l < 0)
        {
            s_r += ABSF(s_l);
            s_l = 0;
            s_r = MIN(s_r, 5.0);
        }
        if(s_r > 5.0)
        {
            s_l -= ABSF(s_r - 5.0);
            s_l = MAX(0,s_l);
            s_r = 5.0;
        }
    }
    
    second_start = second_base + s_l;
    second_end = second_base + s_r;
    
    [self drawCubicAtStart:s_l end:s_r row:rowIndex];
    
    DBG(@"选中%fs----%fs",second_start,second_end);
    self.userInteractionEnabled = NO;
    [self performSelector:@selector(showDetail:)
               withObject:@{@"second_start":[NSNumber numberWithDouble:second_start],@"second_end":[NSNumber numberWithDouble:second_end]}
               afterDelay:200/1000.0];
    
    
}

//画ECG详细波形
-(void)showDetail:(id)obj
{
    NSDictionary *param = (NSDictionary *)obj;
    double second_start = ((NSNumber *)[param objectForKey:@"second_start"]).doubleValue;
    double second_end = ((NSNumber *)[param objectForKey:@"second_end"]).doubleValue;
    self.userInteractionEnabled = YES;
    if([_delegate respondsToSelector:@selector(didChoiceWaveDuringStart:end:)])
        [_delegate didChoiceWaveDuringStart:second_start end:second_end];
}

-(void)showVoiceBtn
{
    _btnVoice.hidden = NO;
}

-(void)hideVoiceBtn
{
    _btnVoice.hidden = YES;
}

//显示用户名标签，分享图片时调用
-(void)showUserName
{
    double lblWidth = 100;
    _lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 2,self.frame.size.height-20.0, lblWidth, 20.0)];
    _lblUserName.textAlignment = NSTextAlignmentLeft;
    _lblUserName.backgroundColor = [UIColor clearColor];
    _lblUserName.textColor = [UIColor grayColor];
    _lblUserName.font = [UIFont systemFontOfSize:13];
    NSString *strName = [NSString stringWithFormat:@"%@",(_isSpc ? _curXuser.name : _curUser.name)];
    _lblUserName.text = strName;
    [self addSubview:_lblUserName];
}

-(void)hideUserName
{
    if (_lblUserName) {
        [_lblUserName removeFromSuperview];
    }
}

@end
