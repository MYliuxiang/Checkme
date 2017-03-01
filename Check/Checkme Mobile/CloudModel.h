//
//  CloudModel.h
//  Checkme Mobile
//
//  Created by Viatom on 16/8/11.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudModel : JKDBModel

@property (nonatomic,copy  ) NSString *sn;
@property (nonatomic,copy  ) NSString  *macID;
@property (nonatomic,copy  ) NSString  *jsonStr;
@property (nonatomic,copy  ) NSString  *patinID;
@property (nonatomic,copy  ) NSString  *time;
@property (nonatomic,copy  ) NSString  *detedStr;
@property (nonatomic,assign) float    weight;
@property (nonatomic,assign) double    height;
@property (nonatomic,assign) double    stride;
@property (nonatomic,copy  ) NSString  *name;
@property (nonatomic,assign) NSInteger age;
@property (nonatomic,copy  ) NSString  *birthDate;
@property (nonatomic,assign) NSInteger sex;
@property (nonatomic,copy  ) NSString    *ISUpload;

@end
