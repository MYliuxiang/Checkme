//
//  WaveInfo.m
//  IOS_Minimotor
//
//  Created by 李乾 on 15/5/11.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "WaveInfo.h"
#import "PublicUtils.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
//  40ms来一包数据，一包数据包含5个点(由Checkme端决定)，  即40ms 5个点，已知量

#define ms_per_pkg 40  // 多久来一包数据，一包数据包含5个点
#define vals_per_pkg 5  //一包数据中点的个数

/***一次取的点数来画(必须为整数)***/
#define vals_per_get_toDraw   5      // 一次取5个点来画自定义


//    (25 mm/s, 规定量)
//    (10mm/mV, 规定量)

//


#define zero_ecg_value       //心电波形为直线时的值
#define zero_oxi_value 200    //血氧波形为直线时的值  自定义    为了让波形处于一个比较好的位置

@interface WaveInfo ()

@property (nonatomic) CGRect left_block_rect;    //左边波形区的frame
@property (nonatomic) CGRect right_block_rect;  //右边信息区的frame

@property (nonatomic, strong) NSMutableArray *realTimeDataArr;    //当前接收点的数据池
@property (nonatomic, strong) NSMutableArray *pointArr;    // 坐标数据池
@property (nonatomic) Wave_type type;

@property (nonatomic,retain)  UIBezierPath *path;
@property (nonatomic, strong) NSMutableArray *arr1;    // 坐标数组1
@property (nonatomic, strong) NSMutableArray *arr2;    // 坐标数组2
@end

int	sysctlbyname(const char *, void *, size_t *, void *, size_t);

@implementation WaveInfo
{
    float pointX;  //画波形的点
    float pointY;
    
    int indexX;   // 标记
    int his_value;   // 柱状图的值
    float orig_his_y;    //柱状图原始的位置宽高
    float orig_his_h;
    
    //标尺，“工”字形
    UIView *ruler;
    UIView *ruler1;
    UIView *ruler2;
    UILabel *rulerLab;  //标尺文字
    

    float mm_per_mV;              //定义1mV对应的毫米数    自定义
    float points_per_mV;               //1mV对应的point点    决定点的y坐标
    
    float mm_per_value;              //两个值的间隔对应的 mm数      计算得来
    float points_per_value;           //两个点之间的距离对应的point点   决定点的x坐标
    NSArray *ruler_height_arr;   // 标尺可取的值
    
    float ppi;  //当前设备的ppi
    int point_to_pix;   // 普通屏为1，retina屏为2     即1point代表多少pixels
    
    /***一屏的点数***/
    int POINTS_PER_SCREEN;   //    由屏宽除一个点对应的point点数   的来
    
    NSArray *_array;
}

static int rulerIndex = 0;

