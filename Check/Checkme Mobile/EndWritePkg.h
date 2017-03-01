//
//  EndWritePkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/22.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EndWritePkg : NSObject

@property(nonatomic,strong)NSData* buf;
- (instancetype)initWithCmd:(int)cmd;

@end
