//
//  RelaxMeCell.m
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "RelaxMeCell.h"
#import "AppDelegate.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "Colors.h"

@interface RelaxMeCell()

@property (nonatomic,retain) RelaxMeItem *relaxMeItem;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;

@end


@implementation RelaxMeCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init
{
    NSArray *arr;
    arr = [[NSBundle mainBundle] loadNibNamed:@"RelaxMeCell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];
    
    if(self){
    }
    return self;
}

+(NSString *)cellReuseId
{
    return @"cellReuseId_RelaxMeCell";
}
- (void)awakeFromNib {
    // Initialization code
    self.index.text = DTLocalizedString(@"Relaxation Index", nil);
    self.duration.text = DTLocalizedString(@"Duration", nil);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setPropertyWithUser:(User *)user infoItem:(RelaxMeItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _relaxMeItem = infoItem;
    _curUser = user;
    _fatherVC = fatherVC;
    [self refreshCellView];
    
}

- (void)refreshCellView
{
    
    _labletime.text = [NSDate engDescOfDateComp:_relaxMeItem.dtcDate][1];
    _lableDate.text = [NSDate engDescOfDateComp:_relaxMeItem.dtcDate][0];
    _lableRelaxaction.text =  INT_TO_STRING_WITHOUT_ERR_NUM(_relaxMeItem.Relaxation);
    _hrvValue.text =  INT_TO_STRING_WITHOUT_ERR_NUM(_relaxMeItem.hrv);
    _lableDuration.text = INT_TO_STRING_WITHOUT_ERR_NUM(_relaxMeItem.timemiao);
    _relaxationLabel.text = DTLocalizedString(@"Relaxation Index", nil);
    if(_relaxMeItem.timemiao < 0)
    {
        _lableDuration.text = @"--";

    }
    
//    if (_relaxMeItem.Relaxation < 0 || _relaxMeItem.Relaxation > 100) {
//        
//        _lableRelaxaction.text = @"--";
//    }
//    else
//    {
//        _lableRelaxaction.text = [NSString stringWithFormat:@"%d",_relaxMeItem.Relaxation];
//    }

    
//    if (_relaxMeItem.timemiao < 0 ) {
//        
//         _lableDuration.text = @"--";
//    }
//    else8613471689193
//    {
//         _lableDuration.text = [NSString stringWithFormat:@"%d",_relaxMeItem.timemiao];
//    }
    
//    _itemImgResult.backgroundColor = _relaxMeItem.enPassKind == kPassKind_Pass ? ITEM_LEFT_BLUE : _relaxMeItem.enPassKind == kPassKind_Fail ? ORANGE : [UIColor clearColor];

}

@end
