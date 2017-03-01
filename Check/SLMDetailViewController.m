//
//  SLMDetailViewController.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SLMDetailViewController.h"
#import "NSDate+Additional.h"
#import "UIView+Additional.h"
#import "PublicMethods.h"
#import "AppDelegate.h"
#import "SLMWave.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"

#import "SLMAlbumView.h"
#import "AlbumHeader.h"
#import "MobClick.h"
@interface SLMDetailViewController ()

@property (nonatomic,retain) User *curUser;
@property (nonatomic,retain) SLMItem *curSLMItem;
@property (nonatomic,retain) SLMWave *slmWave;
@end

@implementation SLMDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"SLMDetailPage"];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"SLMDetailPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    //隐藏右侧栏按钮
    for (id obj in self.navigationController.navigationBar.subviews) {
        if ([obj isMemberOfClass:[UIButton class]]) {
            UIButton *btn = obj;
            [btn setHidden:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
    [self configSummary];
    [self addSLMWave];
}

-(void)configSummary
{
    //总时间
    U32 gap = _curSLMItem.totalTime;
    int h = gap/3600;
    int m = (gap - h*3600)/60;
    int s = gap - m*60 - h*3600;
    //总时间
    if (h==0) {
        _totalTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
    }else {
        _totalTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
    }
    
    _drops.text = INT_TO_STRING(_curSLMItem.LO2Count);
    //跌落时间
    h = self.curSLMItem.LO2Time/3600;
    m = (self.curSLMItem.LO2Time - h*3600)/60;
    s = self.curSLMItem.LO2Time - m*60 - h*3600;
    if (h==0) {
        _dropTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
    }else {
        _dropTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
    }
    
    _lowest.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curSLMItem.LO2Value);
    _average.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curSLMItem.AverageSpo2);
    //诊断结果
    if(_curSLMItem.LO2Count!=0){
        _strResult.text = DTLocalizedString(@"Blood Oxygen drops detected", nil);
    }else if(self.curSLMItem.enPassKind==kPassKind_Pass){
        _strResult.text = DTLocalizedString(@"No abnormalities detected", nil);
    }else{
        _strResult.text = DTLocalizedString(@"Unable to Analyze", nil);
    }
    //笑脸
    _imgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curSLMItem.enPassKind]];
}

-(void)addSLMWave
{
    CGRect bond = CGRectMake(0, 0, _slmChartView.frame.size.width, _slmChartView.frame.size.height);
    _slmWave = [[SLMWave alloc]initWithFrame:bond dataItem:_curSLMItem];
    if(_slmWave)
        [_slmChartView addSubview:_slmWave];
}

-(void)setCurUser:(User*) user andCurItem:(SLMItem*) item
{
    _curUser = user;
    _curSLMItem = item;
}

-(IBAction)onBnViewDetailClicked:(id)sender
{
    [_slmWave onBnViewDetailClicked];
    if ([_slmWave viewingDetail]) {
        [_bnViewDetail setImage:[UIImage imageNamed:@"view_detail_selected.png"] forState:UIControlStateNormal];
    }else{
        [_bnViewDetail setImage:[UIImage imageNamed:@"view_detail.png"] forState:UIControlStateNormal];
    }
}

//导航栏分享
- (IBAction)onShareButtonClicked:(id)sender
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:DTLocalizedString(@"Choose a way to share", nil)];
    [alertView addButtonWithTitle:DTLocalizedString(@"Save to Album", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              SLMAlbumView *slmAlbum = [[SLMAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andSLMItem:_curSLMItem];
                              UIImage *image = [slmAlbum captureView];
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                          }];
    [alertView addButtonWithTitle:DTLocalizedString(@"Share", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              SLMAlbumView *slmAlbum = [[SLMAlbumView alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height) andSLMItem:_curSLMItem];
                              UIImage *image = [slmAlbum captureView];
                              NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
                              UIImage *imgCapture = [UIImage imageWithData:imageData];
                              NSString *msgBody = [NSString stringWithFormat:DTLocalizedString(@"Name:%@\nMeasure Time:%@\nMeasurement:%@\nReports:See file attached\n", nil),_curUser.name,[NSDate engDescOfDateComp:_curSLMItem.dtcStartDate][2],DTLocalizedString(@"Sleep Monitor", nil)];
                              [self shareByActivity:imgCapture shareText:msgBody];
                          }];
#warning 点击 取消按钮 Cancel   hjzXx
    [alertView addButtonWithTitle:DTLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];
}

//保存结果反馈
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){//失败
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Save failed, please check your system's privacy settings.", nil) duration:3];
    }
    else{//成功
        [SVProgressHUD showSuccessWithStatus:DTLocalizedString(@"Save succeeded", nil)];
    }
}

//分享
-(void)shareByActivity:(UIImage*)shareImg shareText:(NSString*)shareText
{
    NSArray *activityItems;
    if (shareImg != nil) {
        activityItems = @[shareText, shareImg];
    } else {
        activityItems = @[shareText];
    }
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypePrint,UIActivityTypeAirDrop,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
