//
//  NSDate+Additional.h
//  DeliveryMS
//
//  Created by demo on 13-5-31.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_FORMATTER_1 @"yy-mm-dd HH:mm:ss"   //设置日期格式(定义宏)

@interface NSDate (Additional)

//两个日期分钟差值
+ (NSInteger)minutesIntervalBetweenDateComponent1:(NSDateComponents*)c1 component2:(NSDateComponents*)c2;

//秒表
+ (NSString *)descriptionOfMinutes:(NSInteger)minutes;



+ (int)howmanyDaysOfYear:(int)year month:(int)month;//年、月

+ (NSInteger) weekDayOfDate:(NSDate *)date; //日期


//年月日转化为date类型
+ (NSDate *)dateFromYear:(int)year month:(int)month day:(int)day;

+ (NSDate *)dateFromString:(NSString *)dateStr formatterStr:(NSString *)formatter;


//年月日转化成字符串
+ (NSString *)dateDescFromDateComp:(NSDateComponents *)comp;
+(NSString*)dateDescFromDate:(NSDate *)date;

+ (NSString *)weekNameOfYear:(int)year month:(int)month day:(int)day;

+ (NSString *)stringFromDate:(NSDate *)date formatterStr:(NSString *)formatter;

+ (NSString *) timeDescFromDateComp:(NSDateComponents *)comp;



+ (NSDateComponents *)dateCompFromToday;

+ (NSDateComponents *)dateCompFromDate:(NSDate *)date;

+ (NSDateComponents *)dateCompFromString:(NSString *)dateStr;

+ (NSDateComponents *)dateCompOfNow;

+ (NSDateComponents *)timeCompFromSeconds:(long) seconds;

+ (NSDate *)dateFromDateComp:(NSDateComponents*)dateComp;

//返回不同国家的日期描述法          如英语："10:35pm" + "12-jul-2013" +  "10:35pm,12-jul-2013"
+(NSArray *)engDescOfDateComp:(NSDateComponents *)dtc;

//同上，由于数据存储原因，特加此方法 关于数据存储的都用此方法
+ (NSArray *)engDescOfDateCompForDataSaveWith:(NSDateComponents *)dtc;
@end