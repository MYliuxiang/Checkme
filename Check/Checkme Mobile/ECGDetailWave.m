//
//  EcgWaveView_Detail.m
//  BTHealth
//
//  Created by demo on 13-11-6.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "ECGDetailWave.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"

static double X_axis_from_top = 0;

#define Ruler_Width_Top_Pix 10
#define Ruler_Width_Middle_Pix 12
#define Ruler_Width_Total (2.0 * Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix)

#define PIX_Per_mm (320.0/50)
#define MM_Per_mv (10.0)
#define MM_per_second (25.0)



@interface ECGDetailWave ()
@property (nonatomic,retain) ECGInfoItem_InnerData *ecgInnerData;
@property (nonatomic,retain) spcInner_Data *spcInnerData;
@property (nonatomic,retain) UILabel *lblUserName, *lblTime;
@property (nonatomic) BOOL isSpc;

@end

@implementation ECGDetailWave
@synthesize ecgInnerData = _ecgInnerData;
static double rulerScale;

-(id)initWithFrame:(CGRect)frame spcInnerData:(spcInner_Data *)data
{
    self = [self initWithFrame:frame];
    if(self)
    {
        self.spcInnerData = data;
        self.isSpc = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame ecgInnerData:(ECGInfoItem_InnerData *)data
{
    self = [self initWithFrame:frame];
    if(self)
    {
        self.ecgInnerData = data;
        self.isSpc = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


-(id)initWithMinFrame:(CGRect)frame spcInnerData:(spcInner_Data *)data
{
    CGSize size = [ECGDetailWave calViewSizeForArr:data.arrEcgContent];
    
    double w,h;
    w = MAX(size.width,frame.size.width);
    h = MAX(size.height,frame.size.height);
    
    CGRect result_frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
    
    self = [self initWithFrame:result_frame spcInnerData:data];
    return self;
}

-(id)initWithMinFrame:(CGRect)frame ecgInnerData:(ECGInfoItem_InnerData *)data
{
    CGSize size = [ECGDetailWave calViewSizeForArr:data.arrEcgContent];
    
    double w,h;
    w = MAX(size.width,frame.size.width);
    h = MAX(size.height,frame.size.height);
    
    CGRect result_frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
    
    self = [self initWithFrame:result_frame ecgInnerData:data];
    return self;
}


-(CGRect)rectForDisplayStart:(double)startSecond end:(double)endSecond fatherViewFrame:(CGRect)fatherViewFrame
{
    CGRect rect = {0};
    double y_t = startSecond*MM_per_second*PIX_Per_mm;
    double y_b = endSecond*MM_per_second*PIX_Per_mm;
 
    rect = CGRectMake(0, y_t, fatherViewFrame.size.width, y_b - y_t);
    
    return rect;
}

+(double)secondsCanBeDisplayOneScreen
{
    double oneScreenH = 0;
    if([UIDevice currentDevice].systemVersion.doubleValue >= 7.0) //iOS 7.0版本以上
    {
        oneScreenH = CUR_SCREEN_H-49-20; //屏幕总高度减去 tabBar  高度再减去 状态栏的高度 
    }
    else
    {
        oneScreenH = CUR_SCREEN_H-49;  //屏幕总高度减去 tabBar的高度
    }
    
    double seconds = (oneScreenH/PIX_Per_mm)/MM_per_second;
    return seconds;
}

+ (void)calRulerScale:(double)max minVal:(double)min{
    double waveHeight = max - min;
    if (waveHeight<0.25) {
        rulerScale = 0.25;
    }else if (waveHeight<0.5){
        rulerScale = 0.5;
    }else if (waveHeight <1){
        rulerScale = 1;
    }else if (waveHeight<2){
        rulerScale = 2;
    }else{
        rulerScale = 4;
    }
}

+(CGSize)calViewSizeForArr:(NSArray *)arr
{
    
    double max_val_mv,min_val_mv;
    [PublicMethods findMaxVal:&max_val_mv minVal:&min_val_mv inArr:arr];
    
    //超出范围去范围值
    max_val_mv = max_val_mv>2 ? 2 : max_val_mv;
    min_val_mv = min_val_mv<-2 ? -2 :min_val_mv;
    
    //计算标尺等级
    [self calRulerScale:max_val_mv minVal:min_val_mv];
    
    
    double view_h_mv =0;
    double X_axis_from_top_mv = 0;
    
    if(max_val_mv >=0 && min_val_mv >=0)
    {
        view_h_mv = max_val_mv;
        X_axis_from_top_mv = view_h_mv;
    }
    else if(max_val_mv>0 && min_val_mv < 0)
    {
        view_h_mv = max_val_mv - min_val_mv;
        X_axis_from_top_mv = max_val_mv;
    }
    else if(max_val_mv < 0 && min_val_mv < 0)
    {
        view_h_mv = -min_val_mv;
        X_axis_from_top_mv = 0;
    }
    
    //计算绘制整个波形需要的长宽
    double total_w=0,total_h=0;
    total_w = arr.count*(1/ECG_DATA_COLLECT_HZ)*MM_per_second*PIX_Per_mm;
    total_w += Ruler_Width_Total;
    
    total_h = view_h_mv*MM_Per_mv*PIX_Per_mm;
    
    
    CGSize ret = CGSizeMake(total_h, total_w);
    
    return ret;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    for(UIView *v in self.subviews)
        [v removeFromSuperview];
    
    
    double max_val_mv,min_val_mv;
    [PublicMethods findMaxVal:&max_val_mv minVal:&min_val_mv inArr:(_isSpc ? _spcInnerData.arrEcgContent : _ecgInnerData.arrEcgContent)];
    
    //超出范围去范围值
    max_val_mv = max_val_mv>2 ? 2 : max_val_mv;
    min_val_mv = min_val_mv<-2 ? -2 :min_val_mv;
    
//    if(max_val_mv < 1)
//        max_val_mv = 1;
    
    double view_h_mv =0;
    double X_axis_from_top_mv = 0;
    
    if(max_val_mv >=0 && min_val_mv >=0)
    {
        view_h_mv = max_val_mv;
        X_axis_from_top_mv = self.frame.size.height;
    }
    else if(max_val_mv>0 && min_val_mv < 0)
    {
        view_h_mv = max_val_mv - min_val_mv;
        X_axis_from_top_mv = max_val_mv;
    }
    else if(max_val_mv < 0 && min_val_mv < 0)
    {
        view_h_mv = -min_val_mv;
        X_axis_from_top_mv = 0;
    }
    
    
    
    // TODO: add +100 to move to center
    X_axis_from_top = X_axis_from_top_mv*MM_Per_mv*PIX_Per_mm + 100;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
#if 1
    
    int lineCount = 0;
    double pix_gap = 0;
    ///////////////////////////绘制横向分割线///////////////////////////
    //粗线
    CGContextSetLineWidth(context, 0.3);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    lineCount =  self.frame.size.height / (5.0 * PIX_Per_mm)+ 1;
    for(int i=0; i<lineCount; ++i)
    {
        double x=0,y=0;
        CGContextBeginPath(context);
        x = 0;
        y = i * (5.0 * PIX_Per_mm);
        CGContextMoveToPoint(context, x, y);
        x = self.frame.size.width;
        y = i * (5.0 * PIX_Per_mm);
        CGContextAddLineToPoint(context, x,y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //细线
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    lineCount =  self.frame.size.height / (1.0 * PIX_Per_mm)+ 1;
    for(int i=0; i<lineCount; ++i)
    {
        double x=0,y=0;
        CGContextBeginPath(context);
        x = 0;
        y = i * (1.0 * PIX_Per_mm);
        CGContextMoveToPoint(context, x, y);
        x = self.frame.size.width;
        y = i * (1.0 * PIX_Per_mm);
        CGContextAddLineToPoint(context, x,y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    /////////////////////////////绘纵向分隔线///////////////////////////
    //粗线
    CGContextSetLineWidth(context, 0.3);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    lineCount =  self.frame.size.width / (5.0 * PIX_Per_mm) + 1;
    for(int i=0; i<lineCount; ++i)
    {
        double x=0,y=0;
        CGContextBeginPath(context);
        x = i * (5.0 * PIX_Per_mm);
        y = 0;
        CGContextMoveToPoint(context, x, y);
        x = i * (5.0 * PIX_Per_mm);
        y = self.frame.size.height;
        CGContextAddLineToPoint(context, x,y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //细线
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    lineCount =  self.frame.size.width / (1.0 * PIX_Per_mm) + 1;
    for(int i=0; i<lineCount; ++i)
    {
        double x=0,y=0;
        CGContextBeginPath(context);
        x = i * (1.0 * PIX_Per_mm);
        y = 0;
        CGContextMoveToPoint(context, x, y);
        x = i * (1.0 * PIX_Per_mm);
        y = self.frame.size.height;
        CGContextAddLineToPoint(context, x,y);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    /////////////////////////////绘制波形///////////////////////////
    //绘制标尺
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    double standardLine = self.frame.size.width/2;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.frame.size.width - standardLine, 0);
    CGContextAddLineToPoint(context, self.frame.size.width -standardLine , Ruler_Width_Top_Pix);
    CGContextAddLineToPoint(context, self.frame.size.width -standardLine + (1*MM_Per_mv*PIX_Per_mm), Ruler_Width_Top_Pix);
    CGContextAddLineToPoint(context, self.frame.size.width -standardLine + (1*MM_Per_mv*PIX_Per_mm) , Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix);
    CGContextAddLineToPoint(context, self.frame.size.width -standardLine , Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix);
     CGContextAddLineToPoint(context, self.frame.size.width -standardLine , Ruler_Width_Top_Pix + Ruler_Width_Middle_Pix + Ruler_Width_Top_Pix);
    CGContextDrawPath(context, kCGPathStroke);
    
    //标尺等级文字
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(standardLine-60,40,100, 20.0)];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor blackColor];
    lbl.font = [UIFont systemFontOfSize:13];
    lbl.text = [NSString stringWithFormat:@"%dmV",1];
    lbl.transform = CGAffineTransformMakeRotation( M_PI/2 );
    [self addSubview:lbl];
    
    //绘制波形
   #define DOUBLE_EQU(d1,d2) ((ABS(d1-d2))<=0.5)
    int pointCount = 0;
    CGPoint *points = (CGPoint*)malloc(sizeof(CGPoint)*(_isSpc ? _spcInnerData.arrEcgContent.count : _ecgInnerData.arrEcgContent.count));
    for(int i=0; i < (_isSpc ? _spcInnerData.arrEcgContent.count : _ecgInnerData.arrEcgContent.count);++i)
    {
        NSNumber *num = [(_isSpc ? _spcInnerData.arrEcgContent : _ecgInnerData.arrEcgContent) objectAtIndex:i];
        double val = num.doubleValue;
        double x,y;
        x = self.frame.size.width/2 + val*MM_Per_mv*PIX_Per_mm;
        y = Ruler_Width_Total + i*(1/ECG_DATA_COLLECT_HZ)*MM_per_second*PIX_Per_mm;
        
#if  !__ECG_DATA_FOR_DEMO__
        if(pointCount > 0)
        {
            if(DOUBLE_EQU(x, points[pointCount -1].x) && DOUBLE_EQU(y,points[pointCount -1].y))
                continue;
        }
#endif
        
        pointCount ++;
        points[pointCount -1].x = x;
        points[pointCount -1].y = y;
    }
    
    CGContextBeginPath(context);
    if(pointCount>0)
    {
        CGContextMoveToPoint(context,  points[0].x, points[0].y);
        CGContextAddLines(context, points, pointCount);
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    free(points);

    /////////////////////////////加入时间标签///////////////////////////

    
#endif
    
#if 0
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    
    //绘制mv线
    double time_sep = 0.1;//每隔0.1秒一根线
    int lineCount = (_isSpc ? _spcInnerData.arrEcgContent.count : _ecgInnerData.arrEcgContent.count)*(1/Collect_HZ)/time_sep + 1;
    int min_line_count = (self.frame.size.height/(MM_per_second*PIX_Per_mm))/time_sep + 1;
    lineCount = MAX(lineCount,min_line_count);
    
    for(int i=0; i < lineCount;++i)
    {
        CGContextBeginPath(context);
        //CGContextMoveToPoint(context,);
        double x,y;
        x = 0;
        y = i*time_sep*MM_per_second*PIX_Per_mm;
        CGContextMoveToPoint(context,x,y);
        x = self.frame.size.width ;//i*time_sep*MM_per_second*PIX_Per_mm;
        y = y;
        CGContextAddLineToPoint(context,x,y);
        //CGContextMoveToPoint(context,i*time_sep*MM_per_second*PIX_Per_mm, 0);
        //CGContextAddLineToPoint(context,i*time_sep*MM_per_second*PIX_Per_mm, self.frame.size.height);
        CGContextDrawPath(context, kCGPathStroke);
    }
    

    
    //绘制时间线
    double mv_sep = 0.1;
    lineCount = (view_h_mv/mv_sep) + 1;
    min_line_count = self.frame.size.width*(1.0/(MM_Per_mv*PIX_Per_mm))/mv_sep + 1;
    lineCount = MAX(lineCount, min_line_count);
    for(int i = 0;i < lineCount;++i)
    {
        CGContextBeginPath(context);
        //CGContextMoveToPoint(context,);
        double x,y;
        x = i*mv_sep*MM_Per_mv*PIX_Per_mm;
        y = 0;//i*time_sep*MM_per_second*PIX_Per_mm;
        CGContextMoveToPoint(context,x,y);
        x = x;
        y = self.frame.size.height;
        CGContextAddLineToPoint(context,x,y);
        //CGContextMoveToPoint(context,i*time_sep*MM_per_second*PIX_Per_mm, 0);
        //CGContextAddLineToPoint(context,i*time_sep*MM_per_second*PIX_Per_mm, self.frame.size.height);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    //绘制标尺
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,self.frame.size.width-X_axis_from_top,0);
    CGContextAddLineToPoint(context, self.frame.size.width-X_axis_from_top, 1.0*(2.0/3.0)*MM_per_second*PIX_Per_mm);
    CGContextAddLineToPoint(context, self.frame.size.width-X_axis_from_top+1.0*MM_Per_mv*PIX_Per_mm, 1.0*(2.0/3.0)*MM_per_second*PIX_Per_mm);
    CGContextAddLineToPoint(context, self.frame.size.width-X_axis_from_top+1.0*MM_Per_mv*PIX_Per_mm, 2.0*(2.0/3.0)*MM_per_second*PIX_Per_mm);
    CGContextAddLineToPoint(context, self.frame.size.width-X_axis_from_top, 2.0*(2.0/3.0)*MM_per_second*PIX_Per_mm);
    CGContextAddLineToPoint(context, self.frame.size.width-X_axis_from_top, 3.0*(2.0/3.0)*MM_per_second*PIX_Per_mm);
    CGContextDrawPath(context, kCGPathStroke);
    
    //绘制曲线
    
    #define DOUBLE_EQU(d1,d2) ((ABS(d1-d2))<=0.5)
    int pointCount = 0;;
    CGPoint *points = (CGPoint*)malloc(sizeof(CGPoint)*(_isSpc ? _spcInnerData.arrEcgContent.count : _ecgInnerData.arrEcgContent.count));
    for(int i=0; i < (_isSpc ? _spcInnerData.arrEcgContent.count : _ecgInnerData.arrEcgContent.count);++i)
    {
        NSNumber *num = [(_isSpc ? _spcInnerData.arrEcgContent : _ecgInnerData.arrEcgContent) objectAtIndex:i];
        double val = num.doubleValue;
        double x,y;
        x = self.frame.size.width-X_axis_from_top + val*MM_Per_mv*PIX_Per_mm;
        y = 2.0*MM_per_second*PIX_Per_mm + i*(1/Collect_HZ)*MM_per_second*PIX_Per_mm;
        
        if(pointCount > 0)
        {
            if(DOUBLE_EQU(x, points[pointCount -1].x) && DOUBLE_EQU(y,points[pointCount -1].y))
                continue;
        }
        
        pointCount ++;
        points[pointCount -1].x = x;
        points[pointCount -1].y = y;
    }

    CGContextBeginPath(context);
    if(pointCount>0)
    {
        CGContextMoveToPoint(context,  points[0].x, points[0].y);
        CGContextAddLines(context, points, pointCount);
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    free(points);
    
#endif

}

//显示用户名标签
-(void)showInfo:(NSString*)userName time:(NSDateComponents*) comps
{
    if (userName!=nil) {
        _lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(-20,43,100, 20.0)];
        _lblUserName.textAlignment = NSTextAlignmentLeft;
        _lblUserName.backgroundColor = [UIColor clearColor];
        _lblUserName.textColor = [UIColor blackColor];
        _lblUserName.font = [UIFont systemFontOfSize:13];
        _lblUserName.text = [NSString stringWithFormat:@"User: %@",userName];
        _lblUserName.transform = CGAffineTransformMakeRotation( M_PI/2 );
        [self addSubview:_lblUserName];

    }
    if (comps!=nil) {
        _lblTime = [[UILabel alloc] initWithFrame:CGRectMake(-60,68,150, 20.0)];
        _lblTime.textAlignment = NSTextAlignmentLeft;
        _lblTime.backgroundColor = [UIColor clearColor];
        _lblTime.textColor = [UIColor blackColor];
        _lblTime.font = [UIFont systemFontOfSize:13];
        _lblTime.text = [NSString stringWithFormat:@"Date: %@",[NSDate engDescOfDateComp:comps][1]];
        _lblTime.transform = CGAffineTransformMakeRotation( M_PI/2 );
        [self addSubview:_lblTime];
    }
    
}

-(void)hideInfo
{
    if (_lblUserName) {
        [_lblUserName removeFromSuperview];
    }
    if (_lblTime) {
        [_lblTime removeFromSuperview];
    }
}

@end
