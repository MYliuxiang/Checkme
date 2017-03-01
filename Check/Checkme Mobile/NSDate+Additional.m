//
//  NSDate+Additional.m
//  DeliveryMS
//
//  Created by demo on 13-5-31.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "NSDate+Additional.h"


@implementation NSDate (Additional)
+(NSDate *)dateFromYear:(int)year month:(int)month day:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];//日历、日期
    NSDateComponents *components = [[NSDateComponents alloc] init] ;
    
    [components setDay:day];
    
    if (month <= 0) { //月份判断   （当月份小于 0 ）
        [components setMonth:12-month];  //(这里这个处理是否有问题呀....month小于0 时是一个负数耶)
        [components setYear:year-1];
    } else if (month >= 13) {  // 当月份大于 13 月份时
        [components setMonth:month-12];
        [components setYear:year+1];
    } else {
        [components setMonth:month];
        [components setYear:year];
    }
    
    
    return [calendar dateFromComponents:components];
}
+(int) howmanyDaysOfYear:(int)year month:(int)month
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:[NSDate dateFromYear:year month:month day:1]];
#warning 修改了下 类型转换
   // return days.length;
    return (int)(days.length);
    
}
//时间日期的判断
+(NSString *)weekNameOfYear:(int)year month:(int)month day:(int)day
{
    NSDate *currDate = [NSDate dateFromYear:year month:month day:day];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit) fromDate:currDate];
    NSInteger weekday = [comps weekday];
    static char *weekDayArr[] = {"星期一", "星期二","星期三","星期四","星期五","星期六","星期日"};
    weekday = (weekday == 1)?7:weekday - 1;
    return [NSString stringWithUTF8String:weekDayArr[weekday-1]];
}

+ (NSInteger)weekDayOfDate:(NSDate *)date
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit) fromDate:date];
    NSInteger weekday = [comps weekday];
    return (weekday == 1) ? 7 : weekday - 1;//时间星期的判定
}

+(NSDateComponents *)dateCompFromToday
{
    NSDate *currDate = [NSDate date];
    return [NSDate dateCompFromDate:currDate];
}

+(NSDateComponents *)dateCompFromDate:(NSDate *)date
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date];
    return comps;
}

+(NSDateComponents *)dateCompFromString:(NSString *)dateStr
{
    if (0 == [dateStr length]) {
        return nil;
    }
    //return [self dateCompFromToday];
    NSMutableString *rightDateStr = [NSMutableString string];
    NSTextCheckingResult *match = nil; 
    NSRange range = {0,0};
    NSCharacterSet *whitespace = nil;
    NSString * str = nil;
    NSMutableString * strFormater = [NSMutableString string];
#warning 提取日期字符串
    //提取日期字符串
    NSString *pattern = @"\\s*\\d\\d\\d\\d\\s*-\\s*\\d\\d\\s*-\\s*\\d\\d\\s*";
    NSError *err;//错误的信息显示
    //NSRegularExpression  常规的表达式
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&err];
    NSArray *matches = [reg matchesInString:dateStr options:NSMatchingReportCompletion range:NSMakeRange(0, [dateStr length])];
    if([matches count] > 0){
        match = [matches objectAtIndex:0];
        range = [match range];
        whitespace = [NSCharacterSet  whitespaceCharacterSet];
        str = [[dateStr substringWithRange:range] stringByTrimmingCharactersInSet:whitespace];
        [rightDateStr appendString:str];
        [rightDateStr appendString:@" "];
        [strFormater appendString:@"yyyy-MM-dd "];//日期格式
    }
    else{
        //[rightDateStr appendString:@"0000-00-00 "];//其他的日期格式设定
    }
    //提取时间字符串
    pattern = @"\\s*\\d\\d\\s*:\\s*\\d\\d(\\s*:\\s*\\d\\d)?";
    reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&err];
    matches = [reg matchesInString:dateStr options:NSMatchingReportCompletion range:NSMakeRange(0, [dateStr length])];
    
    if([matches count] > 0){
        match = [matches objectAtIndex:0];
        range = [match range];
        whitespace = [NSCharacterSet  whitespaceCharacterSet];
        str = [[dateStr substringWithRange:range] stringByTrimmingCharactersInSet:whitespace];
        [rightDateStr appendString:str];
        if([str length] < [@"00:00:00" length]){//时间格式   当某个时间小于00:00:00 的时候就在 rightDateStr 后面拼接上 00
            [rightDateStr appendString:@":00"];
        }

    }
    else{
        [rightDateStr appendString:@"00:00:00"];
    }
    [strFormater appendString:@"HH:mm:ss"];
    
    NSDateFormatter *fmter = [[NSDateFormatter alloc] init];
    [fmter setDateFormat:strFormater/*@"yyyy-MM-dd HH:mm:ss"*/];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date  = [fmter dateFromString:rightDateStr];
    
    NSDateComponents * comp ;
    if(date == nil)
        comp = [[NSDateComponents alloc] init];
    else
        comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    //DBG(@"%04d-%02d-%02d %02d:%02d:%02d",comp.year,comp.month,comp.day,comp.hour,comp.minute,comp.second);
    return comp;
}

