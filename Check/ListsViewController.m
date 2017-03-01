//
//  ListsViewController.m
//  IOS_Minimotor
//
//  Created by 李江 on 15/11/15.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "ListsViewController.h"
#import "PlayMovieViewController.h"
#import "VIPhotoView.h"
#define statusBar_height 20



@interface ListsViewController ()<PlayMovieViewControllerDelegate>
{
    float patient_info_h;
    UIImageView *_phtotImageView;
    UIImageView *_playImageView;
    UILabel *_titleLable;
    NSString *_typeString;
    NSInteger _selePath;
    VIPhotoView *_viphotoView;
    

}
@property (nonatomic, strong) UIView *patientInfo;

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _initView];
}

- (void)_initView
{
    
    
    
    patient_info_h = 0.0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];  //屏幕长亮
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popVC) name:@"pop" object:nil];
    
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor blackColor];
   
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //    （获取当前电池条动画改变的时间）
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
    
    [UIView commitAnimations];
    
    //状态栏
    //        [UIApplication sharedApplication].statusBarHidden = YES;
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
        patientInfo.text = @"< back";
        [_patientInfo addSubview:patientInfo];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapbtuAction:)];
        [patientInfo addGestureRecognizer:tap];
        
    }

    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, 210, kScreenHeight - 60) style:UITableViewStylePlain];
    tableView.rowHeight = 50;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    
    _phtotImageView =[[UIImageView alloc]initWithFrame:CGRectMake(tableView.right + 10, 60, kScreenWidth - 230, kScreenHeight - 60)];
    _phtotImageView.backgroundColor = [UIColor clearColor];
    _phtotImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_phtotImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapList)];
    _phtotImageView.userInteractionEnabled = YES;
    [_phtotImageView addGestureRecognizer:tap];
    
    _playImageView =[[UIImageView alloc]initWithFrame:CGRectMake((_phtotImageView.width - 120 * ration_H ) / 2.0, (_phtotImageView.height - 120 * ration_H) / 2.0 - 30, 120 * ration_H, 120 * ration_H)];
    _playImageView.hidden = YES;
    _playImageView.backgroundColor = [UIColor clearColor];
    _playImageView.image = [UIImage imageNamed:@"play"];
    _playImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_phtotImageView addSubview:_playImageView];

    

    _titleLable =[[UILabel alloc]initWithFrame:CGRectMake((_phtotImageView.width - 300 ) / 2.0, _playImageView.bottom + 10, 300, 40)];
    _titleLable.hidden = YES;
    _titleLable.backgroundColor = [UIColor clearColor];
    _titleLable.font = [UIFont boldSystemFontOfSize:18.0 ];
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    [_phtotImageView addSubview:_titleLable];
    
   

}

- (BOOL)shouldAutorotate{
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

//点击事件
- (void)tapList
{
    Notice *noti = _noticeArray[_selePath];
   
    if ([_typeString isEqualToString:@"image"]) {
         UIImage *image = [UIImage imageWithData: noti.data];
        if (_viphotoView == nil) {
            _viphotoView = [[VIPhotoView alloc] initWithFrame:CGRectMake(-kScreenWidth,- kScreenHeight,kScreenWidth,kScreenHeight) andImage:image];
            _viphotoView.backgroundColor = [UIColor redColor];
            _viphotoView.alpha = 0;
            _viphotoView.autoresizingMask = (1 << 6) -1;
            [self.view addSubview:_viphotoView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(huifutap)];
            [_viphotoView addGestureRecognizer:tap];
        }
       
    [UIView animateWithDuration:.35 animations:^{
        _viphotoView.top = 0;
        _viphotoView.left = 0;
        _viphotoView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
        
}
    
    if ([_typeString isEqualToString:@"movie"]) {
        
        PlayMovieViewController *play = [[PlayMovieViewController alloc]init];
        play.notice = noti;
        play.PlayMovieVCDelegate = self;
        [self presentViewController:play animated:YES completion:nil];
    }

}

//点击回复小图
- (void)huifutap
{
    [UIView animateWithDuration:.35 animations:^{
        _viphotoView.top = -  kScreenWidth;
        _viphotoView.left = - kScreenHeight;
        _viphotoView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];

}

#pragma mark ------- uitableView ------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.noticeArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *idstring = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idstring];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idstring];
        //创建图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(210 - 40, (50 - 15) / 2.0, 15, 15)];
        //tag
        imageView.tag = 103;
        imageView.hidden = YES;
        imageView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:imageView];

    }
    
    Notice *noti = self.noticeArray[indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text = noti.EnddateString;
    //获取图片视图
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
    
    if ([noti.typeSting isEqualToString:@"movie"]) {
        imageView.hidden = NO;
        imageView.image = [UIImage imageNamed:@"imageList"];
    } else {
        imageView.hidden = NO;
        imageView.image = [UIImage imageNamed:@"tupianimage"];
    
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Notice *noti = self.noticeArray[indexPath.row];
    _typeString = noti.typeSting;
    _selePath = indexPath.row;
    
    if ([noti.typeSting isEqualToString:@"movie"]) {
        _playImageView.hidden = NO;
        _titleLable.hidden = NO;
//        self.view.backgroundColor = RGB(91, 155, 213);
        _phtotImageView.image = [UIImage imageNamed:@""];
        _titleLable.text = noti.EnddateString;
        
        
    } else {
    
        _playImageView.hidden = YES;
        _titleLable.hidden = YES;
         UIImage *image = [UIImage imageWithData: noti.data];
        self.view.backgroundColor = [UIColor blackColor];
        _phtotImageView.image = image;
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
     
        NSMutableArray *new  = [NSMutableArray new];
        [new addObjectsFromArray:self.noticeArray];
        [new removeObjectAtIndex:indexPath.row];
        self.noticeArray = new;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        //从数据库删除
        NSArray *array = [Notice allDbObjects];
        Notice *notice = array[(array.count - 1 - indexPath.row)];
        [notice removeFromDb];

    }

}

- (void)tapbtuAction:(UITapGestureRecognizer *)tap
{
    //返回上个界面
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_popVC
{
    //返回上个界面
    [self dismissViewControllerAnimated:NO completion:nil];
    [_ListsVCdelegate gotoVC];

}
#pragma mark ------ PlayMovieViewControllerDelegate -----------
- (void)gotoVC
{

    [self _popVC];
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
