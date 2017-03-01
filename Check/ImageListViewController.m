//
//  ImageListViewController.m
//  IOS_Minimotor
//
//  Created by lijiang on 15/11/6.
//  Copyright © 2015年 Viatom. All rights reserved.
//

#import "ImageListViewController.h"
#import "XYZPhoto.h"

#define IMAGEWIDTH 160
#define IMAGEHEIGHT 142
@interface ImageListViewController ()
{
    float patient_info_h;
    UILabel *_playandstoplable;//
    PosterView *_posterView;

}
@property (nonatomic, strong) UIView *patientInfo;
@end

@implementation ImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imageView.image = [UIImage imageNamed:@"bgxing"];
    [self.view addSubview:imageView];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    }
    _patientInfo = [[UIView alloc] initWithFrame:rect(0, 0, CUR_SCREEN_W, 60)];
    _patientInfo.backgroundColor = RGB(213, 213, 213);
    _patientInfo.alpha = 1;
    [self.view addSubview:_patientInfo];
    patient_info_h = _patientInfo.bounds.size.height - 20;
    _patientInfo.tag = 1000;
    
    UIView *taberView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    taberView.backgroundColor = [UIColor blackColor];
    [_patientInfo addSubview:taberView];
    
    
    if (_patientInfo) {
        
        UILabel *patientInfo = [[UILabel alloc] initWithFrame:rect(10, 20, 100, 40)];
        patientInfo.font = [UIFont boldSystemFontOfSize:15];
        patientInfo.tag = 100;
        patientInfo.textColor = [UIColor blackColor];
        patientInfo.backgroundColor = [UIColor clearColor];
        patientInfo.userInteractionEnabled = YES;
        patientInfo.textAlignment = NSTextAlignmentLeft;
        patientInfo.text = @"< 返回";
        [_patientInfo addSubview:patientInfo];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapbtuAction:)];
        [patientInfo addGestureRecognizer:tap];
        
        UILabel *patientInfo1 = [[UILabel alloc] initWithFrame:rect((kScreenWidth - 100) / 2.0, 20, 100, 40)];
        patientInfo1.font = [UIFont boldSystemFontOfSize:15];
        patientInfo1.numberOfLines = 0;
        patientInfo1.textColor = [UIColor blackColor];
        patientInfo1.backgroundColor = [UIColor clearColor];
        patientInfo1.userInteractionEnabled = YES;
        patientInfo1.textAlignment = NSTextAlignmentCenter;
        patientInfo1.text = @"图集";
        [_patientInfo addSubview:patientInfo1];
               
       }
    
   
   
    
    [self _initData];
}

- (void)_initData
{
     self.photos = [NSMutableArray new];
    
    //添加9个图片到界面中
    if (self.imageArray) {
        for (int i = 0; i < self.imageArray.count; i++) {
            float X = arc4random()%((int)kScreenWidth- IMAGEWIDTH);
            float Y = (arc4random()%((int)kScreenHeight - IMAGEHEIGHT - 80)) + 80;
            float W = IMAGEWIDTH;
            float H = IMAGEHEIGHT;
            
            STDImagetice *imagetice = self.imageArray[i];
            UIImage *image = [UIImage imageWithData: imagetice.data];
            XYZPhoto *photo = [[XYZPhoto alloc]initWithFrame:CGRectMake(X, Y, W, H)];
            photo.imageSetle = i;
            photo.imageArray = self.imageArray;
            [photo updateImage:image withTitlestring:imagetice.EnddateString];
            [self.view addSubview:photo];
            float alpha = .7 / (float)self.imageArray.count * i  + .3;
            [photo setImageAlphaAndSpeedAndSize:alpha];
            
            [self.photos addObject:photo];
        }
    }
    
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [self.view addGestureRecognizer:doubleTap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removebobyView:) name:Noti_RemoveBobyView object:nil];
    

}


- (void)removebobyView:(NSNotification *)objec
{
    
    if ([objec.object isEqualToString:@"hiud"]) {
         _posterView.hidden = YES;
    } else {
        //2.创建海报视图
        
        if (_posterView == nil) {
            _posterView = [[PosterView alloc] initWithFrame:self.view.bounds];
            _posterView.backgroundColor = [UIColor grayColor];
            //吧数据给海报视图
            _posterView.dataList = self.imageArray;
            [self.view addSubview:_posterView];
            
        } else {
            
            _posterView.hidden = NO;
        }
         _posterView.posterHeaderTableView.selectedIndexPath = [NSIndexPath indexPathForRow:[objec.object integerValue] inSection:0];
         _posterView.postBodyTableView.selectedIndexPath = [NSIndexPath indexPathForRow:[objec.object integerValue] inSection:0];
        [_posterView.postBodyTableView scrollToRowAtIndexPath:_posterView.postBodyTableView.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [_posterView.posterHeaderTableView scrollToRowAtIndexPath:_posterView.posterHeaderTableView.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    }
}


- (void)doubleTap {
    
    NSLog(@"DoubleTap...........");
    
    for (XYZPhoto *photo in self.photos) {
        if (photo.state == XYZPhotoStateDraw || photo.state == XYZPhotoStateBig) {
            return;
        }
    }
    
    float W = self.view.bounds.size.width / 3;
    float H = self.view.bounds.size.height / 3;
    
    [UIView animateWithDuration:1 animations:^{
        for (int i = 0; i < self.photos.count; i++) {
            XYZPhoto *photo = [self.photos objectAtIndex:i];
            
            if (photo.state == XYZPhotoStateNormal) {
                photo.oldAlpha = photo.alpha;
                photo.oldFrame = photo.frame;
                photo.oldSpeed = photo.speed;
                photo.alpha = 1;
                photo.frame = CGRectMake(i%3*W, i/3*H, W, H);
                photo.imageView.frame = photo.bounds;
                photo.drawView.frame = photo.bounds;
                photo.speed = 0;
                photo.state = XYZPhotoStateTogether;
            } else if (photo.state == XYZPhotoStateTogether) {
                photo.alpha = photo.oldAlpha;
                photo.frame = photo.oldFrame;
                photo.speed = photo.oldSpeed;
                photo.imageView.frame = photo.bounds;
                photo.drawView.frame = photo.bounds;
                photo.state = XYZPhotoStateNormal;
            }
        }
        
    }];
    
}

//返回  事件
- (void)tapbtuAction:(UITapGestureRecognizer *)tap
{
    //返回上个界面
    if (tap.view.tag == 100) {

        [self dismissViewControllerAnimated:YES completion:nil];
//        [_posterView removeFromSuperview];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
