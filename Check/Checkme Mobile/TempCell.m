//
//  TempCell.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "TempCell.h"
#import "AppDelegate.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "Colors.h"

@interface TempCell()
@property (nonatomic,retain) TempInfoItem *curTempItem;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;
@end

@implementation TempCell

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
    arr = [[NSBundle mainBundle] loadNibNamed:@"TempCell" owner:self options:nil];
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
    return @"cellReuseId_TempCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setPropertyWithUser:(User *)user infoItem:(TempInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.curTempItem = infoItem;
    self.curUser = user;
    self.fatherVC = fatherVC;
    
    [self refreshCellView];//刷新单元格的view视图
}

-(void)refreshCellView
{
    _time.text = [NSDate engDescOfDateComp:_curTempItem.dtcMeasureTime][1];
    _date.text = [NSDate engDescOfDateComp:_curTempItem.dtcMeasureTime][0];
//    _imgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curTempItem.enPassKind]];
//    _itemImgResult.backgroundColor = _curTempItem.enPassKind == kPassKind_Pass ? ITEM_LEFT_BLUE : _curTempItem.enPassKind == kPassKind_Fail ? ORANGE : [UIColor clearColor];
    //温度转换 摄氏度转华氏度  ℉
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Termometer"];
    if (!index) {
        index = 0;
    }
    if (index == 0) {
        _temp.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(_curTempItem.PTT_Value);
        _tempUnit.text = @"℃";
        
    } else if (index == 1){
//        double F = _curTempItem.PTT_Value * 1.8 + 32;
//        if (_curTempItem.PTT_Value == 0) {
//            F = 0;
//        }
//        _temp.text = DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(F);
//        _tempUnit.text = @"℉";
        
            double F = _curTempItem.PTT_Value *1.8 + 32 - 0.04;
            if (_curTempItem.PTT_Value == 0) {
                F = 0;
            }
            _temp.text = DOUBLE3_TO_STRING_WITHOUT_ERR_NUM(F);
            _tempUnit.text = @"℉";

    }
    
//    double F = _curTempItem.PTT_Value *1.8 + 32 - 0.04;
//    if (_curTempItem.PTT_Value == 0) {
//        F = 0;
//    }
//    _temp.text = DOUBLE3_TO_STRING_WITHOUT_ERR_NUM(F);
//    _tempUnit.text = @"℉";
    
//    double F = _curTempItem.PTT_Value *1.8 + 32 - 0.04;
//    if (_curTempItem.PTT_Value == 0) {
//        F = 0;
//    }
//    _temp.text = DOUBLE3_TO_STRING_WITHOUT_ERR_NUM(F);
//    _tempUnit.text = @"℉";
    
    
    //如果是物体温度，则笑脸改为显示温度计
    if (_curTempItem.measureMode == TEMP_MODE_HEAD) {
//        _imgResult.image = [UIImage imageNamed:[IMG_RESULT_ARRAY objectAtIndex:_curTempItem.enPassKind]];
        
        _imgResult.image = [UIImage imageNamed:@"temp_head.png"];
    }else if (_curTempItem.measureMode == TEMP_MODE_THING) {
        _imgResult.image = [UIImage imageNamed:@"temp_thing"];
    }
    
}


@end
