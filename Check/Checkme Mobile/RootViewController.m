 //
//  RootViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-5.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//


#import "RootViewController.h"
#import "UserList.h"
#import "FileParser.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "BTUtils.h"
#import "DeviceVersionUtils.h"
#import "FileUtils.h"
#import "CheckmeInfo.h"
#import "NSDate+Additional.h"
#import "BTCommunication.h"
#import "UserItem.h"

#import "MobClick.h"

#import "HKUpdateUtils.h"

//********************************************
#import <CoreBluetooth/CoreBluetooth.h>
//********************************************

@interface RootViewController () <BTCommunicationDelegate,CBPeripheralManagerDelegate>/////

@property (nonatomic,retain) NSMutableArray *arrFindPeripheral;
@property (nonatomic,retain) NSTimer *scanTimer;
@property (nonatomic,retain) NSTimer *updateTimer;
@property (nonatomic,retain)  UIActionSheet *peripheralChooseSheet;
@property (nonatomic) BOOL isSpcMode;
@property (nonatomic, copy) NSString *MeasureMode;

@property (nonatomic, strong) User *curHKUser;


//**************************************************
@property (nonatomic,strong) CBPeripheralManager *manager;
//**************************************************

@end

static int a = 0;//没事干定义的一个静态变量

@implementation RootViewController
{
    NSString* lastCheckmeName;
    UIImageView *yindaoimage;//引导图
    UIButton *starimagge;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"BasePage"];
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"BasePage"];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization   （自定义初始化...）
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMMDrawer];
    [self initLogo];  //初始化 Logo图标
    [self checkDeviceVersion];  //先判断设备版本
    
//    if ([self checkDeviceVersion]) { //如果版本符合
//        [self start];//开始扫描
//    }
//    else{
//        [self showLowDeviceVersionAlert];//版本过低警告
//    }
    

/** 这个处理 start 开始扫描是重复的操作会引起后面 update 更新后的*/
//    if (a!=0) {
//        DBG(@"************-------------********viewDidLoad*********----------------*************%d",a);
//        if ([self checkDeviceVersion]) { //如果版本符合
//            [self start];//开始扫描
//        }
//        else{
//            [self showLowDeviceVersionAlert];//版本过低警告
//        }
//    }
//

   // [self addTankuang];  这样直接添加是不行的   (见下面的方法处理)  添加创建弹框的方法
    [self performSelector:@selector(addBounced) withObject:nil afterDelay:1.0f];//使用延时方法来处理  添加方法事件
    
    //*************************************************
   // self.manager=[[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    //*************************************************
    
   
}
//6.实现代理方法：
//检测手机端的蓝牙是否开启了
/*
 //HB 的想法  ---  当用户启动App时,如果当前用户的iphone手机已经开启了蓝牙功能,则直接进入到硬件设备的蓝牙列表(BM-88蓝牙设备)  如果用户没有开启蓝牙时,启动App 就到当初的那个弹框(一个是查看离线数据 一个是搜索扫描的),点击搜索扫描才开始提示用户说当前用户的手机没有开启蓝牙,请在设置中打开或者是点击好来打开   -------  这种貌似是做不吧？？？
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    switch (peripheral.state) {
            
        case CBPeripheralManagerStatePoweredOn:
            
        {
            
            NSLog(@"蓝牙开启且可用");
            if ([self checkDeviceVersion]) { //如果版本符合
                [self start];//开始扫描
            }
            else{
                [self showLowDeviceVersionAlert];//版本过低警告
            }
            
        }
            
            break;
            
        default:
            
            NSLog(@"蓝牙不可用");
            //显示 一个 弹框(查看离线数据 -- View Offline data  和  一个 搜索扫描 -- Search device)
            [self performSelector:@selector(addBounced) withObject:nil afterDelay:1.0f];
            
            break;
            
    }
    
}
 //一开始如果启用这个检测手机蓝牙是否开启的功能的话,只有两种情况发生。一种是一开始手机蓝牙就已经打开了,直接扫描外围蓝牙设备。一种是手机蓝牙一开始就没有打开,系统就会立马自动弹出一个弹框来,提示你去设置中将蓝牙打开,这个时候将不能做任何操作的
*/

#warning 加上一个弹框提示...做个查看离线数据的处理事件  hjz
-(void)addBounced {
    
    a++;
    DBG(@"************-------------********addTankuang*********----------------*************%d",a);
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:DTLocalizedString(@"Please select", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];//title 标题  ---- 请选择  (UIAlertControllerStyleAlert 弹框样式)DTLocalizedString(@"Please select a", nil)
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //查看离线数据
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:DTLocalizedString(@"View Offline data", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {// 查看离线数据 DTLocalizedString(@"See the offline data", nil)
        
        DBG(@"点击了查看离线数据按钮");
#warning 离线数据的查看
        [AppDelegate GetAppDelegate].isOffline = YES;    //离线状态
        //加载本地数据   包括DLC和SPC数据
        [self loadNativeUserList]; //调用离线模式下  处理离线数据的方法
        
    }];
    
    //搜索扫描设备
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:DTLocalizedString(@"Search device", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {//搜索扫描  DTLocalizedString(@"Search device", nil)
        
        DBG(@"点击了搜索扫描按钮");
                if ([self checkDeviceVersion]) { //如果版本符合
                    [self start];//开始扫描
                }
                else{
                    [self showLowDeviceVersionAlert];//版本过低警告
                }
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:yesAction];
    
//    [[AppDelegate GetAppDelegate].window.rootViewController presentViewController:alert animated:YES completion:nil];//这句相当于使用UIAlertView  的  show  显示一样  [alertView show];
    //获取当前控制器的window窗口来加载  显示  alertView 弹框
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - MMDrawer viewController
- (void)initMMDrawer
{
    self.mmDrawer = [[MMDrawerController alloc]init];
    
    self.mmDrawer.centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    self.mmDrawer.leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
    self.mmDrawer.rightDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightMenuViewController"];
    /**  设置左边那个抽屉的宽度   (为屏幕宽度的0.8)*/
    self.mmDrawer.maximumLeftDrawerWidth = CUR_SCREEN_W*0.8;
    /**  设置右边那个抽屉的宽度  (是屏幕宽度的0.65)*/
    self.mmDrawer.maximumRightDrawerWidth = CUR_SCREEN_W*0.65;
    
//    self.mmDrawer.openDrawerGestureModeMask = MMOpenDrawerGestureModePanningCenterView;
#warning 关闭手势抽屉模式
    self.mmDrawer.closeDrawerGestureModeMask = MMCloseDrawerGestureModePanningCenterView;  //关闭手势抽屉模式

#warning 设置抽屉 的样式(有五个样式,貌似样式都一样的呀....没啥区别,暂时没有看出有什么不一样的效果)
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeSlideAndScale];//MMDrawerAnimationTypeSlideAndScale
    [[MMExampleDrawerVisualStateManager sharedManager] setRightDrawerAnimationType:MMDrawerAnimationTypeSlideAndScale];
    
    [self.mmDrawer
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
}


- (void) start
{
    
    [self startScan];//开始扫描
    [self addNotificationObserver];
}

//开始扫描
-(void)startScan
{
    [[BTUtils GetInstance] openBT];
}
//通知订阅
-(void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLPowerOnNtf:) name:NtfName_BTPowerOn object:nil]; //连接上
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLPowerOffNtf:) name:NtfName_BTPowerOff object:nil];  //断开
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFindPeripheralNtf:) name:NtfName_FindAPeripheral object:nil];  //找到外设
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectCheckmeSuccessNtf) name:NtfName_ConnectPeriphralSuccess object:nil];  //在连接 Checkme 成功 的情况下
    [BTCommunication sharedInstance].delegate = self;
    
}

