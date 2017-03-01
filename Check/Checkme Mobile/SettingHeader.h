//
//  SettingHeader.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ViewController.h"

@protocol SettingHeaderDelege<NSObject>

- (void)sugress;
@end


@interface SettingHeader : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *usenameField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *brwBtn;

- (IBAction)LoginAC:(id)sender;
- (IBAction)colundAC:(id)sender;

- (IBAction)brwAC:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *usernameImage;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImage;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view0;

@property (nonatomic,assign)id<SettingHeaderDelege> delegate;
@end
