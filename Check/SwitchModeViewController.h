//
//  SwitchModeViewController.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/31.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)
#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))
@interface SwitchModeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) BOOL isSwitchDevice;
@property (nonatomic) BOOL isSwitchUser;
@end


