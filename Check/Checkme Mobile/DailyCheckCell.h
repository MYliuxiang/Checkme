//
//  DailyCheckCell.h
//  MyCellTest
//
//  Created by Joe on 14-8-1.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Colors.h"
#import "DailyCheckItem.h"
#import "User.h"

@interface DailyCheckCell : UITableViewCell

//summary
@property (nonatomic,retain) IBOutlet UILabel *date;
@property (nonatomic,retain) IBOutlet UILabel *time;
@property (nonatomic,retain) IBOutlet UILabel *hrSummaryValue;
@property (nonatomic,retain) IBOutlet UILabel *spo2SummaryValue;
@property (nonatomic,retain) IBOutlet UIImageView *ecgImgResult;
@property (nonatomic,retain) IBOutlet UIImageView *spo2ImgResult;
@property (retain, nonatomic) IBOutlet UIImageView *isVoiceImg;
@property (nonatomic,retain) IBOutlet UIImageView *enter;
@property (nonatomic,retain) IBOutlet UIImageView *itemImgResult;
@property (strong, nonatomic) IBOutlet UILabel *RPPlabel;
@property (strong, nonatomic) IBOutlet UILabel *SBPlable;
@property (strong, nonatomic) IBOutlet UILabel *SBPmmHg;

+(NSString *)cellReuseId;
-(void)setPropertyWithUser:(User *)user infoItem:(DailyCheckItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
-(void)downloadDetail;

@end
