//
//  SLMDetailViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SLMDetailViewController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel* totalTime;
@property (nonatomic,retain) IBOutlet UILabel* drops;
@property (nonatomic,retain) IBOutlet UILabel* dropTime;
@property (nonatomic,retain) IBOutlet UILabel* lowest;
@property (nonatomic,retain) IBOutlet UILabel* average;
@property (nonatomic,retain) IBOutlet UILabel* strResult;
@property (nonatomic,retain) IBOutlet UIImageView* imgResult;
@property (nonatomic,retain) IBOutlet UIView* slmChartView;
@property (nonatomic,retain) IBOutlet UIButton* bnViewDetail;

-(void)setCurUser:(User*) user andCurItem:(SLMItem*) item;

-(IBAction)onBnViewDetailClicked:(id)sender;
@end
