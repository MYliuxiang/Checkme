//
//  AboutCheckmeViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"

//#define URL_GET_LANGUAGE_LIST (@"http://119.29.77.15:8089/CheckmeUpdate/LanguageListServlet")
#define URL_GET_LANGUAGE_LIST (@"https://api.viatomtech.com.cn/update/bodimetrics/aa")


@interface AboutCheckmeViewController : UIViewController

@property(nonatomic,retain) IBOutlet UIImageView* ivState;
@property(nonatomic,retain) IBOutlet UILabel* lblSeries;
@property(nonatomic,retain) IBOutlet UILabel* lblVersion;
@property(nonatomic,retain) IBOutlet UILabel* lblSN;
@property(nonatomic,retain) IBOutlet UIButton* bnUpdate;
@property (nonatomic,retain) NSDictionary *json;

//左侧的按钮  点击实现 抽屉效果

-(IBAction)showLeftMenu:(id)sender;

//设备升级 (Update 按钮)
-(IBAction)onBnUpdateClicked:(id)sender;
@end
