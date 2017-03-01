//
//  ECGCell.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECGInfoItem.h"
#import "User.h"

@interface ECGCell : UITableViewCell <ECGInfoItemDelegate>

@property (nonatomic,retain) IBOutlet UILabel *date;
@property (nonatomic,retain) IBOutlet UILabel *time;
@property (nonatomic,retain) IBOutlet UIImageView *ecgImgResult;
@property (nonatomic,retain) IBOutlet UIImageView *imgLead;
@property (nonatomic,retain) IBOutlet UIImageView *imgVoice;
@property (nonatomic,retain) IBOutlet UIImageView *itemImgResult;
@property (nonatomic,retain) IBOutlet UIImageView *enter;
@property (strong, nonatomic) IBOutlet UILabel *hrlable;



@property (nonatomic, strong) ECGInfoItem *curECGItem;

-(void)setPropertyWithUser:(User *)user infoItem:(ECGInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC;
-(void)downloadDetail;
+(NSString *)cellReuseId;
//-(void)setBDownloading:(BOOL)bDownloading;

@end
