//
//  DataPaser.m
//  IOS_Minimotor
//
//  Created by 李 乾 on 15/5/27.
//  Copyright (c) 2015年 Viatom. All rights reserved.
//

#import "DataPaser.h"

@implementation DataPaser

#define Coef_12mm  0.84//1.68//

#define originalValueTo_mV(a)   ((a*4033.0)/(32767.0*12))*1.05    //把原始数据转换成mV

+ (Packge *)paserMiniDataWithBuff:(NSData *)buff andType:(U8)type
{
    Packge *pkg = [[Packge alloc] init];
    
    U8 *p = (U8 *)buff.bytes;
    if (type == type_ECG || type == type_ECG_oxi) {
        
        U8 *p_ECG_Dis = &p[4];
        for (int i = 0; i < 10; i += 2) {
            
            short data = (p_ECG_Dis[i] & 0xFF) + ((p_ECG_Dis[i+1] & 0xFF) << 8);    //原始数据
            float value = originalValueTo_mV(data);   //转换成mV
            
//            DLog(@"ecg的原始值：%d", data );
            
            [pkg.ECG_Dis addObject:@(value)];
        }
        
        
        U16 HR = 0;
        U16 QRS = 0;
        U16 ST = 0;
        U16 PVC = 0;
        P2U16(&p[14], HR);
        P2U16(&p[16], QRS);
        P2U16(&p[18], ST);
        P2U16(&p[20], PVC);
        pkg.HR = HR;
        pkg.QRS = QRS;
        pkg.ST = ST;
        pkg.PVC = PVC;
        
        if (type == type_ECG) {   // 只有心电
            U8 other = p[24];
            if (other == 0xF1) {
                pkg.Battery = p[25];
            }
            
        } else {  //既有心电又有血氧
            U8 *p_OXI_Dis = &p[25];
            for (int i = 0; i < 10; i += 2) {
                int data = p_OXI_Dis[i] & 0xFF + ((p_OXI_Dis[i+1]&0xFF) << 8);
//                data = data * 3 / 5 + 110;   //新老数据转换
//                DLog(@"oxi原始数据：%d", data);
                [pkg.Oxi_Dis addObject:@(data)];
            }
            pkg.Oxi = p[37];
            U16 oxi_pr = 0;
            P2U16(&p[35], oxi_pr);
            pkg.Oxi_PR = oxi_pr;
            
            pkg.Oxi_PI = p[38];
            
            pkg.HRIdentity = p[22];
            
            pkg.SpO2Identity = p[39];
            
            if (p[41] == 0xF1) {
                pkg.Battery = p[42];
            }
//            DLog(@"----SpO2Identity:%d ----HRIdentity:%d",pkg.SpO2Identity,pkg.HRIdentity);
        }
        
    } else if (type == type_oxi) {    //只有血氧
        
        U8 *p_OXI_Dis = &p[4];
        for (int i = 0; i < 10; i += 2) {
            int data = p_OXI_Dis[i] & 0xFF + ((p_OXI_Dis[i+1]&0xFF) << 8);
//            data = data * 3 / 5 + 110;   //新老数据转换
            [pkg.Oxi_Dis addObject:@(data)];
        }
        
        pkg.Oxi = p[16];
        U16 oxi_pr = 0;
        P2U16(&p[14], oxi_pr);
        pkg.Oxi_PR = oxi_pr;
        
        pkg.Oxi_PI = p[17];
        
        if (p[20] == 0xF1) {
            pkg.Battery = p[21];
        }
    }
    
    return pkg;
}

@end
