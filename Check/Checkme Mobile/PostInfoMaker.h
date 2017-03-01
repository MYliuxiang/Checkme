//
//  PostInfoMaker.h
//  Checkme Mobile
//
//  Created by Joe on 14/11/12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckmeInfo.h"

@interface PostInfoMaker : NSObject

+(NSString *)makeGetLanguageListInfo:(CheckmeInfo*) checkmeInfo;  //语言列表
+(NSString *)makeGetPatchsInfo:(CheckmeInfo*) checkmeInfo WantLanguage:(NSString*) wantLanguage;
@end
