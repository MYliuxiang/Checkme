//
//  RightMenuCell.m
//  Checkme Mobile
//
//  Created by Lq on 14-12-11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "RightMenuCell.h"

@implementation RightMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (id) initWithImage:(UIImage *)image andTitle:(NSString *)title
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RightMenuCell" owner:self options:nil];
    if (arr.count > 0) {
        self = [arr objectAtIndex:0];
    }
    if (self) {
        self.imagV.image = image;
        self.Name.text = title;
        self.Name.textColor = Colol_lableft;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