+(NSInteger)minutesIntervalBetweenDateComponent1:(NSDateComponents*)c1 component2:(NSDateComponents*)c2
{
//    DBG(@"%d--%d--%d  %d:%d:%d",c1.year,c1.month,c1.day,c1.hour,c1.minute,c1.second);
//    DBG(@"%d--%d--%d  %d:%d:%d",c2.year,c2.month,c2.day,c2.hour,c2.minute,c2.second);
    DBG(@"%ld--%ld--%ld  %ld:%ld:%ld",(long)c1.year,(long)c1.month,(long)c1.day,(long)c1.hour,(long)c1.minute,(long)c1.second);
    DBG(@"%ld--%ld--%ld  %ld:%ld:%ld",(long)c2.year,(long)c2.month,(long)c2.day,(long)c2.hour,(long)c2.minute,(long)c2.second);
    //NSCalendar 日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *d1 = [calendar dateFromComponents:c1];
    NSDate *d2 = [calendar dateFromComponents:c2];
    NSInteger intervel  = [d1 timeIntervalSinceDate:d2];
#warning 整数的绝对值 使用  ABS  浮点数的绝对值使用fabs   hjz
    return (NSInteger)(ABS(intervel)/60);
}

+(NSString *)descriptionOfMinutes:(NSInteger)minutes;
{
    NSMutableString *ret = [NSMutableString string];
    NSInteger left = 0,day = 0,hour = 0,minute  =0 ;
    day = minutes/(24*60);
    left = minutes%(24*60);
    
    hour = left/(60);
    left = left%(60);
    
    minute = left;
    
    if(day > 0) //天
//        [ret appendFormat:@"%d天",day];
        [ret appendFormat:@"%ld天",day];
    if(hour > 0) //小时
//        [ret appendFormat:@"%d小时",hour];
        [ret appendFormat:@"%ld小时",hour];
    if(minute >= 0) //分钟
//        [ret appendFormat:@"%d分",minute];
        [ret appendFormat:@"%ld分",(long)minute];
    return ret;
}

+(NSDateComponents *)dateCompOfNow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];//日历
    NSDate *date  = [NSDate date];
    NSDateComponents * comp ;
    comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    return comp;
}

+(NSDateComponents *)timeCompFromSeconds:(long) seconds
{
    NSDateComponents *ret = [[NSDateComponents alloc] init];
    long left, s,min,h;
    left = seconds;
    s = left % 60;
    left -= s;//秒   (left -=s  相当于  left = left - s)
    
    left /= 60;
    min = left % 60;
    left -= min; //分
    
    left /= 60;
    h = left%60;
    left -= h; //小时
    

    
    ret.hour = h;
    ret.minute = min;
    ret.second = s;
    
    return ret;
}

+(NSString *) timeDescFromDateComp:(NSDateComponents *)comp
{
    //return [NSString stringWithFormat:@"%02d:%02d:%02d",comp.hour,comp.minute,comp.second];
     return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)comp.hour,(long)comp.minute,(long)comp.second];
}

+(NSString *)dateDescFromDate:(NSDate *)date
{
    NSDateComponents *dateComp = [NSDate dateCompFromDate:date];
    return [NSDate dateDescFromDateComp : dateComp];
}

+(NSString *)dateDescFromDateComp:(NSDateComponents *)comp
{
    return [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",comp.year,comp.month,comp.day,comp.hour,comp.minute,comp.second];
}

+ (NSString *)stringFromDate:(NSDate *)date formatterStr:(NSString *)formatter {
    
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:formatter];
//    
//    NSString *dateStr = [format stringFromDate:date];
//    [format release];
    
    NSString *dateStr = [NSDate dateDescFromDateComp:[NSDate dateCompFromDate:date]];
    
    return dateStr;
}

+ (NSDate *)dateFromString:(NSString *)dateStr formatterStr:(NSString *)formatter {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:formatter];
    
    NSDate *date = [format dateFromString:dateStr]; //日期格式拼接
    
    return date;//返回日期..
}

+ (NSDate *)dateFromDateComp:(NSDateComponents*)dateComp
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *ret  = [calendar dateFromComponents:dateComp];
    return ret;
}

