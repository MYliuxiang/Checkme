//
//  RelaxMeCell.h
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface RelaxMeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lableDate;
@property (strong, nonatomic) IBOutlet UILabel *labletime;
@property (strong, nonatomic) IBOutlet UILabel *lableRelaxaction;
@property (strong, nonatomic) IBOutlet UILabel *lableDuration;
@property (strong, nonatomic) IBOutlet UIImageView *itemImgResult;
@property (weak, nonatomic) IBOutlet UILabel *index;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *hrvValue;
@property (weak, nonatomic) IBOutlet UILabel *relaxationLabel;

-(void)setPropertyWithUser:(User *)user infoItem:(RelaxMeItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
+(NSString *)cellReuseId;

@end
