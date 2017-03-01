//
//  CloudUpLodaManger.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/11.
//  Copyright © 2016年 VIATOM. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NetWorkManager.h"
@interface CloudUpLodaManger : UIView<NetWorkManagerDelegate>

@property (nonatomic,assign) int            current;
@property (nonatomic,assign) int            total;
@property (nonatomic,retain) UILabel        *countLabel;
@property (nonatomic,assign) BOOL           isUpload;
@property (nonatomic,retain) UILabel        *stateLabel;
@property (nonatomic,retain) UILabel        *nameLabel;
@property (nonatomic,retain) UIImageView    *gifImageView;
@property (nonatomic,strong) NetWorkManager *networkManager;

+ (CloudUpLodaManger *)sharedManager;

- (void)noticeUpdata;
- (void)uplodauto;

@end
