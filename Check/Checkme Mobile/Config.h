#ifndef __CONFIG_H__
#define  __CONFIG_H__

#import "ToolMacro.h"
#import "PublicMethods.h"

#define IMAGE_WITH_NAME(name) [UIImage imageNamed:name]
#define COMMAN_IMAGE_BACK IMAGE_WITH_NAME(@"返回")
#define COMMAN_IMAGE_BACK_LIGHT IMAGE_WITH_NAME(@"返回-点击")

#define NAV_BG_IMAGE IMAGE_WITH_NAME(@"导航栏")
#define NAV_TITLE_FONT ([UIFont systemFontOfSize:20])
#define NAV_TITLE_COLOR ([UIColor whiteColor])

#define IMG_RESULT_ARRAY ([NSArray arrayWithObjects:@"smile", @"cry",@"",nil])
#define IMG_LEAD_ARRAY ([NSArray arrayWithObjects:@"lead_1", @"lead_2",@"lead_3",@"lead_4",nil])
#define IMG_VOICE_ARRAY ([NSArray arrayWithObjects:@"voice",@"",nil])


#define INT_TO_STRING(num) ([NSString stringWithFormat:@"%d",num])
#define DOUBLE_TO_STRING(num) ([NSString stringWithFormat:@"%.1f",num])
#define DOUBLE2_TO_STRING(num) ([NSString stringWithFormat:@"%.2f",num])
#define DOUBLE3_TO_STRING(num) ([NSString stringWithFormat:@"%.3f",num])

#define INT_TO_STRING_WITHOUT_ERR_NUM(num) (num==0?@"--":[NSString stringWithFormat:@"%d",num])
#define DOUBLE1_TO_STRING_WITHOUT_ERR_NUM(num) (num==0?@"--":[NSString stringWithFormat:@"%.1f",num])
//保留一位小数(保留小数点后一位)
#define DOUBLE3_TO_STRING_WITHOUT_ERR_NUM(num) (num==0?@"--":[NSString stringWithFormat:@"%.1f",num])
#define DOUBLE2_TO_STRING_WITHOUT_ERR_NUM(num) (num==0?@"--":[NSString stringWithFormat:@"%.2f",num])

#define STR_RESULT_ARRAY ([NSArray arrayWithObjects:DTLocalizedString(@"Normal Blood Oxygen", nil), DTLocalizedString(@"Low Blood Oxygen", nil),DTLocalizedString(@"Unable to Analyze", nil),nil])

#define ECG_RESULT_ARRAY ([NSArray arrayWithObjects:DTLocalizedString(@"Regular ECG Rhythm", nil), DTLocalizedString(@"High Heart Rate", nil), DTLocalizedString(@"Low Heart Rate", nil), DTLocalizedString(@"High QRS Value", nil), DTLocalizedString(@"High ST Value", nil), DTLocalizedString(@"Low ST Value", nil), DTLocalizedString(@"Irregular ECG Rhythm", nil), DTLocalizedString(@"Suspected Premature Beat", nil), DTLocalizedString(@"Unable to Analyze", nil),nil])

//  liqian add
//关于ecg诊断结果的解析
#define ecgResultDescrib(describ) [PublicMethods parseECG_innerData_ecgResultDescribWith:(describ) withArray:ECG_RESULT_ARRAY]
//当前设备语言
#define curLanguage [PublicMethods getDeviceCurLanguage]
//当前地区
#define curCountry [PublicMethods getCurCountry]
//关于本地化
#define DTLocalizedString(key, comment) [LocalizationUtils DPLocalizedString:(key)]

#define font(a)   [UIFont systemFontOfSize:(a)]
#define rect(x, y, w, h)   CGRectMake(x, y, w, h)
#define size(w, h)   CGSizeMake(w, h)
#define point(x, y)   CGPointMake(x, y)


#define __TEST_MODE__ 0

#endif