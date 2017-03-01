//
//  PlayMovieViewController.h
//  IOS_Minimotor
//
//  Created by 李江 on 15/11/15.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveInfo.h"
#import "BTCommunication.h"
@protocol PlayMovieViewControllerDelegate

- (void)gotoVC;

@end
@interface PlayMovieViewController : UIViewController<BTCommunicationPlayMoviceDelegate>

@property (nonatomic,strong)Notice *notice;

@property (nonatomic,assign)id<PlayMovieViewControllerDelegate>PlayMovieVCDelegate;

@end
