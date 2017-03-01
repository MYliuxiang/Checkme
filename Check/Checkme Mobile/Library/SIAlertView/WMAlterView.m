//
//  WMAlterView.m
//  AlterView
//
//  Created by Xiao_Erge on 15/6/28.
//  Copyright (c) 2015年 Xiao_Erge. All rights reserved.
//

#import "WMAlterView.h"

@implementation WMAlterView {
    UIView   * _alterView;//提示框视图
    CGFloat _width;
    CGFloat _height;
}
//代码创建
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:0.5];
        [self createAlterView];
    }
    return self;
}
//xib创建
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
        self.alpha = 0.5;
        [self createAlterView];
    }
    return  self;
}
//插件AlterView


- (void)createAlterView {
    
    _width                     = 270.f;
    _height                    = 125.f;
    CGFloat x                  = ([UIScreen mainScreen].bounds.size.width - _width)/2;
    CGFloat y                  = ([UIScreen mainScreen].bounds.size.height - _height - 64 - 49) / 2.0 ;
    _alterView                 = [[UIView alloc] initWithFrame:CGRectMake(x, y, _width, _height)];
    _alterView.backgroundColor = [UIColor whiteColor];
    _alterView.clipsToBounds   = YES;
    [_alterView.layer setCornerRadius:8.0];
    
    // 一.标题
    [self createTitle];
    
    // 三.取消确认按钮
    [self createAndConfilmCancellButon];
    
    // 四.协议Button
    [self createProtocol];

    [self addSubview:_alterView];
}

#pragma mark -                                      一.视图类的创建
#pragma mark  1.alterView标题
- (void)createTitle {
    if (self.alterTitle == nil) {
        CGFloat width             = _width;
        CGFloat height            = _height/3.f;
        CGFloat x                 = 0.f;
        CGFloat y                 = 0.f;
        _alterTitle               = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _alterTitle.text          = @"确认提交";
        _alterTitle.font          = [UIFont boldSystemFontOfSize:19];
        _alterTitle.textAlignment = NSTextAlignmentCenter;
        _alterTitle.textColor     = [UIColor blackColor];
        [_alterView addSubview:_alterTitle];
    }
} //alterView标题

#pragma mark  3.取消和确认按钮
- (void)createAndConfilmCancellButon {
    
    // 一.分割线
    CGFloat divisionWidth         = _width;
    CGFloat divisionHeight        = 0.8f;
    CGFloat divisionX             = 0.f;
    CGFloat divisionY             = _height*2.f/3.f;
    UIImageView *divisionView1    = [[UIImageView alloc] initWithFrame:CGRectMake(divisionX, divisionY, divisionWidth, divisionHeight)];
    divisionView1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [_alterView addSubview:divisionView1];
    
    CGFloat divisionWidth2        = 0.5f;
    CGFloat divisionHeight2       = _height/3.f - divisionHeight;
    CGFloat divisionX2            = _width/2.f - divisionWidth2/2.f;
    CGFloat divisionY2            = divisionView1.bottom;
    UIImageView *divisionView2    = [[UIImageView alloc] initWithFrame:CGRectMake(divisionX2, divisionY2, divisionWidth2, divisionHeight2)];
    divisionView2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [_alterView addSubview:divisionView2];

    // 二.取消按钮
    _cancelButton                           = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame                     = CGRectMake(0.f, divisionView1.bottom, _width/2.f,_height/3.f - divisionHeight);
    _cancelButton.titleLabel.font           = [UIFont boldSystemFontOfSize:18];
    _cancelButton.showsTouchWhenHighlighted = YES;
    _cancelButton.tag                       = 101;
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithRed:21/255.f green:125/255.0 blue:251/255.f alpha:1] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_alterView addSubview:_cancelButton];
    
    // 三.确认按钮
    _confirmButton                           = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton.frame                     = CGRectMake(_cancelButton.right, _cancelButton.top, _width/2.f,_height/3.f - divisionHeight);
    _confirmButton.titleLabel.font           = [UIFont boldSystemFontOfSize:18];
    _confirmButton.showsTouchWhenHighlighted = YES;
    _confirmButton.tag                       = 102;
    [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    //锁定确认按钮

    [_alterView addSubview:_confirmButton];
} //取消和确认按钮
#pragma mark  4.协议Button
- (void)createProtocol {
    // 一.label
    CGFloat width  = _width - _height/5.5f *2.0;
    CGFloat height = _height/3.75f;
    CGFloat x      = _height/5.5f;
    CGFloat y      = _height/3.125f;
    
    _textFiled = [[UITextField alloc]init];
    _textFiled.backgroundColor = [UIColor redColor];
    _textFiled.frame           = CGRectMake(x, y, width, height);
    _textFiled.font = [UIFont systemFontOfSize:14.0];
     _textFiled.placeholder = @"请输入该视频的名字";
    [_alterView addSubview:_textFiled];
    
} //协议Button
#pragma mark  5.

//——————————————————————————————————————————————————————————————————————————
#pragma mark -                                      二.方法事件类
#pragma mark  1.确认和取消按钮
- (void)clickAction:(UIButton *)button {

    if (button.tag == 101) {
        
        [self removeFromSuperview];
        
    }else {
        //设置block
        _conflimBlock(_textFiled.text);
        [self removeFromSuperview];
    }
}

#pragma mark  3.
//——————————————————————————————————————————————————————————————————————————
#pragma mark -                                      三.各种代理方法
#pragma mark  1.
#pragma mark  2.
#pragma mark  3.
//——————————————————————————————————————————————————————————————————————————

- (void)dealloc {
    NSLog(@"wmAlterView 死亡");
}
@end









