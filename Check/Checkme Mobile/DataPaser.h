//
//  DataPaser.h
//  IOS_Minimotor
//
//  Created by 李 乾 on 15/5/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packge.h"
typedef void (^myBlock) (id obj);

@interface DataPaser : NSObject
+ (Packge *) paserMiniDataWithBuff:(NSData *)buff andType:(U8)type;
@end
