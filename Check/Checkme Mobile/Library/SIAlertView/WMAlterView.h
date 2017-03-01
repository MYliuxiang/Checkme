//
//  WMAlterView.h
//  AlterView
//
//  Created by Xiao_Erge on 15/6/28.
//  Copyright (c) 2015年 Xiao_Erge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
typedef  void(^ ConflimBlocks)(NSString *textfileString);


@interface WMAlterView : UIView
@property (nonatomic, strong) UIButton      * cancelButton;//取消按钮
@property (nonatomic, strong) UIButton      * confirmButton;//确认按钮
@property (nonatomic, strong) UITextField      * textFiled;//输入内容
@property (nonatomic, strong) UILabel       * alterTitle;//提示框标题
@property (nonatomic, copy  ) ConflimBlocks conflimBlock;//确认

@end
