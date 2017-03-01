//
//  RelaxMeViewController.h
//  Checkme Mobile
//
//  Created by Viatom on 15/8/10.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "User.h"
#import "YFJLeftSwipeDeleteTableView.h"
@interface RelaxMeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) YFJLeftSwipeDeleteTableView* relaxmeTable;

- (IBAction)showLeftMenu:(id)sender;

@end
