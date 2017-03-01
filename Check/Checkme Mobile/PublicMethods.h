//
//  PublicMethods.h
//  DeliveryMS
//
//  Created by hu on 13-5-28.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "TypesDef.h"


@interface PublicMethods : NSObject

//显示一个警告.仅起提示的作用
+ (void)msgBoxWithTitle:(NSString *)title message:(NSString *)message;

//显示一个警告.仅起提示的作用,title默认为 @"提示"
+ (void)msgBoxWithMessage:(NSString *)message;

//67s---->1分7秒
//时间转换
+ (NSString *)transferFromSeconds:(NSInteger)seconds;

/** 将原图片进行放大(类似于切图吧)*/
+ (UIImage *)handImage:(CGSize)targetSize sourceImage:(UIImage *)sourceImag;

//获取diretory目录下startString开头的文件，按名字大小排序
+ (NSArray *)getFilePathStart:(NSString *)startString atDicretory:(NSString *)diretory;

//将苹果经纬度转化成百度经纬度
#warning 这个方法貌似还没用上吧
+ (CLLocationCoordinate2D)sysCoordinate2BaiduCoordinate:(CLLocationCoordinate2D)sysCoor;

//p1 ,p1为两个苹果经纬度点，diffAltitude为海拔差距
#warning 这个方法没有使用(原创有何目的??)
+ (CLLocationDistance)distanceBetweenCoordinate1:(CLLocationCoordinate2D)p1 coordinate2:(CLLocationCoordinate2D)p2 diff:(double)diffAltitude;

//两苹果手机定位点的百度间距
+ (double)distanceBetweenLocation1:(CLLocation *)locate1 location2:(CLLocation *)locate2;

+ (void)makePhoneCallToNumber:(NSString *)phoneNumber;

//通过字符串和字体取得一个label,大小刚好为字符串尺寸
+ (UILabel *)getLabelWithString:(NSString *)text labelFont:(UIFont *)font;

//参数体重kg,平均速度m/s,返回卡路里,type:1为走路 2为跑步
+ (double)useupCalorie:(CGFloat)weight speed:(double)speed grade:(CGFloat)grade duration:(CGFloat)time sportType:(NSInteger)type;

//+ (void)writeLocationToFile:(CLLocation *)locate :(int)speed :(int)heart;
#warning 从文件中获取 location 位置
+ (void)readLocationToFile;

+ (void)setNavItem:(UINavigationItem *)item withTitleText:(NSString *)text;
+ (void)setNavItem:(UINavigationItem *)item withTitleImage:(UIImage *)img;
+ (void)setNavBar:(UINavigationBar*)bar withBgImage:(UIImage *)img;//背景图
//设置导航栏左侧按钮事件
+ (void)setNavItem:(UINavigationItem *)item withLButtonNomalImage:(UIImage *)imgNormal andLButtonHilightImage:(UIImage *)imgHiglight andCallBack:(SEL)callBack forTarget:(id)target;
//设置导航栏右侧按钮事件
+ (void)setNavItem:(UINavigationItem *)item withRButtonNomalImage:(UIImage *)imgNormal
    andRButtonHilightImage:(UIImage *)imgHiglight andCallBack:(SEL)callBack forTarget:(id)target;


+(CGFloat) widthOfString:(NSString *)string withFont:(UIFont *)font maxHeight:(CGFloat)maxHeight;
+(CGFloat) heightOfString:(NSString *)string withFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
////digit：表示10的digit次方。获取单位(十，百，千,万)
//- (NSString *)addUnitFromExponential:(NSInteger)digit;

//将一个数转字符串化成中文阅读（@"123.344"--->@"1百2十3点344"）
//+ (NSString *)translateChineseFromNumber:(NSString *)numberStr;
+ (NSArray*)translateNumberFromNumberString:(NSString *)numberStr;




+(void)findMaxVal:(double *)max minVal:(double *)min inArr:(NSArray *)arr;
+(void)findMaxValWithoutErrVal:(double *)max minVal:(double *)min inArr:(NSArray *)arr;

+(void)sendEmailWith_Subject:(NSString *)subject recipientArr:(NSArray *)recipientArr image:(UIImage *)image imageName:(NSString *)imageName messageBody:(NSString *)messageBody  delegate:(id<MFMailComposeViewControllerDelegate>)delegate;

+(NSString*)makeDateFileName:(NSDateComponents*)date fileType:(U8)type;

//+(uint8_t)calCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int) Buffer_Size;


//  liqian  add
+ (NSString *) parseECG_innerData_ecgResultDescribWith:(NSString *)ecgResultDescrib withArray:(NSArray *)ecgResults;
//获取当前语言
+ (NSString *) getDeviceCurLanguage;
//获取当前国家
+ (NSString *)getCurCountry;
@end


