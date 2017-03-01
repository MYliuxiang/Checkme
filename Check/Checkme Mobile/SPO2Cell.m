//
//  SPO2Cell.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "SPO2Cell.h"
#import "AppDelegate.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "Colors.h"


@interface SPO2Cell()
@property (nonatomic,retain) SPO2InfoItem *curSPO2Item;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;
@end

@implementation SPO2Cell

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
    arr = [[NSBundle mainBundle] loadNibNamed:@"SPO2Cell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];
    if(self){
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

+(NSString *)cellReuseId
{
    return @"cellReuseId_SPO2Cell"; //这里返回的应该就是那个SPO2Cell.xib  中的那个xib文件的cell标识符吧
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPropertyWithUser:(User *)user infoItem:(SPO2InfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.curSPO2Item = infoItem;
    self.curUser = user;
    self.fatherVC = fatherVC;
    
    [self refreshCellView];
}

-(void)refreshCellView
{
    _imgResult.hidden = YES;
    
    //summary
    _time.text = [NSDate engDescOfDateComp:_curSPO2Item.dtcMeasureTime][1];
    _date.text = [NSDate engDescOfDateComp:_curSPO2Item.dtcMeasureTime][0];
//    _imgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curSPO2Item.enPassKind]];
//    _itemImgResult.backgroundColor = _curSPO2Item.enPassKind == kPassKind_Pass ? ITEM_LEFT_BLUE : _curSPO2Item.enPassKind == kPassKind_Fail ? ORANGE : [UIColor clearColor];
    _spo2.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curSPO2Item.SPO2_Value);
    _pr.text = INT_TO_STRING_WITHOUT_ERR_NUM(_curSPO2Item.PR);
//    _pi.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(_curSPO2Item.PI);
    
 }

@end
