//
//  GetUpDataTimePkg.h
//  Checkme Mobile
//
//  Created by Viatom on 2017/1/16.
//  Copyright © 2017年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetUpDataTimePkg : NSObject
@property(nonatomic,assign) int cmdWord;

- (instancetype)initWithBuf:(NSData*)buf;
@end
