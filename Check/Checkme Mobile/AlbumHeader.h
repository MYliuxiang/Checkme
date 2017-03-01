//
//  AlbumHeader.h
//  Checkme Mobile
//
//  Created by Lq on 14-12-30.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#ifndef Checkme_Mobile_AlbumHeader_h
#define Checkme_Mobile_AlbumHeader_h

#endif


//   常量
#define A4_width 210   //  (mm)
#define A4_height 297  //  (mm)
#define mm_per_mV 10  // 1毫伏=10mm
#define mm_per_second 25 //25mm/s

//  自定义
#define point_per_mm 3.0    //  1mm对应的点数   (point)
#define seconds_leftToRight 7.0   //一行波形的秒数  (s)
#define thickLine 1.0   //   粗线
#define thinLine 0.5    //   细线

//  延伸
#define points_per_mV (mm_per_mV * point_per_mm)  //1mV对应的point点
#define wave_width ((mm_per_second * seconds_leftToRight) * point_per_mm)     //一行波形的宽度   (point)
#define whole_width (A4_width * point_per_mm)       //整屏的宽  (point)
#define whole_height (A4_height * point_per_mm)     //整屏的高  (point)
#define padding ((whole_width - wave_width) / 2)       //左右空白的宽度   (point)

