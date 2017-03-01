//
//  CheckmeUpdateViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "CheckmeUpdateViewController.h"
#import "PostUtils.h"
#import "PostInfoMaker.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "NetworkUtils.h"
#import "LanguagePatch.h"
#import "AppPatch.h"
#import "FileUtils.h"
#import "DownloadUtils.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "Colors.h"
#import "BTUtils.h"

#import "MobClick.h"
#define URL_SERVER_ROOT (@"http://119.29.77.15:8089")

@interface CheckmeUpdateViewController()
{
    UIProgressView *_progressGView;
    NSString *curDirName;
}

@property(nonatomic,retain) FileToDwon *appFile;
@property(nonatomic,retain) FileToDwon *languageFile;
@property(nonatomic,retain) FileToRead *appPatch;
@property(nonatomic,retain) FileToRead *languagePatch;

@property (nonatomic, copy) NSString *periphralName;
@end

@implementation CheckmeUpdateViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"upDetailPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"upDetailPage"];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNavigationButton];
    [self addProgresss];
    
    [self getPathsInfo];  //获取路径
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
    
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
    self.periphralName = lastCheckmeName;
    NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
    //本地当前文件夹名称
    curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : lastCheckmeName;
//#warning 清除记录 hjz
//    //清除记录
//    [UserDefaults removeObjectForKey:lastCheckmeName];
//    [UserDefaults synchronize];
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >0000000000");
    
}

#warning 添加 进度条
- (void)addProgresss
{
    CGRect rect;
    rect.size.width = CUR_SCREEN_W*0.46;
    rect.size.height = 6;
    rect.origin.x = self.view.center.x - rect.size.width/2;
    rect.origin.y = self.view.center.y - rect.size.height/2;
    _progressGView = [[UIProgressView alloc] initWithFrame:rect];
    [self.view addSubview:_progressGView];
    //进度百分比
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+rect.size.width+5, rect.origin.y-7, 80, 14)];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.textColor = [UIColor blackColor];
    _progressLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_progressLabel];
    //提示
    _HUDlabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 150/2, rect.origin.y + 14, 150, 40)];
    _HUDlabel.backgroundColor = [UIColor clearColor];
    _HUDlabel.textColor = [UIColor blackColor];
    _HUDlabel.font = [UIFont systemFontOfSize:12];
    _HUDlabel.textAlignment = NSTextAlignmentCenter;
    _HUDlabel.text = nil;
    [self.view addSubview:_HUDlabel];
}

//*****************************
//点击取消的按钮
- (void)addNavigationButton
{
    /**
          原来写的 UIBarButtonItem
     
     - returns: 添加左边的按钮
     */
    /*
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)]; //这里的样式是自己定义的
    self.navigationItem.leftBarButtonItem = leftItem;
     这里使用 UIBarButtonSystemItemCancel 取消 按钮的样式的item  在语言为中文的情况下显示 取消文字 样式 在 语言切换成 英语模式时  是  Cancel  样式...
     
    */
    
#warning 使用自己定义的一个button 来添加到  UIBarButtonItem 的左边 成为 左边的取消按钮(CustomView ...  自定义View控件)
    UIButton *button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(back)
     forControlEvents:UIControlEventTouchUpInside];  //设置点击按钮时的触发方法
    button.frame = CGRectMake(0, 0, 80, 20);
    [button setTitle:@"Cancel" forState:UIControlStateNormal];   //不论处于何种语言开发环境都显示 Cancel 的文字样式
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    button.titleLabel.textAlignment = NSTextAlignmentRight;  此代码设置对button无效  (这样设置的左对齐是不管用的)
    
    /**
     *  <#Description#>
     *
     *  @param 0  top    距离头部 的距离 为 0
     *  @param 10 left   距离左边的距离为 10
     *  @param 0  bottom  距离底部的距离为  0
     *  @param 0  right   距离右边的距离为0
     *
     *  @return <#return value description#>
     UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
     
     */
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;//这样设置才是左对齐方式
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //button.backgroundColor = [UIColor redColor];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = menuButton;
    
}