//内存警告处理(当内存吃紧时会调用这个警告处理的方法)
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//初始化logo
-(void)initLogo
{
    
    CGRect logoFrame = _imgLogo.frame;
    logoFrame.origin.x = (CUR_SCREEN_W - logoFrame.size.width)*0.5;
    _imgLogo.frame = logoFrame;
    _imgLogo.image = [UIImage imageNamed:@"BM logo 1.jpg"];
    
//    if ([curCountry isEqualToString:@"JP"] && [curLanguage isEqualToString:@"ja"]) {   //如果是日本的
//        _imgLogo.image = [UIImage imageNamed:@"BM logo 1.jpg"];
//    }
////    if (isThomson == YES) {  //如果是法国定制版
//        _imgLogo.image = [UIImage imageNamed:@"BM logo 1.jpg"];
//    }
//    if (isSemacare == YES) {
//        _imgLogo.image = [UIImage imageNamed:@"BM logo 1.jpg"];
//    }
    
    [UIView animateWithDuration:1.5 animations:^{
		_imgLogo.alpha = 1.0;//alpha的值设置为 1.0 的时候表示不透明 当值为0.0 的时候表示全透明
	}];
   
}

//检查手机型号，低于ip4不可运行
-(BOOL)checkDeviceVersion
{
    NSString *version = [DeviceVersionUtils platformString]; //手机机型判定
    if ([version hasPrefix:@"iPhone 4 "] || [version hasPrefix:@"iPhone 3"] || [version hasPrefix:@"iPhone 1"]) { //判断 以...开头的手机设备
        DLog(@"iphone太旧，无法支持");
        return NO;
    }else{
        return YES;
    }
}

//版本过低警告
-(void)showLowDeviceVersionAlert{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil) andMessage:DTLocalizedString(@"Can only be used for iphone4s or later", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Exit", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              exit(0);//版本过低就直接退出？？
                          }];
    [alertView show];
}

//移除全部观察者
-(void)removeAllObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除所有的观察者对象
}

#warning  当蓝牙开启时,进入到该方法
//中心设备蓝牙开启时    进入对应通知中心的回调函数
-(void)onBLPowerOnNtf:(NSNotification *)ntf
{
    _arrFindPeripheral = [NSMutableArray array];        
    //开始扫描外设
    [[BTUtils GetInstance] beginScan];
    
    //  开启了蓝牙后开始扫描    每0.8秒执行一次timeUp方法  （使用定时器来不断实现扫描操作）
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(timeUp) userInfo:nil repeats:NO];
}

//预期扫描时长达到后显示设备框
- (void)timeUp
{
    [SVProgressHUD showWithStatus:DTLocalizedString(@"Searching...", nil)];//搜索设备中...正在搜索
    
    [self.peripheralChooseSheet showFromRect:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height) inView:self.view animated:NO];
}

