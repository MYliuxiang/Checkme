//
//  ListsViewController.h
//  IOS_Minimotor
//
//  Created by 李江 on 15/11/15.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCommunication.h"
@protocol ListsViewControllerDelegate

- (void)gotoVC;

@end
@interface ListsViewController : UIViewController<BTCommunicationPlayMoviceDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray *noticeArray;

@property (nonatomic,assign)id<ListsViewControllerDelegate>ListsVCdelegate;

@end
