//
//  LXDownView.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/5.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownManager.h"

@protocol LXAlertDelege<NSObject>

- (void)dismisLoad;

@end


@interface LXDownView : UIView<DownManagerDelegate>
{
    UIView *_maskView;
    
}

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic,assign)id<LXAlertDelege> delegate;
@property (nonatomic,assign)int current;
@property (nonatomic,assign)float totalCount;
@property (nonatomic,retain)DownManager *downManger;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progresslayout;
@property (nonatomic,retain) UIView *view;
@property (nonatomic,assign) float progress;

- (IBAction)cancleAC:(id)sender;

- (instancetype)initWithTitle:(NSString *)title
                     Btntitle:(NSString *)btntitle
                       inview:(UIView *)view;

- (void)show;
- (void)dismiss;

@end