//创建设备选择列表
- (UIActionSheet *)peripheralChooseSheet
{
    if (!_peripheralChooseSheet) {   //如果Sheet不存在
        if ([_arrFindPeripheral count]==0) {
            _peripheralChooseSheet = [[UIActionSheet alloc] initWithTitle:DTLocalizedString(@"Please turn on the Bluetooth of your VIATOM device, or enter Offline mode", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        }else{  //如果找到了外设     _peripheralChooseSheet将被创建
            _peripheralChooseSheet = [[UIActionSheet alloc] initWithTitle:DTLocalizedString(@"Choose a device", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        }

        //离线数据查看....
        [_peripheralChooseSheet addButtonWithTitle:DTLocalizedString(@"View Offline data", nil)];
        _peripheralChooseSheet.backgroundColor = [UIColor redColor];
    }
    
    return _peripheralChooseSheet;
}

#warning 当蓝牙未开启时进入到该方法中(设想,可以用弹框来做个查看离线数据操作..但是,不是在这里进行查看的。。如果在这里进行处理的话会先有那个让你进入设置中打开蓝牙的操作)
//中心设备蓝牙关闭 或未打开时   进入对应通知中心的回调函数
//这里这个方法写的有必要吗？？都没有对应的方法实现  只有一个空洞洞的方法名在这里(在扫描外设的过程中,当检测到主设没有开启蓝牙时,就会来到这个方法中)

//当前手机开启了蓝牙功能
//当前手机未开启蓝牙功能
//这个通知会一直提示你 (不管你当前的手机是否开启了蓝牙,这个通知方法都会走)
-(void)onBLPowerOffNtf:(NSNotification *)ntf
{
    DBG(@"在你的iphone手机蓝牙未开启时,出现的一个提示 ------- > 请开启蓝牙.......打开蓝牙");//这个是在你的iphone手机没有开启蓝牙时触发的一个方法
   
}

static NSString *stringName = @"BM-88";
#warning 指定连接 BM-88 蓝牙设备
//连接外设的通知实现的方法
-(void)onFindPeripheralNtf:(NSNotification *)ntf
{
//    NSDictionary *usrInfo  = [ntf userInfo];
//    
//    CBPeripheral *periphral = [usrInfo objectForKey:Key_FindAPeripheral_Content];//发现外设,调用通知  Key_FindAPeripheral_Content   //用这个测试看看 NtfName_FindAPeripheral
//    //if ([[periphral name]hasPrefix:@"BM-88"])
//    //if ([periphral.name hasSuffix:@"BM-88"]){
//    if ([[periphral name]hasPrefix:stringName]) {//只搜索这个设备的蓝牙  （公司的两种外设设备名 ---- Checkme、BM-88）
//        //hasPrefix   判断开头   以........开头
//        //hasSuffix   判断结尾   以........结尾
//    
//        [self addPeripheralForChoice:periphral];//过滤掉之前一样的外设名字
//    NSLog(@"0000000000000000------------当前搜索到设备:%@",periphral.name);
//    };
    
    //14839ac4-7d7e-415c-9a42-167340cf2339
    
#warning 解决了当前有些设备扫描不到的情况(之前有这种情况,就是之前的外设名为CheckmeXX的外设被一些连接过它的手机设备记录了,然后现在将CheckmeXX 设备改名了,然后现在就搜索不出来了....现在这样的操作就是将以前外设名改名后不能被搜索到的设备重新赋予现在的新设备名称即可被搜索到)
    NSDictionary *usrInfo  = [ntf userInfo];
    
    CBPeripheral *periphral = [usrInfo objectForKey:Key_FindAPeripheral_Content];  //寻找外设内容
    NSString *BLEname =  usrInfo[@"BLEName"];
    DBG(@"-------periphral.name = %@   -----BLEname = %@",periphral.name,BLEname);//查看当前扫描到的设备的设备名(如果有设备改名后,查看改名前与改名后的设备名进行对比)
    if(BLEname && ![BLEname isKindOfClass:[NSNull class]]&& ![BLEname isEqualToString:@""] && ![periphral.name isEqualToString:BLEname])
    {
        [periphral setValue:BLEname forKey:@"name"];//将搜索到以前的设备名替换成现在的
    }
    if ([[periphral name]hasPrefix:stringName]) {
        [self addPeripheralForChoice:periphral];//过滤掉之前一样的外设名字
    };
    
}

-(void)addPeripheralForChoice:(CBPeripheral *)periphral
{
    if (periphral && ![_arrFindPeripheral containsObject:periphral]) {  //滤除之前名字一样的外设名字      containsObject（判断是否存在一样的对象）
        [_arrFindPeripheral addObject:periphral];//将外设加入到数组中去
    }
    
    if(_peripheralChooseSheet){
        [_peripheralChooseSheet dismissWithClickedButtonIndex:0xffffffff animated:NO]; //0xffffffff 转换 成二进制的数 （貌似等于 -1 ??需要证实哦）
        self.peripheralChooseSheet = nil;
    }
    
    if(self.peripheralChooseSheet)
    {
        for(CBPeripheral *p in _arrFindPeripheral)
        {
            [self.peripheralChooseSheet addButtonWithTitle:p.name];
        }
//        [self.peripheralChooseSheet showFromRect:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height) inView:self.view animated:NO];
//        [self.peripheralChooseSheet showInView:self.view];
        [self.peripheralChooseSheet showFromRect:rect(0, CUR_SCREEN_H, CUR_SCREEN_W, 0) inView:self.view animated:YES];

    }
    
}
//结束扫描
-(void)stopScan
{
    [[BTUtils GetInstance] stopScan];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NtfName_FindAPeripheral object:nil];
    [self.scanTimer invalidate]; //将定时器关闭(无效的 -- 扫描完毕就无效了)
    self.scanTimer = nil;
    [_updateTimer invalidate];
}


#warning 存储蓝牙设备
#pragma mark - UIActionSheetDelegate
//选择设备列表某item后处理函数
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [SVProgressHUD dismiss];
    [self stopScan];//结束扫描
    
    if(buttonIndex > 0)   //如果搜索到了外设的蓝牙列表
    {
        [SVProgressHUD showWithStatus:DTLocalizedString(@"Loading...", nil)];
        //点击某个item 对应连接到相应periphral
        CBPeripheral *periphral = _arrFindPeripheral[buttonIndex-1]; //扫描到的外设。。点击某个扫描到的外设进行的相应的处理操作
        [[BTUtils GetInstance] connectToPeripheral:periphral];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#warning 原来的写法
        //NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]; 保存在 document路径下  hjz
//        if (lastCheckmeName == nil) {//第一次连接checkme设备时
//            [userDefaults setObject:periphral.name forKey:@"LastCheckmeName"];
//            // 在document文件夹下创建存储本checkme数据的文件夹
//            [FileUtils createDirectoryInDocumentsWithName:periphral.name];
//            
//        }else if (![lastCheckmeName isEqualToString:[periphral name]]) {//如果连接的checkme设备不同于上次的checkme设备
//            //存储新name
//            [userDefaults setObject:[periphral name] forKey:@"LastCheckmeName"];
//            [userDefaults setInteger:0 forKey:@"LastUser"];
//            
//            // 在document文件夹下创建存储本checkme数据的文件夹
//            [FileUtils createDirectoryInDocumentsWithName:periphral.name];
//        }
//        lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
//        [userDefaults setObject:lastCheckmeName forKey:@"OfflineDirName"];
//    }
        
#warning 自己的写法。。。。。。
        if (lastCheckmeName == nil || ![lastCheckmeName isEqualToString:[periphral name]]) {//第一次连接checkme\BM-88设备时
            [userDefaults setObject:periphral.name forKey:@"LastCheckmeName"];
            // 在document文件夹下创建存储本地checkme数据的文件夹
            [FileUtils createDirectoryInDocumentsWithName:periphral.name];
            
        }
        lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
        [userDefaults setObject:lastCheckmeName forKey:@"OfflineDirName"];
    }
        
    else if(buttonIndex == 0) {  // offline    如果没有外设蓝牙列表    （如果没有搜索到任何外设就读取离线数据信息进行显示）
        
        [AppDelegate GetAppDelegate].isOffline = YES;    //离线状态
        //加载本地数据   包括DLC和SPC数据
        [self loadNativeUserList];
      }
}


//打开本地用户列表，离线模式下调用
-(void)loadNativeUserList
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //新改动
    NSString *lastCKname = nil;
    if ([ud objectForKey:@"OfflineDirName"]) {  //如果存在
        lastCKname = [ud objectForKey:@"OfflineDirName"];
    } else { //如果不存在
        lastCKname = [ud objectForKey:@"LastCheckmeName"];
        if (!lastCKname) {
            //第一次连接checkme设备时 如果没有数据 就自己手动创建一个文件夹
            [ud setObject:@" " forKey:@"LastCheckmeName"];
            // 在document文件夹下创建存储本checkme数据的文件夹
            [FileUtils createDirectoryInDocumentsWithName:@" "];
            lastCheckmeName = [ud objectForKey:@"LastCheckmeName"];
            [ud setObject:lastCheckmeName forKey:@"OfflineDirName"];
            lastCKname = [ud objectForKey:@"LastCheckmeName"];
            
//            [self showNoDataAlertView];
//            return;
        }
    }
    NSString *measureMode = [ud objectForKey:lastCKname];

    if ([measureMode isEqualToString:@"mode_home"]) {
        _isSpcMode = NO;
    }
    else if ([measureMode isEqualToString:@"mode_hospital"]) {
        _isSpcMode = YES;
    }
    //Xusr.dat    usr.dat  判断获取的是哪个文件
    
    NSString *fileName = _isSpcMode ? Hospital_Home_USER_LIST_FILE_NAME : Home_USER_LIST_FILE_NAME;
    //旧版本的user.dat
    NSString *oldfileName = @"usr.dat";

    // 读取document文件下 后缀为 xusr.dat/ user.dat 的文件
    //从本地拿数据UserList
    NSArray *userListArr;

    if ([FileUtils isFileExist:oldfileName inDirectory:lastCKname]) {
    
        NSData *data =  [FileUtils readFile:oldfileName inDirectory:lastCKname];
        NSArray *olduserListArr = [self parseOldUserList_WithFileData:data];
        
        if (olduserListArr.count != 0) { //本地有数据
            
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < olduserListArr.count; i++) {
                    
                    User *user  = olduserListArr[i];
                    UserItem *userItem = [[UserItem alloc] init];
                    userItem.ID = user.ID;
                    userItem.ICO_ID = user.ICO_ID;
                    userItem.dtcBirthday = user.dtcBirthday;
                    userItem.headIcon = user.headIcon;
                    userItem.weight = user.weight;
                    userItem.height = user.height;
                    userItem.name = user.name;
                    userItem.age = user.age;
                    userItem.gender = user.gender;
                    userItem.medical_id = [NSString stringWithFormat:@"%@%d",lastCKname,user.ID];
                    [array addObject:userItem];
                    
                }
                
//                [[UserList instance].arrUserList setArray:array];
//                [UserList instance].isSpotCheck = NO;
            
            [self saveUserList:array withDirectoryName:lastCKname];
//            [FileUtils deleteFile:@"usr.dat" inDirectory:lastCKname];
            //[self presentViewController:self.mmDrawer animated:YES completion:nil];
        //跳转到dailyCheckViewController
            
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSLog(@"documentsDirectory%@",documentsDirectory);
            NSFileManager *fileManage = [NSFileManager defaultManager];
            NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:lastCKname];
            NSDirectoryEnumerator *enumerator = [fileManage enumeratorAtPath:myDirectory];
            for (NSString *fileName in enumerator)
            {
                NSLog(@"%@",fileName);
                if ([fileName isEqualToString:@"*usr.dat"] || [fileName isEqualToString:@"usr.dat"]) {
                    
                }else{
                    
                    if([fileName rangeOfString:@"*"].location ==NSNotFound)//_roaldSearchText
                    {
                        
                        if([fileName rangeOfString:@"ECG"].location !=NSNotFound || [fileName rangeOfString:@"SPO2"].location !=NSNotFound || [fileName rangeOfString:@"TEMP"].location !=NSNotFound){
                            
                            NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",lastCKname,fileName]];
                            NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@1%@*",lastCKname,lastCKname,fileName]];
                            [fileManage moveItemAtPath:old toPath:new error:nil];
                            [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@1%@*",lastCKname,fileName]];
                            [UserDefaults synchronize];
                            
                        }else{
                        
                        
                        NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",lastCKname,fileName]];
                        NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@*",lastCKname,lastCKname,fileName]];
                        [fileManage moveItemAtPath:old toPath:new error:nil];
                        [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@%@*",lastCKname,fileName]];
                        [UserDefaults synchronize];
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
        
        
    
        //  读取本地文件
        if ([FileUtils isFileExist:fileName inDirectory:lastCKname]) {
            
            NSData *dlcListData = [FileUtils readFile:fileName inDirectory:lastCKname];
            NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
            userListArr = [unArch decodeObjectForKey:fileName];
        }
        
        [ud setObject:lastCKname forKey:@"OfflineDirName"];
        
        if (userListArr.count != 0) { //本地有数据
            if (_isSpcMode) {
                //            NSArray *list = [FileParser paserXusrList_WithFileData:data];
                //            [[UserList instance].arrXuserList setArray:list];
                //            [UserList instance].isSpotCheck = YES;
            } else {
                
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < userListArr.count; i++) {
                    
                    UserItem *userItem = userListArr[i];
                    User *user = [[User alloc] init];
                    user.ID = userItem.ID;
                    user.ICO_ID = userItem.ICO_ID;
                    user.dtcBirthday = userItem.dtcBirthday;
                    user.headIcon = userItem.headIcon;
                    user.weight = userItem.weight;
                    user.height = userItem.height;
                    user.name = userItem.name;
                    user.age = userItem.age;
                    user.gender = userItem.gender;
                    user.medical_id = userItem.medical_id;
                    [array addObject:user];
                    
                }
                
                
                [[UserList instance].arrUserList setArray:array];
                [UserList instance].isSpotCheck = NO;
            }
            //        [self presentViewController:self.mmDrawer animated:YES completion:nil];    //跳转到dailyCheckViewController
            [self addyingdaoImagaView];
        } else{ //本地无数据
            User *aUser = [[User alloc] init];
            aUser.ID = 1 ;
            aUser.name = @"Guest" ;  //[NSString stringWithCString:(char *)(p+1) length:16];
            aUser.ICO_ID = 1;
            aUser.gender = kGender_FeMale;
            NSMutableArray *list = [NSMutableArray new];
            [list addObject:aUser];
            [[UserList instance].arrUserList setArray:list];
            [UserList instance].isSpotCheck = NO;
            //        [self presentViewController:self.mmDrawer animated:YES completion:nil];
            [self addyingdaoImagaView];
            //        [self showNoDataAlertView];
        }
 
    
    
   
}


#pragma mark -------旧版本解析userList
- (NSArray *)parseOldUserList_WithFileData:(NSData *)data
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = data.length;   // 27*i
    
    for(int left = dataLen; left >= 27; left -= 27){  //一个用户占27个字节
        unsigned char *p = bytes + dataLen - left;
        
        User *aUser = [[User alloc] init];
        aUser.ID = p[0];
        
        char nameBuff[17] = {0x00};
        int i = 0 ;
        for(i=0;((char *)(p+1))[i] != '\0' && i < 16; ++i)
        {
            nameBuff[i] = ((char *)(p+1))[i];
        }
        nameBuff[i] = '\0';
        aUser.name = [NSString stringWithUTF8String:nameBuff];  //[NSString stringWithCString:(char *)(p+1) length:16];
        aUser.ICO_ID = p[17];
        aUser.gender = (p[18] == 0 ? kGender_FeMale:kGender_Male);
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[19], dtc.year);
        dtc.month = p[21];
        dtc.day = p[22];
        aUser.dtcBirthday = dtc;
        
        U16 w = 0,h=0;
        P2U16(&p[23], w);
        P2U16(&p[25], h);
        aUser.weight = (double)w / 10;
        aUser.height = (double)h;
        
        [arr addObject:aUser];
    }
    DLog(@"  解析完毕！！！");
    return arr;

}



#pragma mark - 没有数据 点击 exit 直接退出应用程序
//没有数据且没有连接到蓝牙
- (void)showNoDataAlertView
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"No records found", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Exit", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              exit(0);  //退出应用
                          }];
    [alertView show];
}

//连接成功后执行ping操作
//不返回信息则认为是旧版Checkme
#warning 不返回信息则认为是旧版Checkme
-(void)onConnectCheckmeSuccessNtf
{
    [[BTCommunication sharedInstance] BeginPing];
}

#pragma mark - BTCommunication delegate
//获取设备信息相关
- (void)pingSuccess
{
    [[BTCommunication sharedInstance] BeginGetInfo];   //get Checkme info
}

//设备版本过低
- (void)pingFailed
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil) andMessage:DTLocalizedString(@"Please update your Checkme", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Exit", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              exit(0);
                          }];
    [alertView show];
}

