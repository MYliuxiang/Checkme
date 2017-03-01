//
//  LXDownView.m
//  Checkme Mobile
//
//  Created by Viatom on 16/8/5.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "LXDownView.h"

@implementation LXDownView

- (IBAction)cancleAC:(id)sender {
    
    [BTCommunication sharedInstance].curReadFile = nil;
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2];
}

- (instancetype)initWithTitle:(NSString *)title
                     Btntitle:(NSString *)btntitle
                       inview:(UIView *)view
{
    self = [super init];
    if (self) {
        self  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
        
        self.current = 0;
        [self.cancleBtn setTitle:btntitle forState:UIControlStateNormal];
        self.width = kScreenWidth - 80;
        self.center = [self topView].center;
        self.progresslayout.constant = 0;

//        if (self.downManger.mdelegate == nil) {
//            
//                _downManger = [[DownManager alloc] init];
//                _downManger.mdelegate = self;
//                [_downManger loadToal];
//            
//                }
        self.view = view;
      
    }
    return self;
                                                                             
}
- (instancetype)init
{
    self = [super init];
    if (self) {
       
        self  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
        self.width = kScreenWidth - 80;
        self.center = [self topView].center;
        self.progresslayout.constant = 0;
              if (self.downManger.mdelegate == nil) {
            
            NSLog(@"空的");
        }

    }
    return self;
}

- (void)setTotalCount:(float)totalCount
{
    _totalCount = totalCount;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d",(self.current + 1),(int)self.totalCount];
}

- (void)awakeFromNib
{
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    self.cancleBtn.layer.cornerRadius = 3;
    self.cancleBtn.layer.masksToBounds = YES;
    
    self.progressView.layer.cornerRadius = 3;
    self.progressView.layer.masksToBounds = YES;
    
    self.backView.layer.cornerRadius = 3;
    self.backView.layer.masksToBounds = YES;
    
}

- (void)count:(int)total
{
    self.totalCount = total;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d",(_current + 1),total];

}

- (void)loadSugrecess
{
//    self.countLabel.text = [NSString stringWithFormat:@"同步成功"];
    [self dismiss];
    return;
}


- (void)countFail
{
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1];

}

- (void)progress:(float)progress
{
    
    self.progress = progress;

}


- (void)loadDatailOne
{
    self.current++;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d",(self.current + 1),(int)self.totalCount];

}

- (void)show {
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.view addSubview:_maskView];
    [self.view addSubview:self];
    
    self.center = self.view.center;
    [self showAnimation];
    
    _downManger = [DownManager sharedManager];
    _downManger.mdelegate = self;
    [_downManger loadData];

    
}

- (void)dismiss
{
    
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
    [self hideAnimation];
    [self.delegate dismisLoad];
    [[CloudUpLodaManger sharedManager] noticeUpdata];
    
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if(progress >=0){
    self.progresslayout.constant = (self.width - 60)*progress;
    }

}

- (void)showAnimation {
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration             = 1;
    popAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.0)],
                                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                                          [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes             = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions      = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:popAnimation forKey:nil];
    
}

- (void)hideAnimation{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        _downManger = nil;
        _downManger.mdelegate = nil;
        [self removeFromSuperview];
        
    }];
    
}

-(UIView*)topView{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.userInteractionEnabled = YES;
    return  window.subviews[0];
    
}


@end
