//
//  FirstDownManger.h
//  Checkme Mobile
//
//  Created by Viatom on 16/7/28.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirstDownManger : NSObject
@property (nonatomic,retain)NSMutableArray *downedArray;

+ (FirstDownManger *)sharedManager;

@end












