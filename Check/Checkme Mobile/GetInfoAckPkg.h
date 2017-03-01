//
//  GetInfoAckPkg.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/11.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GetInfoAckPkg : NSObject

@property(nonatomic,assign) int cmdWord;
@property(nonatomic,retain) NSData* infoData;

- (instancetype)initWithBuf:(NSData*)buf;

@end
