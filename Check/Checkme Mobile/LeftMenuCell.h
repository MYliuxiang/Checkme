//
//  LeftMenuCell.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-9.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuCell : UITableViewCell

-(id)initWithImgName:(NSString*)imgName andText:(NSString*) text;
+(NSString *)cellReuseId;

@property(nonatomic,retain) IBOutlet UIImageView* imgView;
@property(nonatomic,retain) IBOutlet UILabel* lbl;

@end