//点击取消升级按钮的操作
- (void)back
{
    SIAlertView *alertView1 = [[SIAlertView alloc] initWithTitle:DTLocalizedString(@"Warning", nil) andMessage:DTLocalizedString(@"Really want to stop update?", nil)];
    [alertView1 addButtonWithTitle:DTLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [self.navigationController popViewControllerAnimated:YES];
        //终止app包下载的进程
        [[[DownloadUtils alloc] init] cancelDownLoad];
        
        //如果文件正在写入  中止文件的写入
        [[BTCommunication sharedInstance] writeFailed];
        
    }];
#warning 点击 取消按钮 Cancel   hjzXx
    [alertView1 addButtonWithTitle:DTLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
    }];
    [alertView1 show];
}
//*****************************

//获取升级包信息，包括版本和路径等
-(void)getPathsInfo   //获取路径
{
    if (!_checkmeInfo || !_wantLanguage) {
        return;
    }
    if(![NetworkUtils isNetworkEnabled]) {
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Network is not available", nil) duration:2];  //提示网络不可用
        return;
    }
    NSString* dataStr = [PostInfoMaker makeGetPatchsInfo:_checkmeInfo WantLanguage:_wantLanguage];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    //相应观察者在哪里创建的？    答：postUtils中 数据传输完成 或出错时
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGetPatchsSuccess:) name:NtfName_PostSuccess object:nil];  //post  请求成功的通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGetPatchsError) name:NtfName_PostError object:nil];
//    [PostUtils doPost:self.json[@"fileLocate"] DataStr:nil];
    
    [self deleteOldPatchs];
   
    //  问：通知中心在何处创建？  答：DownLoadUtils中 NSURLConnection请求时  对应协议方法中创建
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadSuccess:) name:NtfName_FileDownloadSuccess object:nil];
    
#pragma mark - NSURLConnectionDataDelegate方法中动态获取到一份份下载文件时  发出对应通知  object中包含文件的下载进度，文件的总大小及当前已下载大小
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadPartFinished:) name:NtfName_FileDownloadPartFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadError) name:NtfName_FileDownloadError object:nil];
    
    [[[DownloadUtils alloc]init] downloadFile:self.json[@"language"][_wantLanguage] FileName:@"language.bin"];
    [[[DownloadUtils alloc]init] downloadFile:self.json[@"fileLocate"] FileName:@"app.bin"];
    [_progressGView setTag:2];
    _HUDlabel.text = DTLocalizedString(@"Downloading...", nil);//下载提示性信息
    
}

#pragma mark - 通过发网络请求获得相应语言包和app包的相应属性信息
//获取升级包信息成功(并未开始下载)    post请求数据请求完成时 的回调
-(void)onGetPatchsSuccess:(NSNotification *)ntf
{
    NSMutableData* responseData = ntf.object;
    if (responseData) {
        NSError *err;//定义错误信息变量
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&err];
        NSString* result;
       #pragma mark - important
        
        if (jsonObject!=nil && (result=[jsonObject objectForKey:@"Result"])!=nil ) {
            if ([result isEqual:@"NULL"] || [result isEqual:@"EXP"]) {
                //获取错误，升级失败
                DLog(@"获取升级包错误，升级失败");
                [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_PostError object:nil];
            }else {
                //获取成功，判断App包和语言包版本，并下载
                DLog(@"获取成功，判断App包和语言包版本，并下载");
                [[NSNotificationCenter defaultCenter]removeObserver:self];//移除无用接收器
#pragma mark - 语言包和app包的解析类     由此获得带有属性（信息）的实例     （LanguagePatch 语言包、语言补丁）
                LanguagePatch* languagePatch = [[LanguagePatch alloc]initWithJSON:jsonObject];
                AppPatch* appPatch = [[AppPatch alloc]initWithJSON:jsonObject];
                [self deleteOldPatchs];

#pragma mark - 通过获取的语言包和app包的信息来下载相应安装包
                [self downLoadPatchs:languagePatch AppPatch:appPatch];
                _HUDlabel.text = DTLocalizedString(@"Downloading...", nil);//下载提示性信息
            }
        }else{
            //获取失败
            //post 请求失败处理的通知
            [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_PostError object:nil];
        }
    }
}

