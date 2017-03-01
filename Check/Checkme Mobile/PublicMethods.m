//
//  PublicMethods.m
//  DeliveryMS
//
//  Created by hu on 13-5-28.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "PublicMethods.h"
#import "TypesDef.h"
#import <CoreLocation/CoreLocation.h>
#import "NSString+Additional.h"
#import "BTDefines.h"

@implementation PublicMethods

//显示一个警告.仅起提示的作用
+ (void)msgBoxWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)msgBoxWithMessage:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tips"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (NSString *)transferFromSeconds:(NSInteger)seconds {
    
    if (0 == seconds) {
        return @"0秒";
    }
    
    NSString *timeStr = @"";
    NSInteger hour = seconds/3600;
    if (hour > 0) {
        timeStr = [timeStr stringByAppendingFormat:@"%d小时",hour];
    }
    NSInteger minute = (seconds - hour*3600)/60;
    if (minute > 0) {
        timeStr = [timeStr stringByAppendingFormat:@"%d分",minute];
    }
    
    NSInteger second = seconds%60;
    if (second > 0) {
        timeStr = [timeStr stringByAppendingFormat:@"%d秒",second];
    }
    return timeStr;
}

+ (UIImage *)handImage:(CGSize)targetSize sourceImage:(UIImage *)sourceImag {
    UIImage *newImage = nil;
    
    CGFloat width = sourceImag.size.width;
    CGFloat height = sourceImag.size.height;
    
    CGFloat scaleFactor = 0;
    CGPoint newImagePoint = CGPointMake(0, 0);
    
    CGFloat newImg_width = targetSize.width;
    CGFloat newImg_height = targetSize.height;
    
    CGFloat scale_x = width/newImg_width;
    CGFloat scale_y = height/newImg_height;
    
    //图片放大或缩小相同的倍数先达到预计宽或高
    if (scale_y > scale_x) {
        scaleFactor = scale_y;
    }
    else {
        scaleFactor = scale_x;
    }
    
    //根据图片放大缩小倍数计算出显示区域
    newImg_width = width/scaleFactor;
    newImg_height = height/scaleFactor;
    
    if (scale_y > scale_x) {
        newImagePoint.x = (targetSize.width - newImg_width)/2;
    }
    else {
        newImagePoint.y = (targetSize.height - newImg_height)/2;
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect newRect = CGRectZero;
    newRect.origin = newImagePoint;
    newRect.size.width = newImg_width;
    newRect.size.height = newImg_height;
    
    [sourceImag drawInRect:newRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (nil == newImage) {
    }
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSArray *)getFilePathStart:(NSString *)startString atDicretory:(NSString *)diretory {
    
    NSMutableArray *fileArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:diretory error:nil];
    for (NSString *fileName in fileList) {
        if ([fileName hasPrefix:startString]) {
            
            NSString *file = [diretory stringByAppendingPathComponent:fileName];
            [fileArray addObject:file];
        }
    }
    
    return fileArray;
}

+ (void)makePhoneCallToNumber:(NSString *)phoneNumber
{
    if (0 == [phoneNumber length]) {
        [PublicMethods msgBoxWithTitle:@"提示" message:@"号码不能为空"];
        return;
    }
    NSString *telNUM = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    NSURL *telURL = [NSURL URLWithString:telNUM] ;
    [[UIApplication sharedApplication] openURL:telURL];
}

+ (UILabel *)getLabelWithString:(NSString *)text labelFont:(UIFont *)font {
    
    CGSize textSize = [text sizeWithFont:font];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    label.font = font;
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}


+ (void)setNavItem:(UINavigationItem *)item withTitleText:(NSString *)text;
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(70 , 0, 320 - 70*2, 44)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment  = UITextAlignmentCenter;
    //lbl.shadowColor = [UIColor whiteColor];
    lbl.shadowOffset  =CGSizeMake(0, 1);
    lbl.text = text;
    lbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    lbl.textColor = [UIColor whiteColor];//COLOR_RGB(127,4,4,1.0);
    item.titleView = lbl;
}

