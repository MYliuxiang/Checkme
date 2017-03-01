//
//  DailyCheckDetailViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-6.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Xuser.h"
#import "SpotCheckItem.h"

@interface DailyCheckDetailViewController : UIViewController

@property(nonatomic,retain) IBOutlet UIView* waveView;

@property(nonatomic,retain) IBOutlet UILabel* hr;//心率
@property(nonatomic,retain) IBOutlet UILabel* qrs;
@property(nonatomic,retain) IBOutlet UILabel* spo2;
@property(nonatomic,retain) IBOutlet UILabel* pi;
@property(nonatomic,retain) IBOutlet UILabel* ecgStrResult;
@property(nonatomic,retain) IBOutlet UILabel* spo2StrResult;

@property(nonatomic,retain) IBOutlet UIImageView* ecgImgResult;
@property(nonatomic,retain) IBOutlet UIImageView* spo2ImgResult;
@property (weak, nonatomic) IBOutlet UIButton *imageVoice;

@property (weak, nonatomic) IBOutlet UIView *dataResultView;
@property(nonatomic,retain) IBOutlet UIView* bpAbsView;
@property(nonatomic,retain) IBOutlet UIView* bpReView;

@property(nonatomic,retain) IBOutlet UILabel* bpAbsValue;

@property(nonatomic,retain) IBOutlet UILabel* bpAbsResult;
@property (weak, nonatomic) IBOutlet UIButton *bpAbsVoice;

@property(nonatomic,retain) IBOutlet UILabel* bpReValue;
@property(nonatomic,retain) IBOutlet UILabel* bpReResult;
@property (weak, nonatomic) IBOutlet UIButton *bpReVoice;

//spc
@property (weak, nonatomic) IBOutlet UIView *tempView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempValue;
@property (weak, nonatomic) IBOutlet UILabel *tempUnit;
@property (weak, nonatomic) IBOutlet UIButton *tempVoiceBtn;
@property (weak, nonatomic) IBOutlet UIImageView *tempFaceImg;

@property (strong, nonatomic) IBOutlet UIView *bgLJnewView;
@property (strong, nonatomic) IBOutlet UILabel *lableRppValue;
@property (strong, nonatomic) IBOutlet UILabel *lableSbpValue;
@property (strong, nonatomic) IBOutlet UILabel *labRPPResult;
@property (strong, nonatomic) IBOutlet UILabel *labmmHg;

-(void)setCurUser:(User*) user andCurItem:(DailyCheckItem*) item;
-(void)setCurXuser:(Xuser*) xUser andCurSpcItem:(SpotCheckItem*) spcItem;

@property (nonatomic, strong) NSMutableArray *BPstrArr;
@end
