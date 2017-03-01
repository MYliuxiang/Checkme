//
//  PedCell.m
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "PedCell.h"
#import "AppDelegate.h"
#import "PublicMethods.h"
#import "NSDate+Additional.h"
#import "FileParser.h"
#import "Colors.h"

@interface PedCell()
@property (nonatomic,retain) PedInfoItem *curPedItem;
@property (nonatomic,retain) User *curUser;
@property (nonatomic,assign) UIViewController *fatherVC;
@end

@implementation PedCell

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
    arr = [[NSBundle mainBundle] loadNibNamed:@"PedCell" owner:self options:nil];
    if(arr.count > 0)
        self = [arr objectAtIndex:0];

    if(self){
    }
    return self;
}

+(NSString *)cellReuseId
{
    return @"cellReuseId_PedCell";
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPropertyWithUser:(User *)user infoItem:(PedInfoItem *)infoItem fatherViewController:(UIViewController *)fatherVC
{
    
    self.contentView.backgroundColor = Colol_cellbg;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _curPedItem = infoItem;
    _curUser = user;
    _fatherVC = fatherVC;
    
    [self refreshCellView];
}

-(void)refreshCellView
{
    //summary
    _time.text = [NSDate engDescOfDateComp:_curPedItem.dtcMeasureTime][1];
    _date.text = [NSDate engDescOfDateComp:_curPedItem.dtcMeasureTime][0];
    _step.text = INT_TO_STRING(_curPedItem.step);
    _stepLab.text = DTLocalizedString(@"steps", nil);
    
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud setInteger:1 forKey:@"Unit"];
//    [ud synchronize];

    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"Unit"];
    if (!index) {
        index = 0;
    }
    if (index == 0) {
        _distance.text = DOUBLE2_TO_STRING(_curPedItem.distance);
        _disUnit.text = @"km";
        
        _speed.text = DOUBLE_TO_STRING(_curPedItem.speed);
        _speedUnit.text = @"km/h";
        _fat.text = DOUBLE2_TO_STRING(_curPedItem.fat);
        _fatUnit.text = @"g";
    }else if (index == 1) {
        _distance.text = DOUBLE2_TO_STRING((_curPedItem.distance) / 1.61 ); //0.621371
        _disUnit.text = @"mi";

        _speed.text = DOUBLE_TO_STRING((_curPedItem.speed) / 1.61); //0.621371
        _speedUnit.text = @"mi/h";
        _fat.text = DOUBLE2_TO_STRING((_curPedItem.fat) / 28.35); //0.035274
        _fatUnit.text = @"oz";
    }
    
//    _distance.text = DOUBLE2_TO_STRING((_curPedItem.distance) / 1.61 ); //0.621371
//    _disUnit.text = @"mi";
//    
//    _speed.text = DOUBLE_TO_STRING((_curPedItem.speed) / 1.61); //0.621371
//    _speedUnit.text = @"mi/h";
//    _fat.text = DOUBLE2_TO_STRING((_curPedItem.fat) / 28.35); //0.035274
//    _fatUnit.text = @"oz";
//
    //detail
    _calorie.text = DOUBLE2_TO_STRING(_curPedItem.calorie);
    
    //总时间
    int gap = _curPedItem.totalTime;
    int h = gap/3600;
    int m = (gap - h*3600)/60;
    int s = gap - m*60 - h*3600;
    if (h==0) {
         _totalTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dm%ds", nil),m,s];
    }else {
        _totalTime.text = [NSString stringWithFormat:DTLocalizedString(@"%dh%dm%ds", nil),h,m,s];
    }
}

//重写layoutSubviews方法。。。
- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if (_calorie.hidden == NO) {
//        CGRect calorieRect = [_calorie.text boundingRectWithSize:size(CUR_SCREEN_W, CUR_SCREEN_H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font(18)} context:nil];
//        _calorie.font = font(18);
//        _calorie.backgroundColor = [UIColor redColor];
//        _calorie.frame = rect(CGRectGetMaxX(_imgCalorie.frame)+2, _calorie.frame.origin.y, calorieRect.size.width, calorieRect.size.height);
//        _calorieUnit.frame = rect(CGRectGetMaxX(_calorie.frame)+2, _calorieUnit.frame.origin.y, _calorieUnit.bounds.size.width, _calorieUnit.bounds.size.height);
//        _calorieUnit.font = font(18);
//    }
}

-(void)doOnExpanded
{
    [_calorie setHidden:NO];
    [_fat setHidden:NO];
    [_speed setHidden:NO];
    [_totalTime setHidden:NO];
    [_calorieUnit setHidden:NO];
    [_fatUnit setHidden:NO];
    [_speedUnit setHidden:NO];
    [_imgCalorie setHidden:NO];
    [_imgFat setHidden:NO];
    [_imgSpeed setHidden:NO];
    [_imgTotalTime setHidden:NO];
    [_itemImgResultLong setHidden:NO];
    [_imgSeperator setHidden:NO];
    [_itemImgResultShort setHidden:YES];//隐藏这个,其他的都不隐藏
    
}

-(void)doOnCollapsed
{
    [_calorie setHidden:YES];
    [_fat setHidden:YES];
    [_speed setHidden:YES];
    [_totalTime setHidden:YES];
    [_calorieUnit setHidden:YES];
    [_fatUnit setHidden:YES];
    [_speedUnit setHidden:YES];
    [_imgCalorie setHidden:YES];
    [_imgFat setHidden:YES];
    [_imgSpeed setHidden:YES];
    [_imgTotalTime setHidden:YES];
    [_itemImgResultLong setHidden:YES];
    [_imgSeperator setHidden:YES];
    [_itemImgResultShort setHidden:NO]; //其他的都隐藏,这个不隐藏
}

@end
