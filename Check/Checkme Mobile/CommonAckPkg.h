//
//  CommonAckPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonAckPkg : NSObject

@property(nonatomic,assign) int cmdWord;
//@property(nonatomic,assign) int errCode;

- (instancetype)initWithBuf:(NSData*)buf;

@end
