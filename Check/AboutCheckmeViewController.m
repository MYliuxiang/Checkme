//
//  AboutCheckmeViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "AboutCheckmeViewController.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "CheckmeInfo.h"
#import "SVProgressHUD.h"
#import "CheckmeUpdateViewController.h"
#import "NetworkUtils.h"
#import "PostUtils.h"
#import "PostInfoMaker.h"
#import "SIAlertView.h"
#import "NoInfoViewUtils.h"

#import "MobClick.h"
@interface AboutCheckmeViewController() <BTCommunicationDelegate,UIAlertViewDelegate>

@property(nonatomic,retain)CheckmeInfo *checkmeInfo;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

//@property(nonatomic,strong)NSArray *languageList; //自己加的  hjz    不需要了
//@property(nonatomic,strong) UIAlertView *alertView; //自己加的  hjz  不需要了

@end

static int i = 0; //定义的这个  i  变量是用来检测是否需要更新(update)操作的  需要就跳弹框选择更新,不需要则 用 SVProgressHUD 来提示即可(提示当前是最新版本的)

@implementation AboutCheckmeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self getCheckmeInfo];
    
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            [obj setHidden:YES];
        }
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = DTLocalizedString(@"Back", nil);
    self.navigationItem.backBarButtonItem = backItem;
    
    [BTCommunication sharedInstance].delegate = self;//设置代理
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"UpdatePage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"UpdatePage"];
}

- (IBAction)showLeftMenu:(id)sender
{
    if (![AppDelegate GetAppDelegate].isOffline) { //在线状态
        
        if (![[UserDefaults objectForKey:@"fileVer"] isEqualToString:@"1.1"]) {
            
            [SVProgressHUD showWithStatus:DTLocalizedString(@"Please update...", nil)];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
            return;
        }
        
    }
    
    if(![[BTCommunication sharedInstance] bLoadingFileNow])
    {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        
    }else{
        
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];//显示时间 。。 2 秒后自动消失隐藏
    }
}

//通过蓝牙获取设备信息
-(void)getCheckmeInfo
{
    //如果离线模式，直接返回

    DLog(@"输出app的状态，isOffline = %c", [AppDelegate GetAppDelegate].isOffline);
    if ([AppDelegate GetAppDelegate].isOffline) {   //离线模式---外设蓝牙关闭状态
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not get Checkme information in Offline mode", nil) duration:2];
        
        //离线模式 显示空白   （当前如果是离线模式 再 加上以前没有连接过任何外设的话 就是显示空白部分）
        for (UIView *view in [self.view subviews]) {//当前视图中移除
            [view removeFromSuperview];
        }
        [NoInfoViewUtils showNoInfoView:self];
        
        return;
    }
    
    if(![[BTCommunication sharedInstance] bLoadingFileNow]){   //当前无文件正在下载
        
        DLog(@"开始获取设备信息");
        [[BTCommunication sharedInstance] BeginGetInfo];
    }else{  //如果正在下载别的文件，   //YES   有文件正在下载
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:3];//提示性文字的持续时间  duration 设置  (使用第三方的 SVProgressHUD  还有一个第三方的是 MBProgressHUD)
    }
}

//获取设备信息成功的回调
- (void)getInfoSuccessWithData:(NSData *)data
{
    [BTCommunication sharedInstance].delegate = nil;
    _checkmeInfo = [[CheckmeInfo alloc] initWithJSONStr:data];
    [self refreshInfoView:_checkmeInfo];
}

//取设备信息失败
- (void)getInfoFailed
{
    [BTCommunication sharedInstance].delegate = nil;
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Get Checkme information failed", nil) duration:2];
}

//刷新设备信息View，获取信息成功时调用
-(void)refreshInfoView:(CheckmeInfo*)checkmeInfo
{
    if (!checkmeInfo) {
        return;
    }
    [_lblSeries setText:[self makeSeries:checkmeInfo.model]];
    [_lblVersion setText:[self makeSoftwareVersionStr:checkmeInfo.software]];
    [_lblSN setText:checkmeInfo.sn];//版本号
}

//由model号转换成系列名称
-(NSString*)makeSeries:(NSString*) model
{
    if ([model isEqualToString:@"6632"]) {
//        return @"Checkme Pro";
        return @"BodiMetrics";
    }else if ([model isEqualToString:@"6631"]) {
//        return @"Checkme Plus";
         return @"BodiMetrics";
    }else if ([model isEqualToString:@"6621"]) {
//        return @"Checkme Lite";
         return @"BodiMetrics";
    }else if ([model isEqualToString:@"6611"]) {
//        return @"Checkme Pod";
         return @"BodiMetrics";
    }else {//其他的就是不知道的类型设备
        return @"Unknow device";
    }
}

