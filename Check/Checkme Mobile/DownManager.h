//
//  DownView.h
//  Checkme Mobile
//
//  Created by Viatom on 16/7/29.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCommunication.h"
#import "FileUtils.h"
#import "UserList.h"
#import "AppDelegate.h"
#import "FileParser.h"
#import "NSDate+Additional.h"

@protocol DownManagerDelegate<NSObject>

- (void)count:(int)total;
- (void)countFail;
- (void)loadDatailOne;
- (void)loadSugrecess;
- (void)progress:(float)progress;
@end

@interface DownManager : NSObject<BTCommunicationDelegate,ECGInfoItemDelegate,DailyCheckItemDelegate,SLMItemDelegate,spotCheckItemDelegate>
{
    NSString *curDirName; //编号蓝牙
    BOOL isSpc;
    int dlcint;
}

@property (nonatomic, strong) UserList            *userList;
@property (nonatomic, strong) Xuser               *curXuser;
@property (nonatomic,retain ) User                *curUser;
@property (nonatomic,retain ) ECGInfoItem         *downECG;
@property (nonatomic,retain ) SpotCheckItem       *downSPOT;
@property (nonatomic,retain ) DailyCheckItem      *downDAIL;
@property (nonatomic,retain ) SLMItem             *downSLM;
@property (nonatomic,assign ) int                 userCount;
@property (nonatomic,assign ) int                 uIndex;
@property (nonatomic,assign ) BOOL                isjs;
@property (nonatomic,retain ) NSMutableArray      *slmArr;
@property (nonatomic,assign ) id<DownManagerDelegate> mdelegate;
@property (nonatomic,assign ) BOOL                isDetail;

+ (DownManager *)sharedManager;
- (void)loadToal;
- (void)loadData;

@end