+ (void)setNavItem:(UINavigationItem *)item withTitleImage:(UIImage *)img
{
    UIView * titleBgView = [[UIView alloc] initWithFrame:CGRectMake(70,0,180,44)];
    CGRect rect ;
    rect.origin.x = titleBgView.frame.size.width/2.0 - (img.size.width/2.0)/2.0;
    rect.origin.y = /*12.0*/(titleBgView.frame.size.height - img.size.height/2.0)/2.0;
    rect.size.width = img.size.width/2.0;
    rect.size.height = img.size.height/2.0;
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:rect];
    titleView.image = img;
    [titleBgView addSubview:titleView];
    item.titleView = titleBgView;
    
}
+ (void)setNavBar:(UINavigationBar*)bar withBgImage:(UIImage *)img
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=5.0) {
        [bar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    } else {
        [bar setBarStyle:UIBarStyleBlack];
    }
}

+ (void)setNavItem:(UINavigationItem *)item withLButtonNomalImage:(UIImage *)imgNormal andLButtonHilightImage:(UIImage *)imgHiglight andCallBack:(SEL)callBack  forTarget:(id)target
{
    UIImage *normalImg = imgNormal;
    UIImage *lightImg = imgHiglight;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 58, 44)];
    [btn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [btn setBackgroundImage:lightImg forState:UIControlStateHighlighted];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn addTarget:target action:callBack forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    item.leftBarButtonItem = btnItem;
}

+ (void)setNavItem:(UINavigationItem *)item withRButtonNomalImage:(UIImage *)imgNormal andRButtonHilightImage:(UIImage *)imgHiglight andCallBack:(SEL)callBack  forTarget:(id)target
{
    UIImage *normalImg = imgNormal;
    UIImage *lightImg = imgHiglight;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 58, 44)];
    [btn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [btn setBackgroundImage:lightImg forState:UIControlStateHighlighted];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn addTarget:target action:callBack forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    item.rightBarButtonItem = btnItem;
}


//+ (CLLocationCoordinate2D)sysCoordinate2BaiduCoordinate:(CLLocationCoordinate2D)sysCoor
//{
//    NSDictionary *baidudict = BMKBaiduCoorForWgs84(sysCoor);
//    CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(baidudict);
//    return baiduCoordinate;
//}

//两个坐标点的距离（百度距离）
//+ (CLLocationDistance)distanceBetweenCoordinate1:(CLLocationCoordinate2D)p1 coordinate2:(CLLocationCoordinate2D)p2 diff:(double)diffAltitude {
//    
//    CLLocationCoordinate2D baiduP1 = [PublicMethods sysCoordinate2BaiduCoordinate:p1];
//    CLLocationCoordinate2D baiduP2 = [PublicMethods sysCoordinate2BaiduCoordinate:p2];
//    
//    CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(baiduP1),BMKMapPointForCoordinate(baiduP2));//先转成百度坐标
//    
//    return sqrt(diffAltitude*diffAltitude + distance*distance);
//}

+ (double)distanceBetweenLocation1:(CLLocation *)locate1 location2:(CLLocation *)locate2 {
    
    double diff = (locate1.altitude - locate2.altitude);
    
    CLLocationCoordinate2D p1 = locate1.coordinate;
    CLLocationCoordinate2D p2 = locate2.coordinate;
    
    double distance = [PublicMethods distanceBetweenCoordinate1:p1 coordinate2:p2 diff:diff];//两点之间的距离
    return distance;
}

+ (NSString *)addUnitFromExponential:(NSInteger)digit {
    
    if (1 == digit) {
        return @"十";
    }
    if (2 == digit) {
        return @"百";
    }
    if (3 == digit) {
        return @"千";
    }
    //    if (4 == digit) {
    //        return @"万";
    //    }
    return @"";
}


//+ (NSArray*)translateNumberFromNumberString:(NSString *)numberStr //toLanguage:(Language_t)language
//{
//    NSArray  *ret = nil;//[NSMutableArray arrayWithCapacity:10];
//    Language_t language = [MySetting language];
//    switch (language) {
//        case language_ComplexChinese:
//        case language_SimpleChinese:
//            ret = [PublicMethods translateChineseFromNumber : numberStr];
//            break;
//        case language_English:
//            ret = [PublicMethods translateEnglishFromNumber:numberStr];
//            break;
//        default:
//            break;
//    }
//    
//    return ret;
//}


