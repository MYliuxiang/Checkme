//
//  UIImage+Additional.m
//  hipal
//
//  Created by demo on 13-7-16.
//
//

#import "UIImage+Additional.h"

@implementation  UIImage (Additional)


-(UIImage *)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    //BodiMetrics_IOS_1.0.0   BodiMetrics_IOS_1.2.0  项目版本命名
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}


- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);//获取图片的宽度
    CGFloat height = CGImageGetHeight(self.CGImage); //获取图片的高度
    
	CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