//获取升级包失败
-(void)onGetPatchsError
{
    DLog(@"获取语言列表失败");
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Update failed", nil) duration:2];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//删除本地旧的升级包
-(void)deleteOldPatchs
{
    DLog(@"删除本地已存在的补丁");
    [FileUtils deleteFile:@"app.bin" inDirectory:curDirName];        //app包
    [FileUtils deleteFile:@"language.bin" inDirectory:curDirName];  //语言包
}

#pragma mark - 开始下载安装包
//判断并下载升级包
-(void)downLoadPatchs:(LanguagePatch*) languagePatch AppPatch:(AppPatch*) appPatch
{
    if (!languagePatch || !appPatch || !_progressGView) {
        //下载失败
        return;
    }
    
    //添加下载接收器
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //  问：通知中心在何处创建？  答：DownLoadUtils中 NSURLConnection请求时  对应协议方法中创建
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadSuccess:) name:NtfName_FileDownloadSuccess object:nil];
    
#pragma mark - NSURLConnectionDataDelegate方法中动态获取到一份份下载文件时  发出对应通知  object中包含文件的下载进度，文件的总大小及当前已下载大小
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadPartFinished:) name:NtfName_FileDownloadPartFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadError) name:NtfName_FileDownloadError object:nil];
    
#pragma mark - 判断语言包和app包是否都需要升级
    if (languagePatch.version == [_checkmeInfo.language intValue]) {
        //语言包版本相同，可能不用升语言包，继续判断
        if ([languagePatch.languages hasPrefix:_checkmeInfo.theCurLanguage]) {
            //语言包中包含当前语言，至少不用升语言包
            if (appPatch.version == [_checkmeInfo.software intValue]) {
                //①app包也相同，两个都不升
                DLog(@"两个都不升");
                [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Your version is up to date", nil) duration:2];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FileDownloadError object:nil];
            }else {
                //②app包不同，只升App
                DLog(@"只升APP");
#pragma mark - post请求 下载数据
                [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,appPatch.address] FileName:@"app.bin"];
                [_progressGView setTag:1];
            }
        }else {
            //语言包中不包含当前语言，至少要升语言包
            if (appPatch.version == [_checkmeInfo.software intValue]) {
                //③app包相同，只升语言包
                DLog(@"只升语言包");
                [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,languagePatch.address] FileName:@"language.bin"];
                [_progressGView setTag:1];
            }else {
                //④app包不同，两个都升
                DLog(@"两个都升");
                [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,languagePatch.address] FileName:@"language.bin"];
                [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,appPatch.address] FileName:@"app.bin"];
                [_progressGView setTag:2];
            }
        }
        
    }else {
        //⑤语言包版本不同，两个都升
        DLog(@"两个都升");
        [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,languagePatch.address] FileName:@"language.bin"];//语言包
        [[[DownloadUtils alloc]init] downloadFile:[NSString stringWithFormat:@"%@%@",URL_SERVER_ROOT,appPatch.address] FileName:@"app.bin"];//应用包
        [_progressGView setTag:2];
    }
}