//生成便于查看的版本str
-(NSString*)makeSoftwareVersionStr:(NSString*)inStr
{
    int version = [inStr intValue];
    if (version<0) {
        return @"--";
    }
    NSMutableString * versionStr = [NSMutableString string];
    [versionStr appendFormat:@"%d.",version/10000];
    [versionStr appendFormat:@"%d.",(version%10000)/100];
    [versionStr appendFormat:@"%d",version%100];

    return versionStr;
}

#warning 设备升级操作
//设备升级操作
//升级按钮处理函数   update
-(IBAction)onBnUpdateClicked:(id)sender
{

    DLog(@"点击updata按钮 输出_checkmeInfo = %@", _checkmeInfo);

#warning 检测当前的网络
    if (![NetworkUtils isNetworkEnabled]) {  //如果网络不可用
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Network is not available", nil) duration:2];//提示当前的网络不可用信息
        return;
    }else if (!_checkmeInfo || [AppDelegate GetAppDelegate].isOffline) {   //如果没有外设
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Can not update in Offline mode", nil) duration:2];
        return;
    }
    
    
    [self getLanguageList];//语言列表
}

//获取语言列表，升级按钮按下后调用
-(void)getLanguageList
{
    if (!_checkmeInfo) {
        return;
    }
    //创建一个活动指示器   提示正在下载
    [SVProgressHUD showWithStatus:DTLocalizedString(@"Loading...", nil) maskType:SVProgressHUDMaskTypeBlack];
    // 通过PostInfoMaker 获得语言请求参数
    NSString* dataStr = [PostInfoMaker makeGetLanguageListInfo:_checkmeInfo];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];//从通知中心移除某个通知对象
    
    //问：通知在何处创建的？  答：postUtils中  数据传输完后调用的方法中 创建的
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGetLanguageListSuccess:) name:NtfName_PostSuccess object:nil];//调用获取语言列表成功的方法
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGetLanguageListError) name:NtfName_PostError object:nil];
    DBG(@"1111111111111111111111111111------------------------^^^^^^^^^^^^^^^^^^^^^^>>>>>>>>>>>>>>>>>>>>%d", i);
    // 通过PostUtils发post请求
    [PostUtils doPost:URL_GET_LANGUAGE_LIST DataStr:dataStr];
    
}

#warning 这里这个json数据解析 貌似没有派上用场...好像没有什么json数据用来解析一样
//获取语言列表成功
-(void)onGetLanguageListSuccess:(NSNotification *)ntf
{
    //活动指示器停止
    [SVProgressHUD dismiss];
    NSMutableData* responseData = ntf.object;
    if (responseData) {
        NSError *err;
        //json  序列化
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&err];
        DLog(@"获取语言列表成功,服务器返回的语言数据:%@", jsonObject);//使用苹果自带的json解析数据
        NSString *result;
      
        self.json = jsonObject;
        NSString *version = jsonObject[@"version"];
        if ([version isEqualToString:[self makeSoftwareVersionStr:_checkmeInfo.software]]) {
           
            [self showUnnecessaryUpdate];

            
        }else{
        
            NSDictionary *languageDIC = jsonObject[@"language"];
            NSArray *languageList = [languageDIC allKeys];
            [self showUpdateWarning:languageList];
        
        }
        
        if (jsonObject == nil) {
            
            [self showUpdateFailed];

        }
        
//        if (jsonObject!=nil && (result=[jsonObject objectForKey:@"Result"])!=nil ) {
//            if ([result isEqual:@"NECESSARY"]) {
//                //需要升级
//                
//                //得到语言列表的数组
//                NSArray* languageList = [self decodeLanguageList:jsonObject];
//                [self showUpdateWarning:languageList];
//            }else if ([result isEqual:@"UNNECESSARY"]) {
//                //可以不升级
//                NSArray* languageList = [self decodeLanguageList:jsonObject];
//                [self showSwitchLanguage:languageList];
//            }else if ([result isEqual:@"NULL"]) {//为空的时候
//                //不能升级
//                i++;
//                [self showUnnecessaryUpdate];
//                DBG(@"22222222222222222222222222------------------------^^^^^^^^^^^^^^^^^^^^^^>>>>>>>>>>>>>>>>>>>>%d", i);
//            }else if ([result isEqual:@"EXP"]) {
//                //服务器错误
//                [self showUpdateFailed];
//            }
//        }else{
//
        
//            [self showUpdateFailed];
//        }
    }
}

