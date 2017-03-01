//
//  ReadContentAckPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicUtils.h"
#import "TypesDef.h"

@interface ReadContentAckPkg : NSObject

@property(nonatomic,retain) NSData* dataBuf;
@property(nonatomic,assign) U32 dataLength;
@property(nonatomic,assign) int cmdWord;
- (instancetype)initWithBuf:(NSData*)inBuf;

@end
