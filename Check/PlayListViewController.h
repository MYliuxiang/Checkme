//
//  PlayListViewController.h
//  IOS_Minimotor
//
//  Created by lijiang on 15/10/29.
//  Copyright © 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveInfo.h"
#import "BTCommunication.h"
#import "LJListTabView.h"
@interface PlayListViewController : UIViewController<BTCommunicationPlayMoviceDelegate,LJListPlayDelegate>

@property (nonatomic,strong)NSArray *noticeArray;
@property (nonatomic,strong)LJListTabView *palyListtableView;

@end
