//
//  UserList.h
//  BTHealth
//
//  Created by demo on 13-10-15.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Xuser.h"

@interface UserList : NSObject
/**
 *  singleton
 *
 *  @return return current instance
 */
+(UserList *)instance;

///  user list array contains the items which is the subclass of 'User'
@property (nonatomic,retain) NSMutableArray *arrUserList;

///  xUser list array contains the items which is the subclass of 'Xuser'
@property (nonatomic, retain) NSMutableArray *arrXuserList;

///  bool  ,  when current mode is hospital mode, the value is Yes, otherwise NO
@property (nonatomic) BOOL isSpotCheck;

@end