#pragma mark - BTCommunication delegate
- (void) getInfoSuccessWithData:(NSData *)data
{
    CheckmeInfo *checkmeInfo = [[CheckmeInfo alloc] initWithJSONStr:data];
    NSString *fileVer = checkmeInfo.FileVer;
    NSString *spcpver = checkmeInfo.SPCPVer;
    self.MeasureMode = checkmeInfo.Application;
    
    NSString *sn = checkmeInfo.sn;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:sn forKey:@"SN"];
    [ud setObject:sn forKey:[NSString stringWithFormat:@"#%@",lastCheckmeName]];
    [ud setObject:fileVer forKey:@"fileVer"];
    [ud synchronize];
    
    if ([fileVer isEqualToString:@"1.0"] && [spcpver isEqualToString:@"1.0"]) {
       
        
        //if the version is right
        
        [[BTCommunication sharedInstance] upDataTime];
       
        

    } else {
        //otherwise
//        [self pingFailed];
        
        if(fileVer == nil){
            
        
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Update firmware of monitor:" andMessage:@"1、Go to www.bodimetrics.com\n2、Download，update firmware"];
            alertView.titleFont = [UIFont boldSystemFontOfSize:14];
            alertView.messageFont = [UIFont systemFontOfSize:14];
            [alertView addButtonWithTitle:DTLocalizedString(@"Exit", nil)
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                      // 点击取消 什么都不做
                                      exit(0);
                                  }];
            [alertView show];
            
        }else{
        
            [self addyingdaoImagaView];

        }

    }
}
- (void)getInfoFailed
{
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Get Checkme information failed", nil) duration:2];
}

