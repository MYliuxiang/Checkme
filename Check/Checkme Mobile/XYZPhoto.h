//
//  XYZPhoto.h
//  demo6_PhotoRiver
//
//  Created by BOBO on 15/3/23.
//  Copyright (c) 2015年 BobooO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYZDrawView.h"
#import "PosterView.h"
typedef NS_ENUM(NSInteger, XYZPhotoState) {
    XYZPhotoStateNormal,
    XYZPhotoStateBig,
    XYZPhotoStateDraw,
    XYZPhotoStateTogether
};


@interface XYZPhoto : UIView
{
    NSTimer *_timer;
    PosterView *_posterView;
    UISwipeGestureRecognizer *_rightswipeG;
    UISwipeGestureRecognizer *_leftSwipeG;
    int _swipeselet;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) XYZDrawView *drawView;
@property (nonatomic) float speed;
@property (nonatomic) CGRect oldFrame;
@property (nonatomic) CGRect oldimageFrame;
@property (nonatomic) CGRect oldlabelFrame;
@property (nonatomic) float oldSpeed;
@property (nonatomic) float oldAlpha;
@property (nonatomic) int state;
@property (nonatomic) int imageSetle;
@property (nonatomic,strong)NSArray *imageArray;

- (void)updateImage:(UIImage *)image withTitlestring:(NSString *)Titlestring;
- (void)setImageAlphaAndSpeedAndSize:(float)alpha;

@end
