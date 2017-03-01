//
//  SPO2ViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "User.h"

#import "YFJLeftSwipeDeleteTableView.h"

@interface SPO2ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain) YFJLeftSwipeDeleteTableView* spo2Table;

-(IBAction)showLeftMenu:(id)sender;
@end
