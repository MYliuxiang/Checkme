//
//  UserItem.h
//  Checkme Mobile
//
//  Created by Viatom on 16/11/25.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserItem : NSObject

@property (nonatomic,assign) unsigned char ID;
///  ID for icon
@property (nonatomic,assign) unsigned char ICO_ID;
@property (nonatomic,retain) NSDateComponents *dtcBirthday;
@property (nonatomic,retain) UIImage *headIcon;
@property (nonatomic,assign) double weight;
@property (nonatomic,assign) double height;
@property (nonatomic,copy)   NSString *name;
@property (nonatomic,assign) NSInteger age;
@property (nonatomic,assign) Gender_t gender;
@property (nonatomic,copy) NSString *medical_id;
@property (nonatomic,copy) NSString *str;


@end
