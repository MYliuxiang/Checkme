//
//  PedCell.h
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface PedCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel* date;
@property(nonatomic,retain) IBOutlet UILabel* time;
@property(nonatomic,retain) IBOutlet UILabel* step;
@property (weak, nonatomic) IBOutlet UILabel *stepLab;
@property(nonatomic,retain) IBOutlet UILabel* distance;
@property (weak, nonatomic) IBOutlet UILabel *disUnit;
@property(nonatomic,retain) IBOutlet UIImageView *itemImgResultShort;
@property(nonatomic,retain) IBOutlet UIImageView *itemImgResultLong;
@property(nonatomic,retain) IBOutlet UIImageView *imgDown;

@property(nonatomic,retain) IBOutlet UILabel* calorie;
@property(nonatomic,retain) IBOutlet UILabel* fat;
@property(nonatomic,retain) IBOutlet UILabel* speed;
@property(nonatomic,retain) IBOutlet UILabel* totalTime;

@property(nonatomic,retain) IBOutlet UILabel* calorieUnit;
@property(nonatomic,retain) IBOutlet UILabel* fatUnit;
@property(nonatomic,retain) IBOutlet UILabel* speedUnit;
@property(nonatomic,retain) IBOutlet UIImageView* imgCalorie;
@property(nonatomic,retain) IBOutlet UIImageView* imgFat;
@property(nonatomic,retain) IBOutlet UIImageView* imgSpeed;
@property(nonatomic,retain) IBOutlet UIImageView* imgTotalTime;
@property(nonatomic,retain) IBOutlet UIImageView* imgSeperator;

-(void)setPropertyWithUser:(User *)user infoItem:(PedInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
+(NSString *)cellReuseId;
-(void)doOnExpanded;
-(void)doOnCollapsed;

@end
