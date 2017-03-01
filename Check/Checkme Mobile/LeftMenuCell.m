//
//  LeftMenuCell.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-9.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithImgName:(NSString*)imgName andText:(NSString*) text
{
    NSArray *arr;
    arr = [[NSBundle mainBundle] loadNibNamed:@"LeftMenuCell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];
    if(self){
        _imgView.image = [UIImage imageNamed:imgName];
        _lbl.textColor = Colol_lableft;
        _lbl.text = text;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

+(NSString *)cellReuseId
{
    return @"cellReuseId_LeftMenuCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
