//
//  NavigationViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-5.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "NavigationViewController.h"
#import "UserList.h"
#import "FileParser.h"
#import "PublicMethods.h"

#import "MobClick.h"

#import "SettingsViewController.h"

@interface NavigationViewController ()

@property (nonatomic,retain) NSMutableArray *arrFindPeripheral;
@property (nonatomic,retain) NSTimer *scanTimer;//定义个计时器
@property (nonatomic, strong) CloudUpLodaManger *cloudView;

@end

@implementation NavigationViewController

@synthesize arrFindPeripheral = _arrFindPeripheral;
@synthesize scanTimer = _scanTimer;

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"NaviPage"];
    [self.navigationBar addSubview:_cloudView];

}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"NaviPage"];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cloudView = [CloudUpLodaManger sharedManager];
    self.cloudView.frame = CGRectMake(self.view.bounds.size.width - 33 - 19 - 40,  10, 60, 25);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.cloudView addGestureRecognizer:tap];
    [self.navigationBar addSubview:_cloudView];
    
    //设置系统返回按钮的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (void)tap
{
    
    if (![AppDelegate GetAppDelegate].isOffline) { //在线状态
        
        if (![[UserDefaults objectForKey:@"fileVer"] isEqualToString:@"1.1"]) {
            
            [SVProgressHUD showWithStatus:DTLocalizedString(@"please Update...", nil)];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
            return;
        }
    }
    
    if (![self.viewControllers.lastObject isKindOfClass:[SettingsViewController class]]) {
        
        SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
        [self pushViewController:settingsViewController animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
