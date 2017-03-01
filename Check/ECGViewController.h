//
//  ECGViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-8.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "MONActivityIndicatorView.h"
#import "User.h"
#import "YFJLeftSwipeDeleteTableView.h"

@interface ECGViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) YFJLeftSwipeDeleteTableView* ecgTable;

-(IBAction)showLeftMenu:(id)sender;
@end
