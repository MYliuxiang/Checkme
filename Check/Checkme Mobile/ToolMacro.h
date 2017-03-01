//
//  ToolMacro.h
//  hipal
//
//  Created by demo on 13-8-28.
//
//

//该文件放置所有的自定义工具宏，以便于以后移植到其它项目

#ifndef hipal_ToolMacro_h
#define hipal_ToolMacro_h

//两个NSString字符串是否相等 
#define STR_EQU(strA,strB) ([(strA) isEqualToString:(strB)])
//两个c风格字符串是否相等 
#define C_STR_EQU(c_strA,c_strB) (strcmp(c_strA,c_strB)==0)
//一个整数是否是偶数
#define EVEN_NUMBER(n) ((n%2)== 0)

//两个REct是否相等 
#define RECT_EQU(R_1 , R_2) (\
(R_1.origin.x == R_2.origin.x) &&\
(R_1.origin.y == R_2.origin.y) &&\
(R_1.size.width == R_2.size.width) &&\
(R_1.size.height == R_2.size.height))


#define IPHONE_COMMAN_SCREEN_H 480.0
#define IPHONE_5_SCREEN_H 568.0
#define DEVICE_IS_IPHONE_5() ([[UIScreen mainScreen] bounds].size.height == 568)
#define IPHONE_COMMAN_VIEW_H(bTabShow,bNavShow) (IPHONE_COMMAN_SCREEN_H - (20 + (bNavShow?44:0) + (bTabShow?49:0)))
#define IPHONE_5_VIEW_H(bTabShow,bNavShow)      (IPHONE_5_SCREEN_H - (20 + (bNavShow?44:0) + (bTabShow?49:0)))
#define CUR_SCREEN_H ([[UIScreen mainScreen] bounds].size.height)  //获取屏幕的高度
#define CUR_SCREEN_W ([[UIScreen mainScreen] bounds].size.width)   //获取屏幕的宽度


//设置颜色RGB值
#define COLOR_RGB(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define COMMAN_POPUP_BG_COLOR  COLOR_RGB(0,0,0,.3)
//a除以b
#define A_DIV_B(a,b) ((b) <= 0 ? (a) : (a)/(b))

#define NO_PARAM_BY(nil)

#define NO_PARAM_INT                    LONG_MAX //参数值为0xffff时表示没有这个参数（参数要为正数）
#define NO_PARAM_OBJ                    nil//[NSNull null]//指针类型为[NSNull null]，表示没有这个参数




/*
 从客户端请求参数转化hessian参数的宏,转化类型如不够，则需要增加
 */

//整形转化为字符串,请求专用转化
#define INT_TO_STR(a)   ((a) == NO_PARAM_INT ? NO_PARAM_OBJ : [NSString stringWithFormat:@"%d",((NSInteger)a)])

//NSInteger ---> NSInteger * b
#define INT_TO_INT(a,b)   ((a) == NO_PARAM_INT ? NO_PARAM_INT : (a)*(b))

//NSString ---> NSInteger
#define STR_TO_INT(s)   ((s) == NO_PARAM_OBJ ? NO_PARAM_INT : [(s) integerValue])

//NSDateComponents ---> NSString
#define DATECOMP_TO_STR(comp)  ((comp) == NO_PARAM_OBJ ? NO_PARAM_OBJ : [NSDate dateDescFromDateComp:(comp)])

//NSDate ---> NSString
#define DATE_TO_STR(date,format) ((date) == NO_PARAM_OBJ ? NO_PARAM_OBJ : [NSDate stringFromDate:(date) formatterStr:format])


/*
 从Hessian转化成服务器参数方法，
 */

//指针参数转化
#define MAKE_DIC_OBJ(dic,obj,key)   if ((obj) != NO_PARAM_OBJ && (obj)) {\
[dic setObject:obj forKey:key];\
}
//整形参数转化
#define MAKE_DIC_INT(dic,int,key)   if ((int) != NO_PARAM_INT) {\
[dic setObject:[NSNumber numberWithInteger:int] forKey:key];\
}


/*
 从客户端请求参数转化hessian参数的宏,转化类型如不够，则需要增加
 */
//整形转化为字符串,请求专用转化
#define INT_TO_STR(a)   ((a) == NO_PARAM_INT ? NO_PARAM_OBJ : [NSString stringWithFormat:@"%d",((NSInteger)a)])

//NSInteger ---> NSInteger * b
#define INT_TO_INT(a,b)   ((a) == NO_PARAM_INT ? NO_PARAM_INT : (a)*(b))

//NSString ---> NSInteger
#define STR_TO_INT(s)   ((s) == NO_PARAM_OBJ ? NO_PARAM_INT : [(s) integerValue])

