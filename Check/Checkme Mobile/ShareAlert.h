//
//  ShareAlert.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/18.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareAlertDelege<NSObject>

- (void)shareText:(NSString *)text;

@end


@interface ShareAlert : UIView<UITextFieldDelegate>
{
    UIView *_maskView;
    
}
- (IBAction)shareAC:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *sharebtn;
@property (nonatomic,assign)id<ShareAlertDelege> delegate;
- (void)show;
- (void)dismiss;


@end
