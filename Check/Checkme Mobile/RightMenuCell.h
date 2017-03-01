//
//  RightMenuCell.h
//  Checkme Mobile
//
//  Created by Lq on 14-12-11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imagV;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;


- (id) initWithImage:(UIImage *)image andTitle:(NSString *)title;
@end