//获取语言列表失败
-(void)onGetLanguageListError
{
    //活动指示器停止
    [self.indicator stopAnimating];// 停止的动画
    [self.backView  removeFromSuperview]; //提示性文字 移除操作的方法
    [self.indicator removeFromSuperview];
    [self showUpdateFailed];  //显示升级失败
}

//解析json字符串  获得语言数组
-(NSArray*)decodeLanguageList:(NSDictionary*) jsonObject
{
    if (!jsonObject) {
        return nil;
    }
    NSArray* languageList = [jsonObject objectForKey:@"LanguageList"];
   
    return languageList;//返回语言列表
}

//***************************************************//
//  当设备需要升级时  调用此方法
-(void)showUpdateWarning:(NSArray*) languageList
{
//    if (!languageList) {
//        return;
//    }
//    if ([_checkmeInfo.software integerValue] < 10105) {  //话说这是版本号判断
//            //SIAlertView的另一些用法！！！
//            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil)andMessage:@"Update will erase all data"]; //更新提示
//        
//            //添加按钮的同时   在block中给按钮添加相应的点击点击事件
//            //  点击update按钮  执行对应点击事件
//            [alertView addButtonWithTitle:DTLocalizedString(@"Update", nil) type: SIAlertViewButtonTypeDefault  handler:^(SIAlertView *alertView) {
//        //SIAlertViewButtonTypeDestructive
//                [self showLanguageList:languageList];
//            }];
//            //取消按钮
//            [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
//                                     type:SIAlertViewButtonTypeCancel
//                                  handler:^(SIAlertView *alertView) {
//                                      // 点击取消 什么都不做
//                                  }];
//            [alertView show];
//    
//    } else {
//    
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil) andMessage:DTLocalizedString(@"Update will erase all data", nil)]; //更新提示
//        
//        //添加按钮的同时   在block中给按钮添加相应的点击事件
//        //  点击update按钮  执行对应点击事件
//        [alertView addButtonWithTitle:DTLocalizedString(@"Update", nil) type: SIAlertViewButtonTypeDestructive  handler:^(SIAlertView *alertView) {
//            
//            [self showLanguageList:languageList];
//        }];
//        //取消按钮
//        [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alertView) {
//                                  // 点击取消 什么都不做
//                              }];
//        [alertView show];
//
//    
//    }

    
#warning //自己加的  hjz  自己弄的弹框提示  使用系统自带的
    if (!languageList) {
        return;
    }
    if ([_checkmeInfo.software integerValue] < 10105) {  //话说这是版本号判断
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:DTLocalizedString(@"Warning", nil) message:DTLocalizedString(@"Update will erase all data",nil )preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *Update = [UIAlertAction actionWithTitle:DTLocalizedString(@"Update", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {// 当 style 为 UIAlertActionStyleCancel 时,显示蓝色 文字的按钮  并且显示在 左边
            //点击弹框中的更新按钮...做的操作
            [self showLanguageList:languageList];
        }];
        
        UIAlertAction *Cancel = [UIAlertAction actionWithTitle:DTLocalizedString(@"Cancel", nil) style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { // 当 style 为 UIAlertActionStyleDestructive 时,显示红色 文字的按钮  并且显示在 右边
            //点击弹框中的取消按钮...不做任何操作
    
        }];
         [alert addAction:Cancel];  //取消按钮
        [alert addAction:Update];  //更新按钮
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:DTLocalizedString(@"Warning", nil) message:DTLocalizedString(@"Update will erase all data",nil ) preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *Update = [UIAlertAction actionWithTitle:DTLocalizedString(@"Update", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //点击弹框中的更新按钮...做的操作
            [self showLanguageList:languageList];
        }];
        
        UIAlertAction *Cancel = [UIAlertAction actionWithTitle:DTLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            //点击弹框中的取消按钮...不做任何操作
            
        }];
        
        [alert addAction:Update];  //更新按钮
        [alert addAction:Cancel];  //取消按钮
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//实现系统自带弹框UIAlertView  的代理方法
#pragma mark -  UIAlertView Delegate  的代理方法  iOS8 及 以前需要实现代理方法(iOS9就不需要了)


-(void)showLanguageList:(NSArray*) languageList
{
   
//    if (!languageList) {
//        return;
//    }
//    
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Choose a languge", nil)];  //语言选择
//    
//    for (int i=0; i<languageList.count; i++) {
//        // 添加语言button  点击对应button进入相应下载页面
//        [alertView addButtonWithTitle:[languageList objectAtIndex:i] type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
//            
//            //点击进入升级页面
//            [self gotoCheckmeUpdateViewController:[languageList objectAtIndex:i]];
//        }];
//    }
//    [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
//                             type:SIAlertViewButtonTypeCancel
//                          handler:^(SIAlertView *alertView) {
//                          }];
//    [alertView show];
    
    
#warning //自己加的  hjz  自己弄的弹框提示  使用系统自带的
    if (!languageList) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:DTLocalizedString(@"Choose a languge", nil) preferredStyle:UIAlertControllerStyleAlert]; //语言选择
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:DTLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //取消
    }];
    [alert addAction:Cancel];  //取消按钮
    for (int i = 0; i < languageList.count; i++) {
        // 添加语言button  点击对应button进入相应下载页面
        UIAlertAction *upgrade = [UIAlertAction actionWithTitle:[languageList objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //点击进入升级页面
            [self gotoCheckmeUpdateViewController:[languageList objectAtIndex:i]];
        }];
        
        [alert addAction:upgrade]; //升级按钮
        
    }
 
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
//  跳转到升级页面
-(void)gotoCheckmeUpdateViewController:(NSString*) wantLanguage
{
    CheckmeUpdateViewController *checkmeUpdateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkmeUpdateViewController"];
    checkmeUpdateViewController.checkmeInfo = _checkmeInfo;
    checkmeUpdateViewController.wantLanguage = wantLanguage;
    checkmeUpdateViewController.json = self.json;
    [self.navigationController pushViewController:checkmeUpdateViewController animated:YES];
}

