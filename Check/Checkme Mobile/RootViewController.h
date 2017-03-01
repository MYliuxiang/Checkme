//
//  RootViewController.h
//  Checkme Mobile
//
//  Created by Joe on 14-8-5.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "FileParser.h"
#import "MiniMonitorViewController.h"

#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)

#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))
@interface RootViewController : UIViewController<UIActionSheetDelegate>

/** logo图标*/
@property(nonatomic,retain) IBOutlet UIImageView* imgLogo;

@property (nonatomic, strong) MMDrawerController *mmDrawer;



@end
