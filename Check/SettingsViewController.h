//
//  SettingsViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "CheckmeInfo.h"

@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UILabel *snlabel;

}
@property(nonatomic,retain)CheckmeInfo *checkmeInfo;
@property(nonatomic,copy) NSString *sn;
@property(nonatomic,retain) IBOutlet UITableView* tableView;
-(IBAction)showLeftMenu:(id)sender;


@end
