//
//  SLMCell.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SLMCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel* date;
@property(nonatomic,retain) IBOutlet UILabel* time;
@property(nonatomic,retain) IBOutlet UIImageView *itemImgResult;
@property(nonatomic,retain) IBOutlet UIImageView *imgResult;
@property(nonatomic,retain) IBOutlet UIImageView *enter;

-(void)setPropertyWithUser:(User *)user infoItem:(SLMItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
+(NSString *)cellReuseId;
-(void)downloadDetail;

@end
