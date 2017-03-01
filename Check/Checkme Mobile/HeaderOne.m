//
//  HeaderOne.m
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "HeaderOne.h"

@implementation HeaderOne

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
    
    self.nameBtn.layer.cornerRadius = 3;
    self.nameBtn.layer.masksToBounds = YES;
    
    self.singOutBtn.layer.cornerRadius = 3;
    self.singOutBtn.layer.masksToBounds = YES;
    
    self.mBtn.layer.cornerRadius = 3;
    self.mBtn.layer.masksToBounds = YES;
    
    self.broBtn.layer.cornerRadius = 3;
    self.broBtn.layer.masksToBounds = YES;
    
    self.nameLabel.text = [NSString stringWithFormat:@"Hi %@",[UserDefault objectForKey:NAME]];
    self.mBtn.enabled = NO;
    self.mBtn.backgroundColor = [UIColor lightGrayColor];
    [self.swi setOn:[UserDefault boolForKey:Auto]];
    
    if (![UserDefault boolForKey:Auto]) {
        
        self.mBtn.enabled = YES;
        self.mBtn.backgroundColor = [UIColor colorWithRed:27 / 255.0 green:138/255.0 blue:205/255.0 alpha:1];
    }
    
}

- (IBAction)singOutAC:(id)sender {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:ISLOGIN];
    [userDefault synchronize];
    [[CloudUpLodaManger sharedManager] noticeUpdata];
    [CloudModel clearTable];
    
    [self.delegate signOut];
    
}

- (IBAction)mauanlAC:(id)sender {
    
    [UserDefault setBool:YES forKey:Suto];
    [UserDefault synchronize];
    
    [[CloudUpLodaManger sharedManager] noticeUpdata];

}
- (IBAction)broAC:(id)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.bodimetrics.com"]];
}

- (IBAction)switchAC:(UISwitch *)sender {
    
    if (sender.on) {
    //打开
        self.mBtn.enabled = NO;
        self.mBtn.backgroundColor = [UIColor lightGrayColor];
        [UserDefault setBool:YES forKey:Auto];
        [UserDefault synchronize];
        [[CloudUpLodaManger sharedManager] noticeUpdata];

        
    }else{
        
    //关闭
        self.mBtn.enabled = YES;
        self.mBtn.backgroundColor = [UIColor colorWithRed:27 / 255.0 green:138/255.0 blue:205/255.0 alpha:1];
        [UserDefault setBool:NO forKey:Auto];
        [UserDefault synchronize];
        
    }

}
@end
