//
//  DailyCheckViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-4.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "User.h"
#import "HDScrollview.h"
#import "YFJLeftSwipeDeleteTableView.h"
#import "Xuser.h"
#import "NavigationViewController.h"
#import "AboutCheckmeViewController.h"

@interface DailyCheckViewController : UIViewController<UIScrollViewDelegate,HDScrollviewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain) HDScrollview *chartScrollView;
@property (nonatomic,retain) User *curUser;
@property(nonatomic,retain) YFJLeftSwipeDeleteTableView *tableView;

//Xuser
@property (nonatomic, strong) Xuser *curXuser;

- (IBAction)showLeftMenu:(id)sender;
- (IBAction)segmentChanged:(id)sender;
@end
