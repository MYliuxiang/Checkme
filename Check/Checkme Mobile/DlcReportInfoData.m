//
//  ReportInfoData.m
//  Checkme Mobile
//
//  Created by Lq on 14-12-29.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "DlcReportInfoData.h"
#import "AlbumHeader.h"

@interface DlcReportInfoData ()

@end

@implementation DlcReportInfoData

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.bounds = CGRectMake(0, 0, wave_width, self.frame.size.height);
    
    [self drawHorizontalLines];
}

//画矩形框
//使用贝塞尔曲线来进行图形的绘制
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

// 画横线
- (void) drawHorizontalLines
{
    self.usrName = [[UILabel alloc] init];
    self.usrName.frame = CGRectMake(self.Name.frame.origin.x, CGRectGetMaxY(self.Name.frame), CGRectGetWidth(self.Name.frame), 1);
    self.usrName.backgroundColor = [UIColor blackColor];
    [self addSubview:self.usrName];

    self.usrGender = [[UILabel alloc] init];
    self.usrGender.frame = CGRectMake(self.Gender.frame.origin.x, CGRectGetMaxY(self.Gender.frame), CGRectGetWidth(self.Gender.frame), 1);
    self.usrGender.backgroundColor = [UIColor blackColor];
    [self.Gender.superview addSubview:self.usrGender];
    
    self.usrDateBirth = [[UILabel alloc] init];
    self.usrDateBirth.frame = CGRectMake(self.DateBirth.frame.origin.x, CGRectGetMaxY(self.DateBirth.frame), CGRectGetWidth(self.DateBirth.frame), 1);
    self.usrDateBirth.backgroundColor = [UIColor blackColor];
    [self addSubview:self.usrDateBirth];
}

- (void) drawRect:(CGRect)rect
{
    [self drawRectangle];
}


@end
