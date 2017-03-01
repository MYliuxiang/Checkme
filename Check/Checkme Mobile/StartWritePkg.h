//
//  StartWritePkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDefines.h"
#import "PublicUtils.h"
#import "TypesDef.h"

@interface StartWritePkg : NSObject

@property(nonatomic,strong) NSData* buf;

- (instancetype)initWithFileName:(NSString*)fileName fileSize:(U32)size cmd:(int)cmd;

@end