//将一个数字转化成英文阅读
+ (NSArray *)translateEnglishFromNumber:(NSString *)numberStr
{
    const char *num_c_str = [numberStr UTF8String];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    if(!numberStr || [numberStr length] <= 0)
        return arr;
    
    if ([numberStr doubleValue] - 0.00 == 0) {
        [arr addObject:@"en_number_0"];
        return arr;
    }
    
    //转化小数部分
    NSMutableArray *arr_fraction = [NSMutableArray arrayWithCapacity:10];
    const char * p_point = strchr(num_c_str, '.');
    //小数点后部分
    if(p_point){
        //有小数点
        for(const char *p = p_point + 1; p && *p; ++p ){
            
            NSString *name = [PublicMethods engNumberVoiceFrom0_9:*p-48];
            if([name length] > 0)
                [arr_fraction addObject:name];
        }
    }
    //小数点
    if(p_point && [arr_fraction count] > 0){
        [arr_fraction insertObject:@"en_point" atIndex:0];
    }
    
    //转化整数部分
    NSMutableArray *arr_integer = [NSMutableArray arrayWithCapacity:10];
    const char *p_last_int = (p_point ? (p_point - 1):  num_c_str + strlen(num_c_str) - 1);
    int pos = 0 ;
    for(const char *p = p_last_int; p >= num_c_str;/*--p,++pos*/){
        //NSInteger n = *p - 48;
        if((pos % 3) == 0){
            
            if(p-1>= num_c_str && *(p-1)=='1'){
                if(pos != 0)
                    [arr_integer insertObject:@"en_thousand" atIndex:0];
                
                char a[3] = "";
                strncpy(a, p-1, 2);
                NSString *r = [PublicMethods engNumVoiceFrom_10_19:atoi(a)];
                [arr_integer insertObject:r atIndex:0];
                
                pos += 2;
                p -= 2;
                continue;
            }
            
        }
        
        
        NSArray *ret = [PublicMethods engNumberVoiceArrayFromSingleNum:*p - 48 pos:pos];
        for(NSString *r in ret){
            [arr_integer insertObject:r atIndex:0];
        }
        
        
        
        --p;
        ++pos;
        
        //        NSString *name = [ PublicMethods engNumberVoiceFromSingleNum:n pos:pos];
        //        if([name length])
    }
    
    [arr setArray:arr_integer];//添加到 array数组中去
    [arr addObjectsFromArray:arr_fraction];
    return  arr;
}




+(NSArray *)engNumberVoiceArrayFromSingleNum:(NSInteger)num  pos:(NSInteger)pos
{
    NSInteger r_pos = pos%3;  //这个表示 r_pos 的值  在 0 ~ 2 之间
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    if(r_pos == 0 && pos == 0){
        if(num > 0 && num <= 9){
            NSString *ret = [PublicMethods engNumberVoiceFrom0_9:num];
            [arr addObject:ret];
        }
    }
    else if(r_pos == 1){
        if(num>=2 && num <=9){
            NSArray *arr_20_90 = [NSArray arrayWithObjects:@"en_number_20", @"en_number_30",@"en_number_40",@"en_number_50",@"en_number_60",@"en_number_70",@"en_number_80",@"en_number_90",nil];
            
            NSString *ret = [arr_20_90 objectAtIndex:num - 2];
            [arr addObject:ret];
        }
    }
    else if(r_pos == 2){
        if(num>=1 && num <= 9){
            NSArray *arr_100_900 = [NSArray arrayWithObjects:@"en_number_100", @"en_number_200",@"en_number_300",@"en_number_400",@"en_number_500",@"en_number_600",@"en_number_700",@"en_number_800",@"en_number_900",nil];
            NSString *ret = [arr_100_900 objectAtIndex:num - 1];
            [arr addObject:ret];
            
        }
    }
    
    else if(r_pos ==0 && pos > 0){
        if(num >=1 && num<=9){
            NSString *ret = @"en_thousand";
            [arr addObject:ret];
            ret = [PublicMethods engNumberVoiceFrom0_9:num];
            [arr addObject:ret];
        }
    }
    
    return arr;
    
}

+(NSString *)engNumVoiceFrom_10_19 : (NSInteger)n
{
    if(n<10 || n > 19)
        return @"";
    NSArray * arr_voice = [NSArray arrayWithObjects:@"en_number_10", @"en_number_11",@"en_number_12",@"en_number_13",@"en_number_14",@"en_number_15",@"en_number_16",@"en_number_17",@"en_number_18",@"en_number_19",nil];
    return [arr_voice objectAtIndex:n - 10];
}

