//
//  ReadContentPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicUtils.h"

@interface ReadContentPkg : NSObject

@property(nonatomic,strong) NSData* buf;

- (instancetype)initWithPkgNum:(U32)pkgNum;

@end
