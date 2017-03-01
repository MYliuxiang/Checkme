//
//  SPCReportInfoData.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/3/30.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "SPCReportInfoData.h"
#import "AlbumHeader.h"

@implementation SPCReportInfoData

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.bounds = CGRectMake(0, 0, wave_width, self.frame.size.height);
}

//画矩形框
- (void) drawRectangle
{
    CGPoint point1 = CGPointMake(1, 1);
    CGPoint point2 = CGPointMake(wave_width-2, point1.y);
    CGPoint point3 = CGPointMake(point2.x, self.bounds.size.height-2);
    CGPoint point4 = CGPointMake(point1.x, point3.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point1];
    
    [[UIColor blackColor] setStroke];
    path.lineWidth = thickLine;
    [path stroke];
}

- (void) drawRect:(CGRect)rect
{
    [self drawRectangle];
}

@end