+(NSString *)engNumberVoiceFrom0_9:(NSInteger)n
{
    if(n < 0 || n > 9)
        return @"";
    NSArray * arr_voice  = [NSArray arrayWithObjects:@"en_number_0",@"en_number_1",@"en_number_2",@"en_number_3",@"en_number_4",@"en_number_5",@"en_number_6",@"en_number_7",@"en_number_8",@"en_number_9", nil];
    int index = n;//c - 48;
    if(index > ([arr_voice count] - 1 ) )
        return @"";
    return  [arr_voice objectAtIndex:index];
    
}

//将一个数转化成中文阅读
+ (NSArray *)translateChineseFromNumber:(NSString *)numberStr {
    
    if ([numberStr doubleValue] - 0.00 == 0) {
        return [@"0" arrFromEveryChar];
    }
    NSString *chineseStr = [NSString string];
    
    NSString *integerStr = [numberStr stringByDeletingPathExtension];
    NSInteger len = [integerStr length];
    NSInteger locate = len/4;
    NSInteger reste = len%4;
    
    if (reste > 0) {
        
        NSString *subStr = [numberStr substringWithRange:NSMakeRange(0, reste)];
        chineseStr = [chineseStr stringByAppendingString:[PublicMethods translateFromSubNumber:subStr]];
        
        if (2 == locate) {
            chineseStr = [chineseStr stringByAppendingString:@"万万"];
        }
        else if (1 == locate) {
            chineseStr = [chineseStr stringByAppendingString:@"万"];
        }
        
    }
    
    NSInteger curLocate = locate - 1;
    
    for (int i = 0; i < locate; i++) {
        
        NSString *subStr = [numberStr substringWithRange:NSMakeRange(reste + 4*i, 4)];
        
        chineseStr = [chineseStr stringByAppendingString:[PublicMethods translateFromSubNumber:subStr]];
        
        if (2 == curLocate) {
            chineseStr = [chineseStr stringByAppendingString:@"亿"];
        }
        else if (1 == curLocate) {
            chineseStr = [chineseStr stringByAppendingString:@"万"];
        }
        
        curLocate--;
    }
    
    NSString *decimalStr = [numberStr pathExtension];
    
    if ([decimalStr integerValue] > 0) {
        if ([chineseStr length] < 1) {//0被屏蔽了，因为0后面有小数，所以要把0给加上
            chineseStr = [chineseStr stringByAppendingString:@"0"];
        }
        chineseStr = [chineseStr stringByAppendingString:@"点"];
        
        for (NSInteger j = 0; j < [decimalStr length]; j++) {
            NSString *oneNumStr = [decimalStr substringWithRange:NSMakeRange(j, 1)];
            chineseStr = [chineseStr stringByAppendingString:oneNumStr];
        }
    }
    
    
    return [chineseStr  arrFromEveryChar];
}



//numberStr是不超过4位的整数(注意这里的numberStr不能超过 4 位)
+ (NSString *)translateFromSubNumber:(NSString *)numberStr {
    
    NSString *chineseStr = [NSString string];
    NSString *tmpStr = nil;
    for (NSInteger j = 0; j < [numberStr length]; j++) {
        
        NSString *oneNumStr = [numberStr substringWithRange:NSMakeRange(j, 1)];
        
        if ([tmpStr isEqualToString:@"0"] && [tmpStr isEqualToString:oneNumStr]) {
            
        }
        else {
            NSInteger locate = [numberStr length]- 1 - j;
            if (([chineseStr length] < 1 && 1 == locate && [oneNumStr isEqualToString:@"1"]) || [oneNumStr isEqualToString:@"0"]) {
                
            }
            else {
                if ([tmpStr isEqualToString:@"0"] && ![oneNumStr isEqualToString:@"0"]) {
                    chineseStr = [chineseStr stringByAppendingString:tmpStr];
                }
                chineseStr = [chineseStr stringByAppendingString:oneNumStr];
            }
            
            tmpStr = oneNumStr;
            if (![tmpStr isEqualToString:@"0"]) {
                chineseStr = [chineseStr stringByAppendingString:[PublicMethods addUnitFromExponential:locate]];
            }
        }
    }
    return chineseStr; //返回中文的字符串形式
}

