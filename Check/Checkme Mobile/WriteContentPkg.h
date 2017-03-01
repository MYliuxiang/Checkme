//
//  WriteContentPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDefines.h"

@interface WriteContentPkg : NSObject

@property(nonatomic,strong) NSData* buf;

- (instancetype)initWithBuf:(NSData*)inBuf pkgNum:(int)pkgNum cmd:(int)cmd;

@end
