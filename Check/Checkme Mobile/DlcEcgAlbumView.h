//
//  DlcEcgAlbumView.h
//  Checkme Mobile
//
//  Created by Lq on 14-12-29.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Xuser.h"
#import "SpotCheckItem.h"
#import "BPCheckItem.h"
@interface DlcEcgAlbumView : UIView

//初始化frame
- (id) initWithFrame:(CGRect)frame andUser:(User *)user andEcgInfoItem:(ECGInfoItem *)ecgInfoItem andWaveType:(NSString *)waveType andBPType:(NSArray *)bpArr;
- (id) initWithFrame:(CGRect)frame andXuser:(Xuser *)xUser andSpcInfoItem:(SpotCheckItem *)spcInfoItem andWaveType:(NSString *)waveType;
@end
