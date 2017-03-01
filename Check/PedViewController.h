//
//  PedViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-9-10.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HVTableView.h"
#import "UIViewController+MMDrawerController.h"
#import "User.h"

@interface PedViewController : UIViewController<HVTableViewDelegate,HVTableViewDataSource>{
    
}

@property (nonatomic,retain) HVTableView* pedTable;

-(IBAction)showLeftMenu:(id)sender;

@end
