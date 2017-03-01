//
//  TempCell.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface TempCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel* date;
@property(nonatomic,retain) IBOutlet UILabel* time;
@property(nonatomic,retain) IBOutlet UILabel* temp;
@property (weak, nonatomic) IBOutlet UILabel *tempUnit;
@property(nonatomic,retain) IBOutlet UIImageView *itemImgResult;
@property(nonatomic,retain) IBOutlet UIImageView *imgResult;
@property(nonatomic,retain) IBOutlet UIImageView *imgMode;

-(void)setPropertyWithUser:(User *)user infoItem:(TempInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
+(NSString *)cellReuseId;

@end
