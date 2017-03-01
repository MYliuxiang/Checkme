//
//  SpotCheckCell.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/26.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotCheckItem.h"
#import "Xuser.h"

@interface SpotCheckCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *DateLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgFace;
@property (weak, nonatomic) IBOutlet UIImageView *imgVoice;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoad;

@property (nonatomic, strong) SpotCheckItem *curSpcItem;

-(void)setPropertyWithUser:(Xuser *)xUser infoItem:(SpotCheckItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
-(void)downloadDetail;
+(NSString *)cellReuseId;

@end
