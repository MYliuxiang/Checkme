//
//  CheckmeUpdateViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckmeInfo.h"
#import "BTCommunication.h"

//#define URL_GET_PATCHS (@"http://119.29.77.15:8089/CheckmeUpdate/GetPatchsServlet")
#define URL_GET_PATCHS (@"https://api.viatomtech.com.cn/update/bodimetrics/aa")

@interface CheckmeUpdateViewController : UIViewController <BTCommunicationDelegate>

@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property (strong, nonatomic)  UILabel *progressLabel;
@property(nonatomic,retain) CheckmeInfo* checkmeInfo;
@property(nonatomic,retain) NSString* wantLanguage;
@property (nonatomic,retain) NSDictionary *json;


//   下载及更新时提示
@property (nonatomic, strong) UILabel *HUDlabel;//下载 及 更新 提示
@end
