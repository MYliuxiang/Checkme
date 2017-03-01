//
//  NoInfoViewUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14-8-18.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "NoInfoViewUtils.h"

@implementation NoInfoViewUtils

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#warning 当进入App应用程序时,当前若没有什么可以显示的数据时,界面就显示一个空的文件夹的样式即可...
//显示无内容画面
+(void)showNoInfoView:(UIViewController*) vc
{
    UIImage *image = [UIImage imageNamed:@"no_info"];  //一个空文件夹样式的图片
    CGRect bond = CGRectMake(vc.view.frame.size.width/2-image.size.width/2, vc.view.frame.size.height/2-image.size.height/2, image.size.width, image.size.height);
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:bond];
    imgView.image = image;
    [vc.view addSubview:imgView];//将图片添加到view视图上去
    
    bond = CGRectMake(0, bond.origin.y+bond.size.height+5, CUR_SCREEN_W, 30);//(x,y,width,height)
    UILabel* lbl = [[UILabel alloc]initWithFrame:bond];//初始化label控件
    lbl.textAlignment = NSTextAlignmentCenter;//文字内容居中靠齐
    lbl.textColor = [UIColor grayColor];//设置label标签文字颜色
    lbl.font = [UIFont boldSystemFontOfSize:30];//设置字体大小
    lbl.text = DTLocalizedString(@"No records :(", nil);
    
    if ([curLanguage isEqualToString:@"fr"] || [curLanguage isEqualToString:@"de"]) {//语言判断
        lbl.font = [UIFont boldSystemFontOfSize:20];;
    }
    [vc.view addSubview:lbl];
}

@end