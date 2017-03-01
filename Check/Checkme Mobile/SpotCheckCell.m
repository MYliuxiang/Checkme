//
//  SpotCheckCell.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/26.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SpotCheckCell.h"
#import "AppDelegate.h"
#import "BTUtils.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "Colors.h"
#import "UAProgressView.h"
#import "FileUtils.h"

@interface SpotCheckCell () <spotCheckItemDelegate>
@property (nonatomic, copy) NSString *periphralName;
@property (nonatomic, copy) NSString *curDirName;
@property (nonatomic, assign) int curXuserIndex;
@property (nonatomic,retain) NSString  *reID;

@property (nonatomic,retain) Xuser *curXuser;
@property (nonatomic,assign) UIViewController *fatherVC;
@property (nonatomic,retain) UAProgressView* progressView;
@end

@implementation SpotCheckCell

- (id) init
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"SpotCheckCell" owner:self options:nil];
    if (arr) {
        self = arr.firstObject;
    }
    if (self) {
        self.contentView.backgroundColor = Colol_cellbg; //f4f4f4  的一个背景色
#warning 这个是存储蓝牙设备的吗？？
#warning 这个是存储蓝牙设备的吗？？
#warning 这个是存储蓝牙设备的吗？？
#warning 这个是存储蓝牙设备的吗？？
        //从本地拿到 每次连接的蓝牙设备名
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];//将每次连接到的蓝牙设备存储在沙箱中
        self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];
        self.curXuserIndex = (int)[userDefaults integerForKey:@"LastXuser"];
        NSString *offlineDirName = [userDefaults objectForKey:@"OfflineDirName"];
        _curDirName = [AppDelegate GetAppDelegate].isOffline ? offlineDirName : _periphralName;

    }
    return self;
}
- (void) setReuseIdentifier:(NSString *)identifier
{
    self.reID = identifier;
}
+ (NSString *)cellReuseId
{
    return @"spcCell";
}
- (void) setPropertyWithUser:(Xuser *)xUser infoItem:(SpotCheckItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.curSpcItem = infoItem;
    self.curXuser = xUser;
    self.fatherVC = fatherVC;
    
    if(_curSpcItem.bDownloadIng)
    {
    }
    [self refreshCellView];
}
- (void) refreshCellView
{
    self.TimeLabel.text = [NSDate engDescOfDateComp:self.curSpcItem.dtcDate][0];
    self.DateLabel.text = [NSDate engDescOfDateComp:self.curSpcItem.dtcDate][1];
    self.imgFace.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:self.curSpcItem.enECG_PassKind]];
    
    //录音图标
    if (self.curSpcItem.bHaveVoiceMemo) {  //如果有声音
        _imgVoice.hidden = NO;
        _imgVoice.image = [UIImage imageNamed:@"voice_gray.png"];
        
        //在本地找录音数据
        //查找本地的data 数据
        NSString *voiceName = [NSString stringWithFormat:SPC_VOICE_DATA_USER_TIME_FILE_NAME ,_curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:self.curSpcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.curSpcItem.dtcDate][1]];
        if ([FileUtils isFileExist:voiceName inDirectory:_curDirName]) {//本地有录音数据
            _imgVoice.image = [UIImage imageNamed:@"voice.png"];
        }
    }else { //没有声音
        _imgVoice.hidden = YES;  //隐藏这个imgVoice图标
    }
    
    //读取本地文件
    NSString *fileName = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME ,_curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:self.curSpcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:self.curSpcItem.dtcDate][1]];
    if ([FileUtils isFileExist:fileName inDirectory:_curDirName]) {
        //  测试  反归档取数据
        NSData *itemData = [FileUtils readFile:fileName inDirectory:_curDirName];
        //采用反归档技术获取数据  （反归档也称之为解档）
        NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
        SpotCheckItem *readSPCItem = [unAch decodeObjectForKey:fileName];
        self.curSpcItem = readSPCItem;
    }
    
    //设置enter按钮，信息已经下载
    if(self.curSpcItem.innerData || self.curSpcItem.isNoHR){
        [self.imgLoad setImage:[UIImage imageNamed:@"ljenter.png"]];
    }
    //没有下载
    else{
        [self.imgLoad setImage:[UIImage imageNamed:@"ljdownload.png"]];
    }
    
    [self refreshProgressVisibility];//刷新 progress
    
}
//下载cell详情
-(void)downloadDetail
{
    _curSpcItem.spcDelegate = self;
    [_curSpcItem beginDownloadDetail];//开始下载
    [self initProgress];
}

- (void)onDlcDetailDataDownloadSuccess:(FileToRead *)fileData
{
    _curSpcItem.spcDelegate = nil;
    _curSpcItem.innerData =  [FileParser paserSpcInnerData_WithFileData:fileData.fileData];
    
    //  归档存储数据
    NSString *itemStr = [NSString stringWithFormat:SPC_DATA_USER_TIME_FILE_NAME, _curXuser.userID, [NSDate engDescOfDateCompForDataSaveWith:_curSpcItem.dtcDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSpcItem.dtcDate][1]];;
    NSMutableData *itemData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
    [archiver encodeObject:_curSpcItem forKey:itemStr];
    [archiver finishEncoding];
    [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_curDirName];    //存到指定文件夹
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self refreshCellView];
    [_progressView removeFromSuperview];
    _imgLoad.hidden = NO;
}
- (void)onDlcDetailDataDownloadTimeout
{
    [self refreshCellView];
    [_progressView removeFromSuperview];
    _imgLoad.hidden = NO;
}
- (void)onDlcDetailDataDownloadProgress:(double)progress
{
    if (_progressView) {
        [_progressView setProgress:progress animated:YES];
    }
}

//因为cell在tableview中复用，所以要动态刷新pro
-(void)refreshProgressVisibility
{
    if (_curSpcItem.bDownloadIng) {
        if (!self.progressView) {
            [self initProgress];
        }
        self.imgLoad.hidden = YES;
        self.progressView.hidden = NO;
    }else{
        self.imgLoad.hidden = NO;
        self.progressView.hidden = YES;
    }
}

-(void)initProgress
{
    if (self.curSpcItem.bDownloadIng) {
        self.imgLoad.hidden = YES;
        double bondSize = 35;
        CGRect bond = CGRectMake(self.imgLoad.frame.origin.x+((self.imgLoad.frame.size.width-bondSize)/2), self.frame.size.height/2-bondSize/2, bondSize, bondSize);
        self.progressView = [[UAProgressView alloc] initWithFrame:bond];
        [self addSubview:self.progressView];
    }
}

@end
