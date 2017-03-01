//
//  UIImage+compress.h
//  Checkme Mobile
//
//  Created by Lq on 14-12-12.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (compress)

-(UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
