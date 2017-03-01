//
//  ECGWave.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-7.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Xuser.h"
#import "SpotCheckItem.h"

@protocol EcgWaveViewDelegate<NSObject>

-(void)didChoiceWaveDuringStart:(double)startSecond end:(double)endSecond;
//-(void)willPlayVoice;

@end

@interface ECGWave : UIView

-(id)initWithFrame:(CGRect)frame user:(User *)aUser ecgItem:(ECGInfoItem *)aItem callerType:(int)type delegate:(id<EcgWaveViewDelegate>)del;
-(id)initWithFrame:(CGRect)frame xUser:(Xuser *)xUser spcItem:(SpotCheckItem *)spcItem callerType:(int)type delegate:(id<EcgWaveViewDelegate>)del;

-(void)showVoiceBtn;
-(void)hideVoiceBtn;
-(void)showUserName;
-(void)hideUserName;
@end
