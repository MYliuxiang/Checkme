//
//  ShareAlert.m
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "ShareAlert.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@implementation ShareAlert

//- (instancetype)initWithTitle:(NSString *)title
//                     Btntitle:(NSString *)btntitle
//                       inview:(UIView *)view
//{
//    self = [super init];
//    if (self) {
//        self  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
//        
//        self.width = kScreenWidth - 80;
//        self.center = [self topView].center;
//        
//        
//    }
//    return self;
//    
//}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
        
        self.width = kScreenWidth - 60;
        self.center = [self topView].center;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.sharebtn.layer.cornerRadius = 3;
    self.sharebtn.layer.masksToBounds = YES;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
   
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    self.bottom = keyboardBounds.origin.y - 10;
     [UIView commitAnimations];
    
}

- (void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.center = [self topView].center;
    
    // commit animations
    [UIView commitAnimations];
    
}

- (void)show {
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [_maskView addGestureRecognizer:tap];
    [[self topView] addSubview:_maskView];
    [[self topView] addSubview:self];
    
    self.center = [self topView].center;
    [self showAnimation];
    
}

- (void)tap{

    [self dismiss];
}

- (void)dismiss
{
    
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
    [self hideAnimation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}


- (void)showAnimation {
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration             = 1;
    popAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.0)],
                                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                                          [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes             = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions      = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:popAnimation forKey:nil];
}

- (void)hideAnimation{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
    
}

-(UIView*)topView{
    UIWindow *window = [AppDelegate GetAppDelegate].window;
    window.userInteractionEnabled = YES;
    return  window.subviews[0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        
        [self endEditing:YES];
        
    }
    return YES;
    
}

- (IBAction)shareAC:(id)sender {
    
    if(self.textField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please enter a cloud accout!", nil)];
        return;
    
    }
    
    [self.delegate shareText:self.textField.text];
    [self dismiss];
}
@end
