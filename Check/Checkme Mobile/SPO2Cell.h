//
//  SPO2Cell.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SPO2Cell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel* date;
@property(nonatomic,retain) IBOutlet UILabel* time;
@property(nonatomic,retain) IBOutlet UILabel* spo2;
@property(nonatomic,retain) IBOutlet UILabel* pr;
@property(nonatomic,retain) IBOutlet UILabel* pi;
@property(nonatomic,retain) IBOutlet UIImageView *itemImgResult;
@property(nonatomic,retain) IBOutlet UIImageView *imgResult;

-(void)setPropertyWithUser:(User *)user infoItem:(SPO2InfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
+(NSString *)cellReuseId;
@end