- (instancetype) initWithFrame:(CGRect)frame andType:(Wave_type)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        indexX = 0;
        pointX = 0.0;
        

        ppi = [PublicUtils get_PPI_ofCurDevice];
        if (ppi == 132 || ppi == 163) {   //普通屏    1 point = 1 pixels
            point_to_pix = 1;
        } else if (ppi == 264 || ppi == 326 ) {   //retina屏    1 point = 2 pixels
            
            point_to_pix = 2;
            
        }else if(ppi >= 401){
            point_to_pix = 3  ;

        }
        // 常量
        mm_per_value = 25.0/((1000.0/ms_per_pkg)*vals_per_pkg);   //两个值之间间隔的mm数    这个是固定值的推算值，不是自定义的
        
        ruler_height_arr = [NSArray arrayWithObjects:@(10.0), @(20.0), @(5.0), nil];
        NSNumber *num = [ruler_height_arr objectAtIndex:rulerIndex];
        mm_per_mV = num.floatValue;  // 1 mV代表的mm数    自定义  用于标尺高度的切换
        
        _realTimeDataArr = [NSMutableArray array];
        _pointArr = [NSMutableArray array];
        _arr1 = [NSMutableArray array];
        _arr2 = [NSMutableArray array];
        
        self.opaque = NO;
        self.backgroundColor = RGB(42, 55, 124);
        self.frame = frame;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = RGB(139, 139, 139).CGColor;
        self.clipsToBounds = YES;
        
        
        _left_block_rect = CGRectMake(0, 0, self.bounds.size.width * 0.8, self.bounds.size.height);
        _right_block_rect = CGRectMake(CGRectGetMaxX(_left_block_rect), 0, (self.bounds.size.width-_left_block_rect.size.width), self.bounds.size.height);
        

        //   1mV对应的point点
        if (point_to_pix != 3) {
            
            
            
            size_t size;
            sysctlbyname("hw.machine", NULL, &size, NULL, 0);
            char *machine = malloc(size);
            sysctlbyname("hw.machine", machine, &size, NULL, 0);
            NSString *platform = [NSString stringWithUTF8String:machine];
            free(machine);
            
            if( [platform hasPrefix:@"iPhone7,2"]){
                
                points_per_mV = (ppi/30.5)*mm_per_mV/point_to_pix;
                //   两点之间的横坐标对应的point点
                points_per_value = (ppi/30.5)*mm_per_value/point_to_pix;
                POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
                
            }else{
                
                
                points_per_mV = (ppi/25.4)*mm_per_mV/point_to_pix;
                //   两点之间的横坐标对应的point点
                points_per_value = (ppi/25.4)*mm_per_value/point_to_pix;
                POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
            }
            
            
            
        }else{
            
            if(ppi == 401){
                //6p
                points_per_mV = (ppi / 28.7) * mm_per_mV/point_to_pix;  //(46.5737534)
                //   两点之间的横坐标对应的point点
                points_per_value = (ppi / 28.7)*mm_per_value/point_to_pix; //(0.931475043)
                POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
            }else if (ppi == 488){
                //6s
                points_per_mV = (ppi / 30.5) * mm_per_mV/point_to_pix;  //(46.5737534)
                //   两点之间的横坐标对应的point点
                points_per_value = (ppi / 30.5)*mm_per_value/point_to_pix; //(0.931475043)
                POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
                
            }else if (ppi == 460){
                //6sp
                points_per_mV = (ppi / 25.4) * mm_per_mV/point_to_pix;  //(46.5737534)
                //   两点之间的横坐标对应的point点
                points_per_value = (ppi / 25.4)*mm_per_value/point_to_pix; //(0.931475043)
                POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
                
            }
            
        }

      
        if([AppDelegate GetAppDelegate].ishaveList == YES)
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//            [self addGestureRecognizer:tap];
        }
        
        if (type == Wave_type_ECG) {
            _ecg_info = [[[NSBundle mainBundle] loadNibNamed:@"ECG_info" owner:self options:nil] lastObject];
            [self addSubview:_ecg_info];
            _ecg_info.userInteractionEnabled = YES;
            
            //画标尺
            ruler = [[UIView alloc] init];
            ruler.backgroundColor = [UIColor grayColor];
            [self addSubview:ruler];
            
            ruler1 = [[UIView alloc] init];
            ruler1.backgroundColor = [UIColor grayColor];
            [self addSubview:ruler1];
            
            ruler2 = [[UIView alloc] init];
            ruler2.backgroundColor = [UIColor grayColor];
            [self addSubview:ruler2];
            
            //注释掉
            rulerLab = [[UILabel alloc] init];
            rulerLab.text = @"";
            rulerLab.font = font(15);
            rulerLab.textColor = [UIColor grayColor];
            [self addSubview:rulerLab];
            
        }
        else if (type == Wave_type_SpO2) {
            _spo2_info = [[[NSBundle mainBundle] loadNibNamed:@"SpO2_info" owner:self options:nil] lastObject];
            [self addSubview:_spo2_info];
            
            his_value = 0;
            orig_his_y = _spo2_info.spo2_his.frame.origin.y;
            orig_his_h = CGRectGetHeight(_spo2_info.spo2_his.frame);
        }
        else if (_type == Wave_type_RESP) {
            _resp_info = [[[NSBundle mainBundle] loadNibNamed:@"RESP_info" owner:self options:nil] lastObject];
            [self addSubview:_resp_info];
        }
        else if (_type == Wave_type_ART) {
            _art_info = [[[NSBundle mainBundle] loadNibNamed:@"ART_info" owner:self options:nil] lastObject];
            [self addSubview:_art_info];
        }
        
        
    }
    
    return self;
}

