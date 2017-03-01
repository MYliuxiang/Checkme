//
//  UserItem.m
//  Checkme Mobile
//
//  Created by Viatom on 16/11/25.
//  Copyright © 2016年 VIATOM. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem



@synthesize ID = _ID;
@synthesize ICO_ID = _ICO_ID;
@synthesize dtcBirthday = _dtcBirthday;
@synthesize headIcon = _headIcon;
@synthesize weight = _weight;
@synthesize height = _height;
@synthesize name = _name;
@synthesize gender = _gender;
@synthesize medical_id = _medical_id;

-(id)init
{
    self = [super init];
    if(self){
        
        //_innerData = [[ECGInfoItem_InnerData alloc] init];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.ID forKey:@"ID"];
    [aCoder encodeInteger:self.ICO_ID forKey:@"ICO_ID"];
    [aCoder encodeObject:self.dtcBirthday forKey:@"dtcBirthday"];
    [aCoder encodeObject:self.headIcon forKey:@"headIcon"];
    [aCoder encodeDouble:self.weight forKey:@"weight"];
    [aCoder encodeDouble:self.height forKey:@"height"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.age forKey:@"age"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.medical_id forKey:@"medical_id"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.ID = [aDecoder decodeIntForKey:@"ID"];
        self.ICO_ID = [aDecoder decodeIntForKey:@"ICO_ID"];
        self.dtcBirthday = [aDecoder decodeObjectForKey:@"dtcBirthday"];
        self.headIcon = [aDecoder decodeObjectForKey:@"headIcon"];
        self.weight = [aDecoder decodeDoubleForKey:@"weight"];
        self.height = [aDecoder decodeDoubleForKey:@"height"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
        self.gender = [aDecoder decodeIntForKey:@"gender"];
        self.medical_id = [aDecoder decodeObjectForKey:@"medical_id"];

    }
    return self;
}


@end
