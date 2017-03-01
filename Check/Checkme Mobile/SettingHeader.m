//
//  SettingHeader.m
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "SettingHeader.h"
#import "SVProgressHUD.h"

@implementation SettingHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];

    }
    return self;
}

- (void)awakeFromNib
{
    self.loginBtn.layer.cornerRadius = 3;
    self.loginBtn.layer.masksToBounds = YES;
    
    self.brwBtn.layer.cornerRadius = 3;
    self.brwBtn.layer.masksToBounds = YES;

    self.usenameField.leftView = self.view0;
    self.usenameField.leftViewMode = UITextFieldViewModeAlways;
    
    self.passwordField.leftView = self.view1;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *email = [userDefault objectForKey:EMAIL];
    NSString *password = [userDefault objectForKey:Password];
    
    if (email != nil) {
        self.usenameField.text = email;
    }
    
//    if (password != nil) {
//        self.passwordField.text = password;
//    }

}

#pragma mark -------UITextField ---------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        
        [self endEditing:YES];
    }
    return YES;
    
}

- (IBAction)LoginAC:(id)sender {
    
    if(self.usenameField.text.length == 0){
        
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please enter an email.", nil)];
        return;
        
    }
    
    if (self.passwordField.text.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please enter password.", nil)];

        return;
    }
    
        [WXDataService postLoginParams:@{@"email":self.usenameField.text,@"password":self.passwordField.text} finishBlock:^(id result) {
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:self.usenameField.text forKey:EMAIL];
            [userDefault setObject:self.passwordField.text forKey:Password];
            [userDefault setObject:result[@"name"] forKey:NAME];
            [userDefault setBool:YES forKey:ISLOGIN];
            [userDefault setBool:YES forKey:Auto];

            [userDefault synchronize];
            [userDefault objectForKey:ISLOGIN];
            [self.delegate sugress];
            [[CloudUpLodaManger sharedManager] noticeUpdata];
        } errorBlock:^(NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Sign in failed!",  nil) ];
            
        }];
 
}

- (IBAction)colundAC:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.bodimetrics.com/register"]];

}

- (IBAction)brwAC:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.bodimetrics.com"]];

}
@end
