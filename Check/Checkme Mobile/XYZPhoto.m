//
//  XYZPhoto.m
//  demo6_PhotoRiver
//
//  Created by BOBO on 15/3/23.
//  Copyright (c) 2015年 BobooO. All rights reserved.
//

#import "XYZPhoto.h"
#import "PosterBodyTableView.h"
@implementation XYZPhoto

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - 30)];
        self.drawView = [[XYZDrawView alloc]initWithFrame:self.bounds];
        self.drawView.backgroundColor = [UIColor clearColor];
        self.drawView.alpha = 1;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.drawView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.drawView];
        [self addSubview:self.imageView];
        
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,self.imageView.bottom , self.width, 30)];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
//        _timeLabel.tag = 2015;
        [self addSubview:_timeLabel];


          _timer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(movePhotos) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:@"NSDefaultRunLoopMode"];
        
 
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        
//        [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(movePhotos) userInfo:nil repeats:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage)];
        [self addGestureRecognizer:tap];
        
        
    }
    return self;
}

- (void)tapImage
{

    [[NSNotificationCenter defaultCenter] postNotificationName:Noti_RemoveBobyView object:[NSString stringWithFormat:@"%d",self.imageSetle]];

}

//- (void)tapImage {
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        
//        if (self.state == XYZPhotoStateNormal) {
//            //关闭定时器
////            [_timer setFireDate:[NSDate distantFuture]];
//             _swipeselet = _imageSetle;
//            
//            self.oldFrame = self.frame;
//            self.oldimageFrame = self.imageView.frame;
//            self.oldlabelFrame = _timeLabel.frame;
//            self.oldAlpha = self.alpha;
//            self.oldSpeed = self.speed;
//            self.transform = CGAffineTransformScale(self.transform, 1 / self.oldAlpha , 1 / self.oldAlpha);
//            self.frame = CGRectMake(0, 0, self.superview.bounds.size.width, self.superview.bounds.size.height);
//            NSLog(@"---%f,--%f",self.superview.bounds.size.height,self.height);
//            self.imageView.frame = CGRectMake(100,100, self.width - 200, self.height - 200);
//            _timeLabel.frame = CGRectMake(0, self.height - 100, self.width, 100);
//            self.layer.borderWidth = 1;
//            self.layer.borderColor = [[UIColor whiteColor] CGColor];
//            _timeLabel.backgroundColor = [UIColor clearColor];
//            _timeLabel.textColor = [UIColor whiteColor];
//            _timeLabel.font = [UIFont systemFontOfSize:18.0];
//            self.drawView.frame = CGRectMake(0, 0, self.width, self.height);
//            self.drawView.backgroundColor = [UIColor blackColor];
//            self.drawView.alpha = .5;
//            [self.superview bringSubviewToFront:self];
//            self.speed = 0;
//            self.alpha = 1;
//            self.state = XYZPhotoStateBig;
//            
//       
//            
//            _rightswipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipImage:)];
//            _rightswipeG.direction = UISwipeGestureRecognizerDirectionLeft;
//            [self addGestureRecognizer:_rightswipeG];
//            
//            _leftSwipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipImage:)];
//            _leftSwipeG.direction = UISwipeGestureRecognizerDirectionRight;
//            [self addGestureRecognizer:_leftSwipeG];
//            
//            
//        } else if (self.state == XYZPhotoStateBig) {
//            //开启定时器
////            [_timer setFireDate:[NSDate distantPast]];
//            self.transform = CGAffineTransformScale(self.transform, self.oldAlpha , self.oldAlpha);
//            self.frame = self.oldFrame;
//            self.imageView.frame = self.oldimageFrame;
//            _timeLabel.frame = self.oldlabelFrame;
//            self.layer.borderWidth = 1;
//            self.layer.borderColor = [[UIColor whiteColor] CGColor];
//            _timeLabel.backgroundColor = [UIColor whiteColor];
//            _timeLabel.textColor = [UIColor blackColor];
//            _timeLabel.font = [UIFont systemFontOfSize:13.0];
//            self.drawView.frame = self.bounds;
//            self.drawView.backgroundColor = [UIColor blackColor];
//            self.drawView.alpha = 1;
//            self.alpha = self.oldAlpha;
//            self.speed = self.oldSpeed;
//            self.state = XYZPhotoStateNormal;
//            
//            [self removeGestureRecognizer:_leftSwipeG];
//            [self removeGestureRecognizer:_rightswipeG];
//        }
//        
//    }];
//   
//}


//- (void)swipImage:(UISwipeGestureRecognizer *)recognizer {
//    
//    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
//         _swipeselet --;
//        if (_swipeselet > 0) {
//            STDImagetice *imagetice = self.imageArray[_swipeselet];
//            UIImage *image = [UIImage imageWithData: imagetice.data];
//            [self updateImage:image withTitlestring:imagetice.EnddateString];
//           
//        } else {
//            _swipeselet = 0;
//            STDImagetice *imagetice = self.imageArray[0];
//            UIImage *image = [UIImage imageWithData: imagetice.data];
//            [self updateImage:image withTitlestring:imagetice.EnddateString];
//        }
//       
//
//        
//    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
//        _swipeselet ++;
//        if (_swipeselet < self.imageArray.count) {
//            STDImagetice *imagetice = self.imageArray[_swipeselet];
//            UIImage *image = [UIImage imageWithData: imagetice.data];
//            [self updateImage:image withTitlestring:imagetice.EnddateString];
//        } else {
//            _swipeselet = (int)self.imageArray.count;
//            STDImagetice *imagetice = self.imageArray[self.imageArray.count - 1];
//            UIImage *image = [UIImage imageWithData: imagetice.data];
//            [self updateImage:image withTitlestring:imagetice.EnddateString];
//        }
//    }
//}


- (void)updateImage:(UIImage *)image withTitlestring:(NSString *)Titlestring {
    self.imageView.image = image;
    _timeLabel.text = [NSString stringWithFormat:@"%@",Titlestring];
    NSLog(@"image......");
}


- (void)setImageAlphaAndSpeedAndSize:(float)alpha {
    self.alpha = alpha ;
    self.speed = alpha;
    self.transform = CGAffineTransformScale(self.transform, alpha , alpha);
}

- (void)movePhotos {
    self.center = CGPointMake(self.center.x + self.speed, self.center.y);
    if (self.center.x > self.superview.bounds.size.width + self.frame.size.width/2) {
        self.center = CGPointMake(-self.frame.size.width, arc4random()%(int)(self.superview.bounds.size.height - self.bounds.size.height - 100) + 90 + self.bounds.size.height / 2.0);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
