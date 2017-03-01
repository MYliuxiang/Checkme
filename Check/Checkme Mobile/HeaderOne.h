//
//  HeaderOne.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderOneDelege<NSObject>

- (void)signOut;
@end

@interface HeaderOne : UIView
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIButton *singOutBtn;
- (IBAction)singOutAC:(id)sender;
- (IBAction)mauanlAC:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *swi;

@property (weak, nonatomic) IBOutlet UIButton *mBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,assign)id<HeaderOneDelege> delegate;
@property (weak, nonatomic) IBOutlet UIButton *broBtn;
- (IBAction)broAC:(id)sender;
- (IBAction)switchAC:(UISwitch *)sender;

@end
