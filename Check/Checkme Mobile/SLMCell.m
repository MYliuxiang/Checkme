//
//  SLMCell.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SLMCell.h"
#import "AppDelegate.h"
#import "BTUtils.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "SLMViewController.h"
#import "Colors.h"
#import "UAProgressView.h"
#import "FileUtils.h"

@interface SLMCell() <SLMItemDelegate>

@property (nonatomic,retain) SLMItem   *curSLMItem;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;
@property (nonatomic,retain) UAProgressView* progressView;
@property (nonatomic, copy) NSString *periphralName;
@end

@implementation SLMCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)init
{
    NSArray *arr;
    arr = [[NSBundle mainBundle] loadNibNamed:@"SLMCell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];
    if(self){
        //从本地拿到 每次连接的蓝牙设备名
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.periphralName = [userDefaults objectForKey:@"LastCheckmeName"];

    }
    return self;
}

+(NSString *)cellReuseId
{
    return @"cellReuseId_SLMCell";
}

-(void)setPropertyWithUser:(User *)user infoItem:(SLMItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.curSLMItem = infoItem;
    self.curUser = user;
    self.fatherVC = fatherVC;
    
    if(_curSLMItem.bDownloadIng)
    {
    }
    [self refreshCellView];
}

-(void)refreshCellView
{
    //summary
    _time.text = [NSDate engDescOfDateComp:_curSLMItem.dtcStartDate][0];
    _date.text = [NSDate engDescOfDateComp:_curSLMItem.dtcStartDate][1];
    
    _imgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curSLMItem.enPassKind]];
    _itemImgResult.backgroundColor = _curSLMItem.enPassKind == kPassKind_Pass ? ITEM_LEFT_BLUE : _curSLMItem.enPassKind == kPassKind_Fail ? ORANGE : [UIColor clearColor];
    
    //读取本地文件
    NSString *fileName = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:_curSLMItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSLMItem.dtcStartDate][1]];
    if ([FileUtils isFileExist:fileName inDirectory:_periphralName]) {
        //  反归档取数据
        NSData *itemData = [FileUtils readFile:fileName inDirectory:_periphralName];
        NSKeyedUnarchiver *unAch = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemData];
        SLMItem *readECGItem = [unAch decodeObjectForKey:fileName];
        _curSLMItem = readECGItem;
    }
    
    //设置enter按钮，信息已经下载
    if(_curSLMItem.innerData){
        [_enter setImage:[UIImage imageNamed:@"ljenter.png"]];
    }
    //没有下载
    else{
        [_enter setImage:[UIImage imageNamed:@"ljdownload.png"]];
    }
    [self refreshProgressVisibility];
}

-(void)downloadDetail
{
    _curSLMItem.slmDelegate = self;
    [_curSLMItem beginDownloadDetail];
    [self initProgress];
}

- (void)onSLMDetailDataDownloadSuccess:(FileToRead *)fileData
{
    _curSLMItem.slmDelegate = nil;
    _curSLMItem.innerData = [FileParser parseSLMData_WithFileData:fileData.fileData];
    
    //  归档存储数据
    NSString *itemStr = [NSString stringWithFormat:SLM_DATA_USER_TIME_FILE_NAME, [NSDate engDescOfDateCompForDataSaveWith:_curSLMItem.dtcStartDate][0], [NSDate engDescOfDateCompForDataSaveWith:_curSLMItem.dtcStartDate][1]];;
    NSMutableData *itemData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:itemData];
    [archiver encodeObject:_curSLMItem forKey:itemStr];
    [archiver finishEncoding];
    
    [FileUtils saveFile:itemStr FileData:itemData withDirectoryName:_periphralName];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self refreshCellView];
    [_progressView removeFromSuperview];
    _enter.hidden = NO;
}

- (void)onSLMDetailDataDownloadTimeout
{
    DLog(@"进入SLM详情下载超时处理函数");
    [self refreshCellView];
    [_progressView removeFromSuperview];
}

- (void)onSLMDetailDataDownloadProgress:(double)progress
{
    if (_progressView) {
        [_progressView setProgress:progress animated:YES];
    }
}

-(void)initProgress
{
    if (_curSLMItem.bDownloadIng) {
        _enter.hidden = YES;
        double bondSize = 35;
        CGRect bond = CGRectMake(_enter.frame.origin.x+((_enter.frame.size.width-bondSize)/2), self.frame.size.height/2-bondSize/2, bondSize, bondSize);
        _progressView = [[UAProgressView alloc] initWithFrame:bond];
        [self addSubview:_progressView];
        [self addSubview:_progressView];
    }
}

-(void)refreshProgressVisibility
{
    if (_curSLMItem.bDownloadIng) {
        if (!_progressView) {
            [self initProgress];
        }
        _enter.hidden = YES;
        _progressView.hidden = NO;
    }else{
        _enter.hidden = NO;
        _progressView.hidden = YES;
    }
}
@end
