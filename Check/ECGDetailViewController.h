//
//  ECGDetailViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ECGDetailViewController : UIViewController

@property(nonatomic,retain) IBOutlet UIView* waveView;

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property(nonatomic,retain) IBOutlet UILabel* hrValue;
@property(nonatomic,retain) IBOutlet UILabel* qrsValue;
@property(nonatomic,retain) IBOutlet UILabel* st;
@property(nonatomic,retain) IBOutlet UILabel* stValue;
@property(nonatomic,retain) IBOutlet UILabel* stUnit;
@property(nonatomic,retain) IBOutlet UILabel* strResult;
@property(nonatomic,retain) IBOutlet UIImageView* imgResult;
@property(nonatomic,retain) IBOutlet UIImageView* imgLead;
@property (weak, nonatomic) IBOutlet UIButton *voiceImg;
@property (strong, nonatomic) IBOutlet UIView *getValueView;

@property (strong, nonatomic) IBOutlet UIImageView *bgValueImage;
@property (strong, nonatomic) IBOutlet UIImageView *sanValueimage;

-(void)setCurUser:(User*) user andCurItem:(ECGInfoItem*) item;

@end
