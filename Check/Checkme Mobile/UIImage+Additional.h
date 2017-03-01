//
//  UIImage+Additional.h
//  hipal
//
//  Created by demo on 13-7-16.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Additional)
-(UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;
@end