//更新时间失败
- (void)updataTimeFailed
{
    [self loadUserList];
}

//更新时间成功
- (void)updataTimeSuccess
{
    [self loadUserList];
}

//添加引导图
- (void)addyingdaoImagaView
{
    //判断是不是第一次启动应用
    if([UserDefaults boolForKey:@"firstLaunch"])
    {
        DBG(@"不是第一次启动");
        // 跳转到dlc
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];//隐藏提示的那个提示性文字
        });
        [self presentViewController:self.mmDrawer animated:NO completion:nil];//添加引导图
        
    } else {
        
        [SVProgressHUD dismiss];//隐藏提示的那个提示性文字
        yindaoimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        yindaoimage.contentMode = UIViewContentModeScaleToFill;
        yindaoimage.image = [UIImage imageNamed:@"app guidence(2).png"];
        yindaoimage.userInteractionEnabled = YES;
        [self.view addSubview:yindaoimage];
        
        starimagge = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2.0, kScreenHeight - 75 - 100, 150, 75)];
        [starimagge setImage:[UIImage imageNamed:@"guide_start(1).png"] forState:UIControlStateNormal];
        //starimagge.image = [UIImage imageNamed:@"guide_start(1).png"];
        [starimagge addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        starimagge.userInteractionEnabled = YES;
        [self.view addSubview:starimagge];
        
        //            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        //            [starimagge addGestureRecognizer:tap];
    }


}

//引导图点击事件
- (void)tapAction
{
    
    [yindaoimage removeFromSuperview];
    [starimagge removeFromSuperview];
    [UserDefaults setBool:YES forKey:@"firstLaunch"];
    [UserDefaults synchronize];
    // 跳转到dlc
    [self presentViewController:self.mmDrawer animated:YES completion:nil];
}


