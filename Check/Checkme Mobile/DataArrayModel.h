//
//  DataArrayModel.h
//  IOS_Minimotor
//
//  Created by Viatom on 15/10/20.
//  Copyright © 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataArrayModel : NSObject

+ (DataArrayModel *)sharedInstance;

@property (nonatomic,strong)NSMutableArray *dataMutableArray;
@property(nonatomic,strong)NSString *StardateString;
@property(nonatomic,strong)NSString *EeddateString;
@property (nonatomic,assign)BOOL isluzhi;


@end