//返回各国日期时间格式       如：英语的日期描述法 "10:35pm" + "12-jul-2013"
+(NSArray *)engDescOfDateComp:(NSDateComponents *)dtc
{
    NSString *time = @"";  //时间
    NSString *date = @"";  //日期
    NSString *dateInWave = @"";//画图专用
    
//    if ([curLanguage isEqualToString:@"zh-Hans"]) { //如果是简体中文
//        date = [NSString stringWithFormat:@"%d-%02d-%02d", dtc.year, dtc.month, dtc.day];
//        dateInWave = [NSString stringWithFormat:@"%02d-%02d",dtc.month ,dtc.day];
//    }else if([curLanguage isEqualToString:@"ja"]) {  //如果是日语
//        date = [NSString stringWithFormat:@"%d/%02d/%02d", dtc.year, dtc.month, dtc.day];
//        dateInWave = [NSString stringWithFormat:@"%02d/%02d",dtc.month ,dtc.day];
//    } else {  //如果是
//        NSArray *monthNameList;
//        if ([curLanguage isEqualToString:@"fr"]) {  //法文
//            monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Avr",@"Mai",@"Juin",@"Juil",@"Aou",@"Sep",@"Oct",@"Nov",@"Déc",nil];
//        }else if ([curLanguage isEqualToString:@"de"]) {   //德文
//            monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mär",@"Apr",@"Mai",@"Jun",@"Jul",@"Aug",@"Sep",@"Okt",@"Nov",@"Dez",nil];
//        }else if ([curLanguage isEqualToString:@"hu"]) {   //匈牙利文
//            monthNameList = [NSArray arrayWithObjects:@"Jan", @"Febr",@"Márc",@"Ápr",@"Május",@"Jún",@"Júl",@"Aug",@"Szept",@"Okt",@"Nov",@"Dec",nil];
//        }else { //英文 或其他
//            monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
//        }
        NSArray *monthNameList;
    
    if ([curLanguage isEqualToString:@"es-CN"]) { //如果是简体中文
        monthNameList = [NSArray arrayWithObjects:@"Ene",@"Feb",@"Mar",@"Abr",@"May",@"Jun",@"Jul",@"Ago",@"Sept",@"Oct",@"Nov",@"Dic",nil];
    }else{
        //因为只有英文，所以写出来
        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
    }
    

        int index = MIN(dtc.month-1,12-1);//最小的月份
        index = MAX(index,1-1);
        NSString *monthName = monthNameList[index];
        date = [NSString stringWithFormat:@"%@ %02ld, %ld",monthName,(long)dtc.day,(long)dtc.year];
        dateInWave = [NSString stringWithFormat:@"%0ld-%@",(long)dtc.day,monthName];
//    }
    
    time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)dtc.hour,(long)dtc.minute,(long)dtc.second];
    
    //转换成12小时
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:time];
    dateFormatter.timeStyle = kCFDateFormatterMediumStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* dateString = @"";
    if(destDate)
    {
       dateString = [dateFormatter stringFromDate:destDate];//日期字符串格式转换
    }
   


    NSArray *ret = [NSArray arrayWithObjects:dateString,date,[NSString stringWithFormat:@"%@, %@",dateString,date],dateInWave, nil];
    
    return ret;
}
#warning 采用英文格式来存储
//同上，由于数据存储原因，特加此方法 关于数据存储的都用此方法（即统一用英语格式）
+ (NSArray *)engDescOfDateCompForDataSaveWith:(NSDateComponents *)dtc
{
    NSString *time = @"";
    NSString *date = @"";
    NSString *dateInWave = @"";//画图专用
    
    time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)dtc.hour,(long)dtc.minute,(long)dtc.second];
  
    //转换成12小时
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:time];
    dateFormatter.timeStyle = kCFDateFormatterMediumStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* dateString = [dateFormatter stringFromDate:destDate];
    
    NSArray *monthNameList;
    if ([curLanguage isEqualToString:@"es-CN"]) { //如果是简体中文
        monthNameList = [NSArray arrayWithObjects:@"Ene",@"Feb",@"Mar",@"Abr",@"May",@"Jun",@"Jul",@"Ago",@"Sept",@"Oct",@"Nov",@"Dic",nil];
    }else{
        //因为只有英文，所以写出来
        monthNameList = [NSArray arrayWithObjects:@"Jan", @"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
    }
    
    int index = MIN(dtc.month-1,12-1);
    index = MAX(index,1-1);
    NSString *monthName = monthNameList[index];
    date = [NSString stringWithFormat:@"%2ld-%@-%ld",(long)dtc.day,monthName,(long)dtc.year];
    dateInWave = [NSString stringWithFormat:@"%ld-%@",(long)dtc.day,monthName];
    NSArray *ret = [NSArray arrayWithObjects:dateString,date,[NSString stringWithFormat:@"%@,%@",dateString,date],dateInWave, nil];
    
    return ret;
}


@end