//加载用户列表
-(void)loadUserList
{
    [AppDelegate GetAppDelegate].isOffline = NO;
    
    if ([_MeasureMode isEqualToString:@"MODE_HOSPITAL"]) {
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:Hospital_Home_USER_LIST_FILE_NAME fileType:FILE_Type_xuserList];
    } else if ([_MeasureMode isEqualToString:@"MODE_HOME"]) {
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:@"usr.dat" fileType:FILE_Type_UserList];
    } else if ([_MeasureMode isEqualToString:@"MODE_MULTI"]) {
        
    } else if (_MeasureMode == nil) {   //为空 则加载user.dat 兼容以前版本
        [[BTCommunication sharedInstance] BeginReadFileWithFileName:Home_USER_LIST_FILE_NAME fileType:FILE_Type_UserList];
    }
}

- (void) saveDataToHealthKitWithHKUserName:(NSString *)hkUserName
{
    //******************************   hjz   *******************************//
    NSArray *userArr = [UserList instance].arrUserList;
    for (User *user in userArr) {
        NSString *userName = user.name;
        if ([hkUserName isEqualToString:userName]) {
            _curHKUser = user;
            [[HKUpdateUtils sharedInstance] saveUserInfoToHealthKitWithCurUser:user];
            if(![[BTCommunication sharedInstance] bLoadingFileNow]){    //如果没有在下载别的数据
                [BTCommunication sharedInstance].delegate = self;
                NSString *fileName = [NSString stringWithFormat:DLC_LIST_FILE_NAME,user.ID];
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_DailyCheckList];
            }
        }
    }
    
    //*****************************   hjz   ********************************//
}

#pragma mark - BTCommunication delegate
- (void)postCurrentReadProgress:(double)progress{
    return;
}
- (void)readCompleteWithData:(FileToRead *)fileData
{
    [self removeAllObserver];//移除全部观察器
    [BTCommunication sharedInstance].delegate = nil;
    [SVProgressHUD dismiss];
    FileToRead *file = fileData;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (file.fileType == FILE_Type_xuserList) {    //  是xusr.dat数据
        if(file.enLoadResult != kFileLoadResult_NotExist)
        {
            if(file.enLoadResult != kFileLoadResult_TimeOut)
            {
                [ud setObject:@"mode_hospital" forKey:lastCheckmeName];
                
                NSArray *newList = [FileParser paserXusrList_WithFileData:file.fileData];
                
                [[UserList instance].arrXuserList setArray:newList];
                [UserList instance].isSpotCheck = YES;
                
                //删除处理本地SPC数据
                [self removeSPCUnuseXuserWithNewList:newList];
                //存储到本地 xusr.dat
                [FileUtils saveFile:Hospital_Home_USER_LIST_FILE_NAME FileData:file.fileData withDirectoryName:lastCheckmeName];
                //  跳转
//                [self presentViewController:self.mmDrawer animated:YES completion:nil];
                [self addyingdaoImagaView];
                
            }else {
                [PublicMethods msgBoxWithMessage:[file loadStateDesc]];
            }
        }else {
            [PublicMethods msgBoxWithMessage:[file loadStateDesc]];
        }

    } else if (file.fileType == FILE_Type_UserList) {
        
        if(file.enLoadResult != kFileLoadResult_NotExist)
        {
            if(file.enLoadResult != kFileLoadResult_TimeOut)
            {
                
                [ud setObject:@"mode_home" forKey:lastCheckmeName];
                NSArray *newList = [FileParser parseUserList_WithFileData:file.fileData];
//              NSArray *newList;
                NSLog(@"%@",file.fileData);
                [[UserList instance].arrUserList setArray:newList];
                [UserList instance].isSpotCheck = NO;
                
                NSMutableArray *usersItems = [NSMutableArray array];
                for(int i = 0 ;i < newList.count;i++){
                
                    UserItem *userItem = [[UserItem alloc] init];
                    User *user = newList[i];
                    userItem.ID = user.ID;
                    userItem.ICO_ID = user.ICO_ID;
                    userItem.dtcBirthday = user.dtcBirthday;
                    userItem.headIcon = user.headIcon;
                    userItem.weight = user.weight;
                    userItem.height = user.height;
                    userItem.name = user.name;
                    userItem.age = user.age;
                    userItem.gender = user.gender;
                    userItem.ID = user.ID;
                    userItem.medical_id = user.medical_id;
                    [usersItems addObject:userItem];
                
                }
                
                //删除处理本地DLC数据 即Checkme端已经删除的用户，手机本地也对应删除其数据
                [self removeDLCUnuseUserWithNewList:newList];
                
                //存储到本地 usr.dat
//                [FileUtils saveFile:Home_USER_LIST_FILE_NAME FileData:file.fileData withDirectoryName:lastCheckmeName];
                
                //保存数据至HK
                NSString *hkUserName = [ud objectForKey:@"HKUserName"];
                NSMutableArray *nameArr = [NSMutableArray array];
                for (User *user in [UserList instance].arrUserList) {
                    [nameArr addObject:user.name];
                }
                
                if (hkUserName && [nameArr containsObject:hkUserName]) {
                    [self saveDataToHealthKitWithHKUserName:hkUserName];
                }else {
                    
                    // 跳转到dlc
//                    [self presentViewController:self.mmDrawer animated:YES completion:nil];
                    [self addyingdaoImagaView];
                }
                
            }else {
                
                [self showNoDataAlertView];
                
            }
        }
    }
    
    ///////////
    else if(fileData.fileType == FILE_Type_DailyCheckList) {    //  保存数据到HK
        if(fileData.enLoadResult == kFileLoadResult_TimeOut){
            //  timeOut
            //请求Pedometer处的数据
            if (![[BTCommunication sharedInstance] bLoadingFileNow]) {
                [BTCommunication sharedInstance].delegate = self;
                NSString *fileName = [NSString stringWithFormat:PED_FILE_NAME,_curHKUser.ID];
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_PedList];
            }
        }else {
            //***************************    hjz  **********************************//
            
             //解析
            NSArray *arr = [FileParser parseDlcList_WithFileData:fileData.fileData];
            for (DailyCheckItem *dlcItem in arr) {
                //保存 HR、SpO2、BP数据到HealthKit
                [[HKUpdateUtils sharedInstance] saveHR_SpO2_BPToHealthKitWithDLCItem:dlcItem andUser:_curHKUser];
            }
            
            //***************************  hjz **********************************//
            //再请求Pedometer处的数据
            if (![[BTCommunication sharedInstance] bLoadingFileNow]) {
                [BTCommunication sharedInstance].delegate = self;
                NSString* fileName = [NSString stringWithFormat:PED_FILE_NAME,_curHKUser.ID];
                [[BTCommunication sharedInstance] BeginReadFileWithFileName:fileName fileType:FILE_Type_PedList];
            }
            
        }
    } else if (fileData.fileType == FILE_Type_PedList) {
        if (fileData.enLoadResult == kFileLoadResult_TimeOut) {
            //timeOut
            
        } else {
            //**************************  hjz ***********************************//
            //解析
            NSArray *arr = [FileParser parsePedList_WithFileData:fileData.fileData];
            for (PedInfoItem *pedItem in arr) {
                // 保存计步相关的数据到HealthKit
                [[HKUpdateUtils sharedInstance] savePedDataToHealthKitWithPedItem:pedItem andUser:_curHKUser];
            }
            
            //*************************  hjz ************************************//
        }
        
        // 跳转到dlc
//        [self presentViewController:self.mmDrawer animated:YES completion:nil];
        [self addyingdaoImagaView];
        
    } else {
        //   都不是
        [self pingFailed];
    }
}