#pragma mark - 全部下载成功时 的回调方法
-(void)onDownloadSuccess:(NSNotification*) ntf
{
    if (!ntf || !ntf.object) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadError object:nil];
        return;
    }
    FileToDwon *fileToDown = ntf.object;
    DLog(@"%@安装包下载成功!!!",fileToDown.fileName);
    
    //判断是否两个包都下载完成
    double progress = 0;
    progress += _appFile ? _appFile.fileProgress : 0;
    progress += _languageFile ? _languageFile.fileProgress : 0;
    if (progress == _progressGView.tag) {
        
        //全部下载完了
        DLog(@"全部安装包下载完成");
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        _HUDlabel.text = DTLocalizedString(@"Updating...", nil);
        
        //准备写入,写入前先设置进度条属性
        if ([FileUtils isFileExist:@"language.bin" inDirectory:_periphralName] && [FileUtils isFileExist:@"app.bin" inDirectory:_periphralName]) { //如果在本地两个包都存在
            DLog(@"两个包都写入");
            [_progressGView setTag:2];
            [_progressGView setProgress:0];   //原进度条进度置为 0
            _progressLabel.text = nil;
#pragma mark - 开始写入
            //加入提示：
            [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Download success", nil) duration:2];
            [self writePatchsToCheckme:FILE_Type_Lang_Patch];
            
        }else if([FileUtils isFileExist:@"app.bin" inDirectory:_periphralName]){  //如果在本地只有app包
            DLog(@"只写App包");
            [_progressGView setTag:1];
            [_progressGView setProgress:0];
            _progressLabel.text = nil;
#pragma mark - 开始写入
            //加入提示：
            [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Download success", nil) duration:2];
            [self writePatchsToCheckme:FILE_Type_App_Patch];
            
        } else if([FileUtils isFileExist:@"language.bin" inDirectory:_periphralName]) {//  如果本地只有Language包
            DLog(@"致谢Language包");
            [_progressGView setTag:1];
            [_progressGView setProgress:0];
            _progressLabel.text = nil;
#pragma mark - 开始写入
            //加入提示：
            [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Download success", nil) duration:2];
            [self writePatchsToCheckme:FILE_Type_Lang_Patch];
        }
        //开启屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }else if(progress == _progressGView.tag/2) {
        
    }
}

//下载失败处理函数
-(void)onDownloadError
{
    DLog(@"升级包下载失败");
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Update failed", nil) duration:2];
    //下载失败后移除接收器
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 正在下载中的回调函数   可用来更新进度条
//下载中进度条更新
-(void)onDownloadPartFinished:(NSNotification*) ntf
{
    if (!ntf && !ntf.object && _progressGView) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NtfName_FileDownloadError object:nil];
        return;
    }
    FileToDwon *fileToDown = ntf.object;
    
    if ([fileToDown.fileName isEqual:@"app.bin"]) {
        //是app包
        _appFile = fileToDown;
    }else if ([fileToDown.fileName isEqual:@"language.bin"]) {
        //是language包
        _languageFile = fileToDown;
    }
    
    //设置进度条
    double progress = 0;
    progress += _appFile ? _appFile.fileProgress : 0;
    progress += _languageFile ? _languageFile.fileProgress : 0;
    //tag为progressGView的最大值
    [_progressGView setProgress:(progress / _progressGView.tag) animated:YES];
    _progressLabel.text = [NSString stringWithFormat:@"%.f%%",(progress / _progressGView.tag) * 100];
//    DLog(@"已下载：%.1f%%",(progress / _progressGView.tag) * 100);
}

#pragma mark - 写入升级包到Checkme
-(void)writePatchsToCheckme:(int)patchType
{
    //修改当前imageView为写入图片
    UIImage *image = [UIImage imageNamed:@"writing.png"];
    self.imageView.image = image;
    
    CGRect imaFrame = self.imageView.frame;
    imaFrame.size.width = 200;
    imaFrame.size.height = 70;
    self.imageView.frame = imaFrame;
    self.imageView.center = CGPointMake(self.view.bounds.size.width/2, self.imageView.center.y);
    
    //从本地拿到 每次连接的蓝牙设备名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastCheckmeName = [userDefaults objectForKey:@"LastCheckmeName"];
//#warning 清除记录 hjz
//    //清除记录
//    [UserDefaults removeObjectForKey:lastCheckmeName];
//    [UserDefaults synchronize];
//    DBG(@"NSUserDefault 清除记录 hjz ---------- >NSUserDefault 清除记录 hjz ---------- >1111111111");
    //判断包类型，写入不同文件
    
    [BTCommunication sharedInstance].delegate = self;
#pragma mark - 通过蓝牙写文件
    NSString *fileName = nil;
    if (patchType == FILE_Type_App_Patch) {
        fileName = @"app.bin";
        NSData *fileData = [FileUtils readFile:fileName inDirectory:lastCheckmeName];
        [[BTCommunication sharedInstance] BeginWriteFile:fileName FileType:patchType andFileData:fileData];
    }else if (patchType == FILE_Type_Lang_Patch) {
        fileName = @"language.bin";
        NSData *fileData = [FileUtils readFile:fileName inDirectory:lastCheckmeName];
        [[BTCommunication sharedInstance] BeginWriteFile:fileName FileType:patchType andFileData:fileData];
    }
}


#pragma mark - 全部写入完成
//升级包发送成功处理函数
- (void)writeSuccessWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    if (!fileData) {
        return;
    }
    if (fileData.fileType == FILE_Type_Lang_Patch) {  //是语言包
        if ([FileUtils isFileExist:@"app.bin" inDirectory:_periphralName]) {  //如果有app包  继续写
            DLog(@"语言包写完，继续写app包");
            [self writePatchsToCheckme:FILE_Type_App_Patch];
        }else {
            //没有app包，写入完成
            DLog(@"语言包写完，全部包写完");
            //关闭屏幕常亮的方法
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            
#pragma mark - 全部写入完成  加入提示  并且跳到初始页面
            [self writeEndNotice];
        }
    }else if(fileData.fileType == FILE_Type_App_Patch) {   //只有app包
        //只是app包，则写入完成
         DLog(@"app包写完，全部包写完");
        //关闭屏幕常亮的方法
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
#pragma mark - 全部写入完成  加入提示  并且跳到初始页面
        [self writeEndNotice];
    }
}

