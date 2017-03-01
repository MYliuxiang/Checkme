//
//  StartReadAckPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/21.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicUtils.h"
#import "TypesDef.h"

@interface StartReadAckPkg : NSObject

- (instancetype)initWithBuf:(NSData*)buf;

@property(nonatomic,assign) int cmdWord;
//@property(nonatomic,assign) int errCode;
@property(nonatomic,assign) U32 fileSize;

@end