//删除处理SPC本地数据
- (void) removeSPCUnuseXuserWithNewList:(NSArray *)newList
{
    //每个user的 ID 和名字都是唯一对应的，如果不对应则主机肯定删除了这个用户   此时应删除之前对应ID下载过的所有数据 （删除本地以ID号为前缀命名的所有数据）
    NSData *oldXuserData = [FileUtils readFile:Hospital_Home_USER_LIST_FILE_NAME inDirectory:lastCheckmeName];
    if (oldXuserData) {   //如果本地存储过xusr.dat数据
        NSArray *oldList = [FileParser paserXusrList_WithFileData:oldXuserData];
        for (Xuser *newXuser in newList) {
            for (Xuser *oldXuser in oldList) {
                if (newXuser.userID == oldXuser.userID) {

                    if (![newXuser.name isEqualToString:oldXuser.name] || newXuser.sex != oldXuser.sex || ![newXuser.patient_ID isEqualToString:oldXuser.patient_ID]) {
                        //删除数据
                        //SPC数据
                        NSArray *spc_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%d_SPC", oldXuser.userID] inDirectory:lastCheckmeName];
                        for (NSString *fileName in spc_data_arr) {
                            [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
                        }
                        
                    }
                }
            }
        }
        
        //如果新数组中找不到旧数组中user对应的ID号 则删除这个ID对应的本地数据
        NSMutableArray *newUserID = [NSMutableArray array];
        for (Xuser *newUser in newList) {
            [newUserID addObject:[NSString stringWithFormat:@"%d",newUser.userID]];
        }
        
        NSMutableArray *oldUserID = [NSMutableArray array];
        for (Xuser *oldUser in oldList) {
            [oldUserID addObject:[NSString stringWithFormat:@"%d",oldUser.userID]];
        }
        [oldUserID removeObjectsInArray:newUserID];
        
        for (NSString *ID in oldUserID) {
            //删除数据
            //SPC数据
            NSArray *spc_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_SPC", ID] inDirectory:lastCheckmeName];
            for (NSString *fileName in spc_data_arr) {
                [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
            }
        }
        
    }
}

- (void)saveUserList:(NSArray *)users withDirectoryName:(NSString *)dirname
{
    NSString *fileName = Home_USER_LIST_FILE_NAME;
    NSMutableData *dlcListData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dlcListData];
    [archiver encodeObject:users forKey:fileName];
    [archiver finishEncoding];
    [FileUtils saveFile:fileName FileData:dlcListData withDirectoryName:dirname];

}

//删除处理DLC本地数据
- (void) removeDLCUnuseUserWithNewList:(NSArray *)newList
{
    NSString *oldfileName = @"usr.dat";
    if ([FileUtils isFileExist:oldfileName inDirectory:lastCheckmeName]) {
        
        NSData *data =  [FileUtils readFile:oldfileName inDirectory:lastCheckmeName];
        NSArray *olduserListArr = [self parseOldUserList_WithFileData:data];
        
        if (olduserListArr.count != 0) { //本地有数据
            
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < olduserListArr.count; i++) {
                
                User *user  = olduserListArr[i];
                UserItem *userItem = [[UserItem alloc] init];
                userItem.ID = user.ID;
                userItem.ICO_ID = user.ICO_ID;
                userItem.dtcBirthday = user.dtcBirthday;
                userItem.headIcon = user.headIcon;
                userItem.weight = user.weight;
                userItem.height = user.height;
                userItem.name = user.name;
                userItem.age = user.age;
                userItem.gender = user.gender;
                userItem.medical_id = [NSString stringWithFormat:@"%@%d",lastCheckmeName,user.ID];
                [array addObject:userItem];
                
            }
            
            [self saveUserList:array withDirectoryName:lastCheckmeName];
            [FileUtils deleteFile:@"usr.dat" inDirectory:lastCheckmeName];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSLog(@"documentsDirectory%@",documentsDirectory);
            NSFileManager *fileManage = [NSFileManager defaultManager];
            NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:lastCheckmeName];
            NSDirectoryEnumerator *enumerator = [fileManage enumeratorAtPath:myDirectory];
            for (NSString *fileName in enumerator)
            {
                NSLog(@"%@",fileName);
                if ([fileName isEqualToString:@"*usr.dat"] || [fileName isEqualToString:@"usr.dat"]) {
                    
                }else{
                    
                    if([fileName rangeOfString:@"*"].location ==NSNotFound)//_roaldSearchText
                    {
                        
                        if([fileName rangeOfString:@"ECG"].location !=NSNotFound || [fileName rangeOfString:@"SPO2"].location !=NSNotFound || [fileName rangeOfString:@"TEMP"].location !=NSNotFound){
                        
                            NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",lastCheckmeName,fileName]];
                            NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@1%@*",lastCheckmeName,lastCheckmeName,fileName]];
                            [fileManage moveItemAtPath:old toPath:new error:nil];
                            [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@1%@*",lastCheckmeName,fileName]];
                            [UserDefaults synchronize];
                        
                        }
                        
                            NSString *old = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",lastCheckmeName,fileName]];
                            NSString *new = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@%@*",lastCheckmeName,lastCheckmeName,fileName]];
                            [fileManage moveItemAtPath:old toPath:new error:nil];
                            [UserDefaults setObject:fileName forKey:[NSString stringWithFormat:@"%@%@*",lastCheckmeName,fileName]];
                            [UserDefaults synchronize];
                            
                    }
                    
                }
                
            }
        }
        
    }
    
    //从本地拿数据UserList
    NSMutableArray *dlcListArr = [NSMutableArray array];
    NSString *fileName = [NSString stringWithFormat:Home_USER_LIST_FILE_NAME];
    //  读取本地文件
    if ([FileUtils isFileExist:fileName inDirectory:lastCheckmeName]) {
        
        NSData *dlcListData = [FileUtils readFile:fileName inDirectory:lastCheckmeName];
        NSKeyedUnarchiver *unArch = [[NSKeyedUnarchiver alloc] initForReadingWithData:dlcListData];
        dlcListArr = [unArch decodeObjectForKey:fileName];
    }

    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:newList];
    NSMutableArray *totalUsers = [NSMutableArray array];
    for (User *user in array) {
        UserItem *userItem = [[UserItem alloc] init];
        userItem.ID = user.ID;
        userItem.ICO_ID = user.ICO_ID;
        userItem.dtcBirthday = user.dtcBirthday;
        userItem.headIcon = user.headIcon;
        userItem.weight = user.weight;
        userItem.height = user.height;
        userItem.name = user.name;
        userItem.age = user.age;
        userItem.gender = user.gender;
        userItem.ID = user.ID;
        if([user.medical_id isKindOfClass:[NSNull class]]){
        
            userItem.medical_id = [NSString stringWithFormat:@"%@%c",lastCheckmeName,user.ID];

        }else{
        
            userItem.medical_id = user.medical_id;

        }
        [totalUsers addObject:userItem];
    }

    NSMutableArray *array1 = [NSMutableArray arrayWithArray:dlcListArr];
    for (User *user in newList) {
        
           for (UserItem *localItem in dlcListArr) {
               
            if ([user.medical_id isEqualToString:localItem.medical_id]) {
                //存在相同的
                [array1 removeObject:localItem];
                
            }
        }
    }
    