//***************************************************//
//当设备无需升级 但可以切换语言时  调用此方法
-(void)showSwitchLanguage:(NSArray*) languageList
{
//    if (!languageList) {
//        return;
//    }
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Your version is up to date", nil)];
//    alertView.buttonFont = [UIFont systemFontOfSize:14];
//    
//    [alertView addButtonWithTitle:DTLocalizedString(@"Change Language", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
//        [self showUpdateWarning:languageList];
//    }];
//#warning 点击 取消按钮 Cancel   hjzXx
//    [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
//                             type:SIAlertViewButtonTypeCancel
//                          handler:^(SIAlertView *alertView) {
//                          }];
//    [alertView show];
    
#warning //自己加的  hjz  自己弄的弹框提示  使用系统自带的
    if (!languageList) {
        return;
    }
#warning 这里需要判断处理下....是否需要 update  更新操作   如果不需要更新 直接调用  showUnnecessaryUpdate 这个提示当前是最新版本的提示方法  如果需要才往下走
    if (i == 0) {
        DBG(@"3333333333333333333333333333333------------------------^^^^^^^^^^^^^^^^^^^^^^>>>>>>>>>>>>>>>>>>>>%d", i);
        [self showUnnecessaryUpdate];
    }
    else{
#warning  其实这里 这个什么弹框提示改变语言是多余的写法.....因为这里只有英文并没有多余的语言选择...不知道是谁这样设计的...fuck  （下面这些代码是多余的.......亲。。可以忽略哦）
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:DTLocalizedString(@"Your version is up to date", nil) preferredStyle:UIAlertControllerStyleAlert]; // 当 在 使用update 更新操作时,当版本最新时..提示 Your version is up to date  （版本是最新的）
    UIAlertAction *update = [UIAlertAction actionWithTitle:DTLocalizedString(@"Change Language", nil) style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {//这里的文字过长了...弹框样式都被改变了
        //点击更新语言列表
        [self showUpdateWarning:languageList];
    }];
    
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:DTLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //取消
    }];
    
    [alert addAction:Cancel];  //取消按钮
    [alert addAction:update]; //升级按钮
    [self presentViewController:alert animated:YES completion:nil];
    }
   
}

//显示无需升级
-(void)showUnnecessaryUpdate
{
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Your version is up to date", nil) duration:2];
    
}

//显示升级失败
-(void)showUpdateFailed
{
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Update failed", nil) duration:2];
}

@end