//数据清零
- (void)_shujuqingling
{
    indexX = 0;
    pointX = 0.0;
    _realTimeDataArr = [NSMutableArray array];
    _pointArr = [NSMutableArray array];
    _arr1 = [NSMutableArray array];
    _arr2 = [NSMutableArray array];

}


//- (void)swipeAction:(UISwipeGestureRecognizer *)swipe
//{
//    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
//        NSLog(@"=========滑动");
//        
//        if ([DataArrayModel sharedInstance].isluzhi == NO) {
//            _array = @[@"录制",@"视频列表"];
//        }
//        if ([DataArrayModel sharedInstance].isluzhi == YES) {
//            _array = @[@"停止录制",@"视频列表"];
//        }
//       
//        SIAlertView *alertView ;
//        alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:@"功能选择"];
//
//        for (int i=0; i<_array.count; i++) {
//            // 添加  点击对应button进入
//            [alertView addButtonWithTitle:[_array objectAtIndex:i] type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
//                
//                
//              [[NSNotificationCenter defaultCenter] postNotificationName:Noti_STDNoti object:_array[i]];
//               
//            }];
//        }
//        
//        [alertView addButtonWithTitle:@"取消"
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alertView) {
//                              }];
//        [alertView show];
//
//        
//    }
//
//}

- (void) layoutSubviews
{
    _left_block_rect = CGRectMake(0, 0, self.bounds.size.width * 0.8, self.bounds.size.height);
    _right_block_rect = CGRectMake(CGRectGetMaxX(_left_block_rect), 0, (self.bounds.size.width-_left_block_rect.size.width), self.bounds.size.height);
    
    //   1mV对应的point点
    if (point_to_pix != 3) {
        
      
        
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithUTF8String:machine];
        free(machine);
        
        if( [platform hasPrefix:@"iPhone7,2"]){
            
            points_per_mV = (ppi/30.5)*mm_per_mV/point_to_pix;
            //   两点之间的横坐标对应的point点
            points_per_value = (ppi/30.5)*mm_per_value/point_to_pix;
            POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
            
        }else{
        
        
            points_per_mV = (ppi/25.4)*mm_per_mV/point_to_pix;
            //   两点之间的横坐标对应的point点
            points_per_value = (ppi/25.4)*mm_per_value/point_to_pix;
            POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
        }
        

        
    }else{
        
        if(ppi == 401){
            //6p
        points_per_mV = (ppi / 28.7) * mm_per_mV/point_to_pix;  //(46.5737534)
        //   两点之间的横坐标对应的point点
        points_per_value = (ppi / 28.7)*mm_per_value/point_to_pix; //(0.931475043)
        POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
        }else if (ppi == 488){
        //6s        
            points_per_mV = (ppi / 30.5) * mm_per_mV/point_to_pix;  //(46.5737534)
            //   两点之间的横坐标对应的point点
            points_per_value = (ppi / 30.5)*mm_per_value/point_to_pix; //(0.931475043)
            POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
            
        }else if (ppi == 460){
        //6sp
            points_per_mV = (ppi / 25.4) * mm_per_mV/point_to_pix;  //(46.5737534)
            //   两点之间的横坐标对应的point点
            points_per_value = (ppi / 25.4)*mm_per_value/point_to_pix; //(0.931475043)
            POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;    //  一屏的点数
            
        }
        
    }

//    points_per_mV = 49;
//    //   两点之间的横坐标对应的point点
//    points_per_value = (4.9)*mm_per_value;
//    POINTS_PER_SCREEN = _left_block_rect.size.width/points_per_value;

    if (_ecg_info) {
        _ecg_info.frame = _right_block_rect;
    
        ruler.frame = rect(30 * ration_W, self.height * 0.5 - points_per_mV, 2, points_per_mV * 2);
        rulerLab.frame = rect(ruler.frame.origin.x + 10, CGRectGetMaxY(ruler.frame) - 24, 60, 24);
        
        ruler1.frame = rect(30 * ration_W -2.5, ruler.frame.origin.y, 8, 2);
        ruler2.frame = rect(30 * ration_W -2.5, CGRectGetMaxY(ruler.frame)-1, 8, 2);
        
    }
    
    if (_spo2_info) {
        _spo2_info.frame = _right_block_rect;
    }
    
    if (_resp_info) {
        _resp_info.frame = _right_block_rect;
    }
    
    if (_art_info) {
        _art_info.frame = _right_block_rect;
    }
}