#warning 更新完后重新启动....   Restart   (重启App应用程序...)
- (void)writeEndNotice
{
    SIAlertView *alView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Update success, application will restart", nil)];
    [alView addButtonWithTitle:DTLocalizedString(@"Restart" , nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        //其他操作
        //关闭屏幕常亮
        [[ UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [BTCommunication sharedInstance].peripheral = nil;
        [BTUtils GetInstance].currentPeripheral = nil;
        
        //跳转到window的根视图控制器  重启app   （在这里有点质疑耶。。。。这不是推出根视图控制器吗？这就是重启？？fuck）
        RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"rootViewController"];
       [self presentViewController:rootVC animated:YES completion:nil];
    
        
    }];
    [alView show];
}

//升级包发送失败处理函数
- (void)writeFailedWithData:(FileToRead *)fileData
{
    [BTCommunication sharedInstance].delegate = nil;
    //关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO ];
    [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Update failed", nil) duration:2];
    [self.navigationController popViewControllerAnimated:YES];
    //关闭屏幕常亮的方法
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
}


#pragma mark - BTCommunication  delegate
//写入中 更新进度条
- (void)postCurrentWriteProgress:(FileToRead *)fileData
{
    if (!fileData && _progressGView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FileWriteError object:nil];
        return;
    }
    FileToRead *fileToRead = fileData;
    if ([fileToRead fileType] == FILE_Type_App_Patch) {
        //是app包
        _appPatch = fileToRead;
    }else if ([fileToRead fileType] == FILE_Type_Lang_Patch) {
        //是language包
        _languagePatch = fileToRead;
    }
    
    //设置进度条
    double progress = 0;
    progress += _appPatch ? ((double)_appPatch.curPkgNum/(double)_appPatch.totalPkgNum) : 0;
    progress += _languagePatch ? ((double)_languagePatch.curPkgNum/(double)_languagePatch.totalPkgNum) : 0;
    //tag为progressGView的最大值
    [_progressGView setProgress:(progress / _progressGView.tag) animated:YES];
    _progressLabel.text = [NSString stringWithFormat:@"%.f%%",(progress / _progressGView.tag) * 100];
}

@end