+ (double)useupCalorie:(CGFloat)weight speed:(double)speed grade:(CGFloat)grade duration:(CGFloat)time sportType:(NSInteger)type {
    grade = 0.01;
    if (1 == type) {//走路
        /* 3.5 + [speed (meters per minute) x 0.1] + [speed (meters per minute) x % grade x 1.8] = VO2 in ml/kg/min
         METs = VO2 / 3.5
         所消耗卡路里/每小时 = METs x 重量kg */
        
        CGFloat VO2 = 3.5 + speed*0.1 + speed*grade*1.8;//ml/kg/min
        CGFloat METs = VO2/3.5;
        return METs*weight*time/3600;//卡/小时
        
    }
    else if (2 == type) {//跑步
        CGFloat VO2 = 3.5 + speed*0.2 + speed*grade*0.9;//ml/kg/min
        CGFloat METs = VO2/3.5;
        return METs*weight*time/3600;
    }
    return 0;
}


/*
 struct result
 {
 double  x;//经度
 double  y;//纬度
 double  z;//海拔
 double  time;//时间戳
 int     speed;
 int     heartRate;
 }a;
 
 + (void)writeLocationToFile:(CLLocation *)locate :(int)speed :(int)heart {
 
 NSString *dire = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 NSString *fullFileName = [dire stringByAppendingPathComponent:@"ios_locate.txt"];
 
 FILE *fp = fopen([fullFileName UTF8String],"ab+");
 //    struct result
 //    {
 //        double  x,y,z;
 //        double  time;//时间戳
 //    }a;
 
 a.x = locate.coordinate.longitude;
 a.y = locate.coordinate.latitude;
 a.z = locate.altitude;
 a.time = [locate.timestamp timeIntervalSince1970];
 a.speed = speed;
 a.heartRate = heart;
 
 fwrite(&a,sizeof(struct result),1,fp);
 fclose(fp);
 
 }
 
 + (void)readLocationToFile {
 NSString *dire = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 NSString *fullFileName = [dire stringByAppendingPathComponent:@"ios_locate.txt"];
 
 FILE *fp = fopen([fullFileName UTF8String],"rb+");
 
 while (1 && fp) {
 
 if (feof(fp)) {
 break;
 }
 
 fread(&a,sizeof(struct result),1,fp);
 DBG(@"%lf,%lf,%lf,%@",a.x,a.y,a.z, [NSDate dateWithTimeIntervalSince1970:a.time]);
 
 }
 
 fclose(fp);
 }
 */

struct result
{
    double    x,y,z;
    NSInteger time;//时间戳
    NSInteger type;//运动类型
}a;

struct result1
{
    double    x,y;
}a1;

+ (void)readLocationToFile {
    NSString *dire = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFileName = [dire stringByAppendingPathComponent:@"ios_sport.txt"];
    
    FILE *fp = fopen([fullFileName UTF8String],"rb+");
    
    while (1 && fp) {
        
        if (feof(fp)) {
            break;
        }
        
        fread(&a,sizeof(struct result),1,fp);        
    }
    fclose(fp);
}


+(CGFloat) widthOfString:(NSString *)string withFont:(UIFont *)font maxHeight:(CGFloat)maxHeight
{
    CGSize sz  = [string sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, maxHeight)];
    return sz.width;
}


+(CGFloat) heightOfString:(NSString *)string withFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    CGSize sz  = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    return sz.height;
}







+(void)findMaxVal:(double *)max minVal:(double *)min inArr:(NSArray *)arr
{
    if(NULL == max || NULL == min)
        return;
    
    double mi = 0 ;
    double ma = 0;
    
    if(arr.count > 0)
    {
        mi = [[arr objectAtIndex:0] doubleValue];
        ma = mi;
    }
    for(NSNumber * num in arr)
    {
        double val = num.doubleValue;
        if(val>ma)
            ma = val;
        if(val<mi)
            mi = val;
    }
    
    *max = ma;
    *min = mi;
}

+(void)findMaxValWithoutErrVal:(double *)max minVal:(double *)min inArr:(NSArray *)arr
{
    if(NULL == max || NULL == min)
        return;
    
    double mi = 254 ;
    double ma = -100;
    
//    if(arr.count > 0)
//    {
//        mi = [[arr objectAtIndex:0] doubleValue];
//        ma = mi;
//    }
    for(NSNumber * num in arr)
    {
        double val = num.doubleValue;
        if(val>ma&&val!=0xFF&&val!=0)
            ma = val;
        if(val<mi&&val!=0xFF&&val!=0)
            mi = val;
    }
    
    *max = ma;
    *min = mi;
}