- (void) tapAction:(UITapGestureRecognizer *)tap
{
    CGPoint touchPos = [tap locationInView:self];
    if(touchPos.x < CGRectGetMaxX(_left_block_rect)+2)
    {
        if (_type == Wave_type_ECG) {
            DLog(@"点击缩放");
            rulerIndex ++;
            if (rulerIndex == 3) {
                rulerIndex = 0;
            }
            NSNumber *num = [ruler_height_arr objectAtIndex:rulerIndex];
            mm_per_mV = num.floatValue;
            
            //   1mV对应的point点
//            points_per_mV = (ppi/25.4)*mm_per_mV/point_to_pix;
            
            [self setNeedsDisplay];
            [self layoutSubviews];
        }

    
    }
    
    
}

//  刷新画线
- (void)refreshWaveWithDataArr:(NSArray *)dataArr
{
    [_realTimeDataArr addObjectsFromArray:dataArr];
    
    DLog(@"点的个数：%lu", _realTimeDataArr.count);
  
    
    if (_realTimeDataArr.count == vals_per_get_toDraw) {
        
        //更新柱状图
        his_value = 0;
        if (_type == Wave_type_SpO2) {
            for (NSNumber *num in _realTimeDataArr) {
                his_value += num.intValue;
            }
            his_value /= vals_per_get_toDraw;    //求出*个点过来的平均值
            DLog(@"***  %d", his_value);
//            his_value*=1.4;      //给个比例1.4    使柱状图的值等比小于实际值，以免柱子过高
#warning 修改条形柱反向
            float y = self.bounds.size.height*(1.0/2) - (100 - his_value);
            if (y<self.bounds.size.height*(1.8/5)) {
                y=self.bounds.size.height*(1.8/5);
            }
            
            DLog(@"----y:%f,orig_his_h:%f,orig_his_y:%f",y,orig_his_h,orig_his_y);
            
            if (his_value == 200) {   //
                _spo2_info.spo2_his.hidden = YES;
            } else {
                _spo2_info.spo2_his.hidden = NO;
                _spo2_info.spo2_his.frame = rect(0, y, 25 * ration_H, orig_his_h - (y -  orig_his_y));
                
            }
            
            //        DLog(@"*** %@", NSStringFromCGRect(_spo2_info.spo2_his.frame));
        }
        
        [self refreshRealTimeView];
    }
    
}

