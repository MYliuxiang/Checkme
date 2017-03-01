//
//  Notice.h
//  数据库STDb
//
//  Created by Viatom on 15/10/10.
//  Copyright © 2015年 YilingOranization. All rights reserved.
//

#import "STDbObject.h"
@interface Notice : STDbObject


@property(nonatomic,strong)NSString *StardateString;
@property(nonatomic,strong)NSString *EnddateString;
@property(nonatomic,strong)NSString *NameString;
@property(nonatomic,strong)NSString *PkID;
@property(nonatomic,strong)NSMutableArray *PkArray;
@property(nonatomic,strong)NSString *typeSting;

@property(nonatomic,strong)NSData *data;


@end