+(void)sendEmailWith_Subject:(NSString *)subject recipientArr:(NSArray *)recipientArr image:(UIImage *)image imageName:(NSString *)imageName messageBody:(NSString *)messageBody  delegate:(id<MFMailComposeViewControllerDelegate>)delegate
{
    Class mailClass = NSClassFromString(@"MFMailComposeViewController");
    if(mailClass)
    {
        if([mailClass canSendMail])
        {
            //开始发送邮件
            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            
            mailPicker.mailComposeDelegate = delegate;
            
            //设置主题
            [mailPicker setSubject: subject];
            
            // 添加收件人
            NSArray *toRecipients = recipientArr;//[NSArray arrayWithObject: @"2280278615@qq.com"];
            [mailPicker setToRecipients: toRecipients];
            
            //添加抄送
            //NSArray *ccRecipients
            //[mailPicker setCcRecipients:ccRecipients];
            
            
            //添加密送
            // NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
            //[mailPicker setBccRecipients:bccRecipients];
            
            
            // 添加图片
            UIImage *addPic = image;
            //NSData *imageData = UIImagePNGRepresentation(addPic);            // png
             NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
            [mailPicker addAttachmentData: imageData mimeType: @"" fileName: imageName];
            
            
            //添加一个pdf附件
            //            NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
            //            NSData *pdf = [NSData dataWithContentsOfFile:file];
            //            [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
            //
            
            
            //添加正文
            NSString *emailBody = messageBody;//@"蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理蓝牙健康管理";
            [mailPicker setMessageBody:emailBody isHTML:NO];
            
            
            [(UIViewController *)delegate presentModalViewController:mailPicker animated:YES];
            
        }
        else
        {
            [PublicMethods msgBoxWithMessage:@"Does not support in-app email"];
        }
    }
    else
    {
        [PublicMethods msgBoxWithMessage:@"Does not support in-app email"];
    }
}

+(NSString *)makeDateFileName:(NSDateComponents*)date fileType:(U8)type
{
    
    NSString* dateString = [NSString stringWithFormat:@"%ld%02ld%02ld%02ld%02ld%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.second];
    
    if (type==FILE_Type_ECGVoiceData || type == FILE_Type_SpcVoiceData) {
        NSString* voiceString = [NSString stringWithFormat:@"%@.wav",dateString];
        return voiceString;
    }
    return dateString;
}


//const unsigned char Table_CRC8[256]={      /*CRC8 ±í*/
//    0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
//    0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
//    0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
//    0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
//    0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
//    0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
//    0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
//    0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
//    0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
//    0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
//    0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
//    0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
//    0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
//    0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
//    0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
//    0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
//    0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
//    0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
//    0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
//    0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
//    0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
//    0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
//    0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
//    0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
//    0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
//    0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
//    0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
//    0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
//    0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
//    0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
//    0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
//    0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
//};
//
//+(uint8_t)calCRC8:(unsigned char *)RP_ByteData bufSize:(unsigned int) Buffer_Size
//{
//    uint8_t x,R_CRC_Data;
//    uint32_t i;
//    
//    R_CRC_Data=0;
//    for(i=0;i<Buffer_Size;i++)
//    {
//        x = R_CRC_Data ^ (*RP_ByteData);
//        R_CRC_Data = Table_CRC8[x];
//        RP_ByteData++;
//    }
//    return R_CRC_Data;
//}

//  liqian add    解析ecg诊断结果  多结果
+ (NSString *)parseECG_innerData_ecgResultDescribWith:(NSString *)ecgResultDescrib withArray:(NSArray *)ecgResults
{
    U8 result = [ecgResultDescrib intValue];
    NSString *str = @"";
    if(result==0xFF)
        str = ecgResults[8];
    else if(result==0)
        str = ecgResults[0];
    else{
        for (int i=0; i<9; i++) {
            //第一条前面不加回车
            NSString *tempStr = (result&(1<<i)) == 0 ? @"" : ( str.length<1 ? ecgResults[i+1] : [NSString stringWithFormat:@"\r\n%@",ecgResults[i+1]]);
            str = [str stringByAppendingString:tempStr];
        }
    }
    return str;
}

//获取当前设备使用的语言
+(NSString *)getDeviceCurLanguage
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [[ud objectForKey:@"AppleLanguages"] firstObject];//获取当前语言
}
//获取当前 的 国家
+ (NSString *)getCurCountry
{
    NSLocale *currentLocale = [NSLocale currentLocale]; //语言环境...
    return [currentLocale objectForKey:NSLocaleCountryCode];
}

@end
