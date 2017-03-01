//
//  StartReadPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDefines.h"

@interface StartReadPkg : NSObject

@property(nonatomic,strong) NSData* buf;

- (instancetype)initWithFileName:(NSString*)fileName;

@end
