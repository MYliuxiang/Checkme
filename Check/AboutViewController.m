//
//  AboutViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14/10/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "AboutViewController.h"
#import "MobClick.h"
#import "Colors.h"

@implementation AboutViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"AboutPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"AboutPage"];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setVersion];
    [self setAppIconImg];
    [self setAppName];
    
    if (kScreenHeight < 500) {
        [self _initView];
    }
    
//    self.view.backgroundColor = RGB(239, 239, 244);
    self.view.backgroundColor = [UIColor whiteColor];
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
}


- (void)_initView
{

    _lab_1.top =  200 + 80;
    _lab_2.top = _lab_1.bottom + 5;
    _lab_3.top = _lab_2.top;
    _lab_4.top = _lab_3.bottom + 5;
    _lab_5.top = _lab_4.top;
    
    _lab1.top = _lab_5.bottom + 20;
    _lab2.top = _lab1.bottom + 5;
    _lab3.top = _lab2.bottom + 5;
    _lab4.top = _lab3.bottom + 5;


}


-(void)setVersion
{
    NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_lblVersion setText:appVer];
}

- (void) setAppIconImg
{
    _appIconImg.image = [UIImage imageNamed:@"BMicon.png"];
    
    if (isThomson == YES) {   //如果是法国定制版Thomson
        _appIconImg.image = [UIImage imageNamed:@"thomson_icon.png"];
    }
    
    if (isSemacare == YES) {
        _appIconImg.image = [UIImage imageNamed:@"semacare_icon.png"];
    }
}

- (void) setAppName
{
    _appName.text = @"BodiMetrics";
    
    if (isThomson == YES) {   //如果是法国定制版
        _appName.text = @"Thomson HC CheckMe";
        _appName.font = [UIFont systemFontOfSize:20];
    }
    
    if (isSemacare == YES) {
        _appName.text = @"semacare";
        _appName.font = [UIFont systemFontOfSize:20];
    }
}

- (IBAction)showLeftMenu:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


@end