//    for (UserItem *item in array1) {
//        
//        item.ID = -1;
//        
//    }
    
    [totalUsers addObjectsFromArray:array1];
    [self saveUserList:totalUsers withDirectoryName:lastCheckmeName];
    
    //每个user的 ID 和名字都是唯一对应的，如果不对应则主机肯定删除了这个用户   此时应删除之前对应ID下载过的所有数据 （删除本地以ID号为前缀命名的所有数据）
//    NSData *oldUserData = [FileUtils readFile:Home_USER_LIST_FILE_NAME inDirectory:lastCheckmeName];
//    if (oldUserData) {  //如果本地存储过usr.dat数据
//        NSArray *oldList = [FileParser parseUserList_WithFileData:oldUserData];
//        //遍历比较
//        for (User *newUser in newList) {
//            for (User *oldUser in oldList) {
//                if (newUser.ID == oldUser.ID) {  //如果两个ID相同 其他信息却不同   就删掉这个ID对应的本地数据
//                    NSString *newBirthDay = [NSDate dateDescFromDateComp:newUser.dtcBirthday];
//                    NSString *oldBirthDay = [NSDate dateDescFromDateComp:oldUser.dtcBirthday];
//                    
////                    if (![newUser.name isEqualToString:oldUser.name]) {
//                    //修改了(12.15)
//                     if (![newUser.name isEqualToString:oldUser.name] || newUser.gender != oldUser.gender || ![newBirthDay isEqualToString:oldBirthDay]) {
//                    
//                        //dlc数据
//                        NSArray *dlc_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%d_DLC", oldUser.ID] inDirectory:lastCheckmeName];
//                        for (NSString *fileName in dlc_data_arr) {
//                            [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//                        }
//                        //ped数据
//                        NSArray *ped_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%d_PED_Data", oldUser.ID] inDirectory:lastCheckmeName];
//                        for (NSString *fileName in ped_data_arr) {
//                            [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//                        }
//                        
//                        
//                        //relaxme
//                         NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%d_RELAXME_Data", oldUser.ID] inDirectory:lastCheckmeName];
//                         for (NSString *fileName in fileArr) {
//                                 [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//                            }
//                        
//                    }
//                }
//            }
//        }
//        
//        //如果新数组中找不到旧数组中user对应的ID号 则删除这个ID对应的本地数据
//        NSMutableArray *newUserID = [NSMutableArray array];
//        for (User *newUser in newList) {
//            [newUserID addObject:[NSString stringWithFormat:@"%d",newUser.ID]];
//        }
//        
//        NSMutableArray *oldUserID = [NSMutableArray array];
//        for (User *oldUser in oldList) {
//            [oldUserID addObject:[NSString stringWithFormat:@"%d",oldUser.ID]];
//        }
//        [oldUserID removeObjectsInArray:newUserID];
//        for (NSString *ID in oldUserID) {
//            //删除数据
//            //dlc数据
//            NSArray *dlc_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_DLC", ID] inDirectory:lastCheckmeName];
//            for (NSString *fileName in dlc_data_arr) {
//                [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//            }
//            //ped数据
//            NSArray *ped_data_arr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_PED_Data", ID] inDirectory:lastCheckmeName];
//            for (NSString *fileName in ped_data_arr) {
//                [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//            }
//            
//            //relaxme
//            NSArray *fileArr = [FileUtils readAllFileNamesInDocumentsWithPrefix:[NSString stringWithFormat:@"%@_RELAXME_Data", ID] inDirectory:lastCheckmeName];
//            
//            for (NSString *fileName in fileArr) {
//                [FileUtils deleteFile:fileName inDirectory:lastCheckmeName];
//            }
//
//            
//        }
//    }
    
}

- (void)isAirtrace
{

    [SVProgressHUD dismiss];
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    // 获取故事板
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    // 获取故事板中某个View
    MiniMonitorViewController *next = [board instantiateViewControllerWithIdentifier:@"MiniMonitorViewController"];
    // 跳转
    BOOL _bool = !([AppDelegate GetAppDelegate].ischonglian);
    [self presentViewController:next animated:_bool completion:nil];

}

- (BOOL)shouldAutorotate{
    
    return NO;
    
}

- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self removeAllObserver];
}

@end