- (void)refreshRealTimeView     //  每40ms刷新一次
{
    if (_realTimeDataArr.count != 0) {
        
        for (int i = 0; i < vals_per_get_toDraw; i++) {  //1次取5个点
            
            // x坐标
            if (indexX == 0) {
                pointX = 0;
            }
            pointX += points_per_value;   //一个数值点占用的像素
            
            // y坐标
            NSNumber *num = [_realTimeDataArr objectAtIndex:i];   //取realTimeDataArr的前*个点
            
            pointY = num.floatValue * 2;
            
            CGPoint point = {pointX, pointY};    //  生成像素点
            NSValue *value = [NSValue valueWithCGPoint:point];
            
//            NSLog(@"------------%d",POINTS_PER_SCREEN);
            if (_pointArr.count < POINTS_PER_SCREEN) {
                [_pointArr addObject:value];    // 每次取到的5个点放进数组
                
                
            } else {   //当点达到满屏时  根据indexX即可找到跳跃的那个点  indexX和indexX+1那两个点
                
                 [_pointArr replaceObjectAtIndex:indexX withObject:value];
                
                    if (indexX == 0) {
                        
                        [_arr1 removeAllObjects];
                        [_arr1 addObject:_pointArr[0]];
                        
                        [_arr2 removeAllObjects];
                        
                        for (int i =(indexX+10); i<_pointArr.count; i++) {
                            [_arr2 addObject:[_pointArr objectAtIndex:i]];
                        }
                    }
                    
                    if (indexX > 0 && indexX < POINTS_PER_SCREEN) {
                        [_arr1 addObject:_pointArr[indexX]];
                        if (_arr2.count != 0) {
                            [_arr2 removeObjectAtIndex:0];
                        }
                    }
                
            }
            
            indexX ++;
            if (indexX >= POINTS_PER_SCREEN) {
                indexX = 0;
            }
        }
        
        DLog(@"==========================================");
        [_realTimeDataArr removeObjectsInRange:NSMakeRange(0, vals_per_get_toDraw)];   //删除realTimeDataArr前*个点
    }
    
    [self setNeedsDisplay];    //取到*个点 重绘一次
    

}


- (void)drawRect:(CGRect)rect {
    
    _path = [UIBezierPath bezierPath];
    
    if (_pointArr.count < POINTS_PER_SCREEN) {   //点少于一屏的点数时
        
        //第一个点
        NSValue *value = _pointArr.firstObject;
        CGPoint f_point = [self transferOriginalPointToNewPointWith:value.CGPointValue];
        [_path moveToPoint:f_point];
        
        //其他点
        for (NSValue *value1 in _pointArr) {
            CGPoint o_Point = [self transferOriginalPointToNewPointWith:value1.CGPointValue];
            [_path addLineToPoint:o_Point];
        }
        
    } else {  //点达到一屏时 画线的方式改变
        
        //arr1
        CGPoint f_Point1 = [self transferOriginalPointToNewPointWith:[_arr1.firstObject CGPointValue]];
        [_path moveToPoint:f_Point1];
        for (NSValue *value1 in _arr1) {
            CGPoint o_Point1 = [self transferOriginalPointToNewPointWith:value1.CGPointValue];
            [_path addLineToPoint:o_Point1];
        }
        
        //arr2
        CGPoint f_Point2 = [self transferOriginalPointToNewPointWith:[_arr2.firstObject CGPointValue]];
        [_path moveToPoint:f_Point2];
        for (NSValue *value2 in _arr2) {
            CGPoint o_Point2 = [self transferOriginalPointToNewPointWith:value2.CGPointValue];
            [_path addLineToPoint:o_Point2];
        }
    }
    
     // 设置画线颜色
    if (_type == Wave_type_ECG) {
        [RGB(250, 138, 53) setStroke];
    }else if (_type == Wave_type_SpO2) {
        [RGB(250, 138, 53) setStroke];
    }else if (_type == Wave_type_RESP) {
        [RGB(250, 138, 53) setStroke];
    } else if (_type == Wave_type_ART) {
        [[UIColor redColor] setStroke];
    }
    
    _path.lineWidth = 1.5;
    [_path stroke];
}

#warning 修改血样相反的情况
- (CGPoint) transferOriginalPointToNewPointWith:(CGPoint)point
{
    CGPoint newPoint;
    
    newPoint.x = point.x;
    if (_type == Wave_type_ECG) {
        newPoint.y = self.bounds.size.height*(1.0/2) - point.y*points_per_mV;
    } else if (_type == Wave_type_SpO2) {
        if (point.y == 200) {  // 200时对应的为直线
            newPoint.y = self.bounds.size.height*(1.0/2) - (200 - point.y);
        } else {
            newPoint.y = self.bounds.size.height*(1.0/2) - (100 - point.y);//修改血样相反的情况
        }
        
        
    }
    return newPoint;
}

@end