//NSDateComponents ---> NSString
#define DATECOMP_TO_STR(comp)  ((comp) == NO_PARAM_OBJ ? NO_PARAM_OBJ : [NSDate dateDescFromDateComp:(comp)])

//NSDate ---> NSString
#define DATE_TO_STR(date,format) ((date) == NO_PARAM_OBJ ? NO_PARAM_OBJ : [NSDate stringFromDate:(date) formatterStr:format])



/*
 将Hessian响应转化成客户端数据方法
 */
//id ---> NSString
#define STR_BY_DIC(dic,key,obj)     {id s = [dic objectForKey:key];\
if(s) {\
if ([s isKindOfClass:([NSString class])]) { \
(obj) = s;\
} \
else if ([s isKindOfClass:([NSNumber class])]) {\
(obj) = [NSString stringWithFormat:@"%d",[s integerValue]]; \
}\
}}
//NSString ---> NSDateComponents
#define DATE_BY_DIC(dic,key,comp)   {NSString *s = [dic objectForKey:key];\
if(s) {\
(comp) = [NSDate dateCompFromString:s];\
}}
// NSNumber ---> NSInteger
#define INT_BY_DIC(dic,key,value)   {NSNumber *d = [dic objectForKey:key];\
if(d) {\
(value) = [d integerValue];\
}}

//NSNumber ---> NSInteger/div
#define INT_BY_DIC_DIV(dic,key,value,div)   {NSNumber *d = [dic objectForKey:key];\
if(d) {\
(value) = [d integerValue]/(div);\
}}

//NSNumber ---> long
#define LONG_BY_DIC(dic,key,long)   { NSNumber *l = [dic objectForKey:key];\
if(l) {\
(long) = [l longValue];\
}}



//国际化加载字符串
#define LoadLocalizedString(key) [[InternationalControl bundle] localizedStringForKey:key value:nil table:@"Localization"]//DTLocalizedStringFromTable(key, @"Localization",@"") 



#define  AdjustFramOfImageView(imgv,imgSize) \
{\
    double h_inter = (imgv).frame.size.height - (imgSize).height;\
    double y = 0;\
    if(h_inter > 0){\
    y = (imgv).frame.origin.y+(h_inter/2.0);\
    }\
    else{\
    y = (imgv).frame.origin.y;\
    }\
    (imgv).frame = CGRectMake((imgv).frame.origin.x ,y, (imgSize).width, (imgSize).height);\
}


#define ADD_OFFSETTO_FRAM_OFVIEW(theView,off_x,off_y,off_w,off_h)  do{\
    theView.frame = CGRectMake(theView.frame.origin.x + off_x, theView.frame.origin.y + off_y, \
    theView.frame.size.width + off_w, theView.frame.size.height + off_h);\
}while(0)

#define SET_FRAME_OF_VIEW(theView,x,y,w,h) do\
{\
    theView.frame = CGRectMake(x, y,w, h);\
}while(0)

#define AdjustTiteLabel_ValueView(title_lbel,value_view) do{\
    double t_w = [PublicMethods widthOfString:(title_lbel).text withFont:(title_lbel).font\
    maxHeight:(title_lbel).frame.size.height];\
    double dec = t_w - (title_lbel).frame.size.width;\
    if(dec > 0){\
    ADD_OFFSETTO_FRAM_OFVIEW(title_lbel, 0, 0, dec, 0);\
    ADD_OFFSETTO_FRAM_OFVIEW((value_view),dec,0,(-dec),0);\
    }\
}while(0)

#define AdjustViewToFllowLabel(lbl,max_lbl_w,the_view) do{\
    double w = [PublicMethods widthOfString:lbl.text withFont:lbl.font maxHeight:lbl.frame.size.height];\
    if(w > max_lbl_w)\
    w = max_lbl_w;\
    double dec = w - lbl.frame.size.width;\
    ADD_OFFSETTO_FRAM_OFVIEW(lbl, 0, 0, dec, 0);\
    the_view.frame = CGRectMake(lbl.frame.origin.x+lbl.frame.size.width + 5, the_view.frame.origin.y, the_view.frame.size.width, the_view.frame.size.height);\
}while(0)

#define AdjustAColumOfViewToMostRight(viewArr) do{\
    double mostRightX = 0.0;\
    for(UIView *v in viewArr){\
        if(v.frame.origin.x > mostRightX)\
            mostRightX = v.frame.origin.x;\
        }\
        for(UIView *v in viewArr){\
        double dec = v.frame.origin.x - mostRightX;\
        if(dec < 0){\
            ADD_OFFSETTO_FRAM_OFVIEW(v, (-1*dec), 0, dec, 0);\
        }\
    }\
}while(0)

#define OBJ_ISKIND_CLASS(obj,theClass) [obj isKindOfClass:[theClass class]]

#endif
