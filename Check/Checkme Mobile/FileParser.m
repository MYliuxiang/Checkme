//
//  FileParser.m
//  BTHealth
//
//  Created by demo on 13-11-4.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#import "FileParser.h"

#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)

#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))



@implementation FileParser


+(NSArray *)parseEcgList_WithFileData:(NSData *)data
{
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    //int dataLen = data.length;
    int dataLen = (int)data.length;
    
    for(int left = dataLen; left >= 10; left -= 10)
    {
        U8 *p  = bytes + dataLen - left;
        
        //ECG
        ECGInfoItem *ecgItem = [[ECGInfoItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        
        ecgItem.dtcDate = dtc;
        
        ecgItem.HR = p[7];
        if (ecgItem.HR < 30 || ecgItem.HR > 210) {
            ecgItem.HR = 0;
        }
        
        //        U8 leadKind = p[7];
        //        if(leadKind == 0x01)
        //            ecgItem.enLeadKind = kLeadKind_Hand;
        //        else if(leadKind == 0x02)
        //            ecgItem.enLeadKind = kLeadKind_Chest;
        //        else if(leadKind == 0x03)
        //            ecgItem.enLeadKind = kLeadKind_Wire;
        //        else if(leadKind == 0x04)
        //            ecgItem.enLeadKind = kLeadKind_Wire12;
        //
        U8 resultKind = p[8];
        if(resultKind == 0x00)
            ecgItem.enPassKind = kPassKind_Pass;
        else if(resultKind==0x01)
            ecgItem.enPassKind = kPassKind_Fail;
        else
            ecgItem.enPassKind = kPassKind_Others;
        
        U8 vioce = p[9];
        
        if(vioce == 0)
            ecgItem.bHaveVoiceMemo = NO;
        else
            ecgItem.bHaveVoiceMemo = YES;
        
        [arr addObject:ecgItem];
        
    }
    return arr;
}

+(NSArray *)parseDlcList_WithFileData:(NSData *)data
{
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = data.length;
    
    for(int left = dataLen; left >= 15; left -= 15)
    {
        U8 *p  = bytes + dataLen - left;
        
        //Dailycheck
        DailyCheckItem *dlcItem = [[DailyCheckItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        
        dlcItem.dtcDate = dtc;
        
        P2U16(&p[7], dlcItem.HR);
        if (dlcItem.HR < 30 || dlcItem.HR > 210) {
            dlcItem.HR = 0;
        }
        
        
        //        if(p[9] == 0x00)
        //            dlcItem.ECG_R = kPassKind_Pass;
        //        else if(p[9]==0x01)
        //            dlcItem.ECG_R = kPassKind_Fail;
        //        else
        //            dlcItem.ECG_R = kPassKind_Others;
        
        
        
        
        int value = p[9];
        //ImportantLog(@"%d", value);
        if (value == 0 || value == -1 || value == 255 || value < 60 || value > 100) {
            dlcItem.SPO2 = 0;
        } else {
            dlcItem.SPO2 = p[9];
            
        }
        
        
        
        dlcItem.BP_Flag = p[12];
        
        if (dlcItem.BP_Flag==0) {//Re,有符号
            NSLog(@"%d",p[13]);
            if (p[13]>=128) {
                dlcItem.BP = -((~p[13]+1)&0x7F);
            }else{
                dlcItem.BP = p[13];
            }
        }else{//Abs,无符号
            dlcItem.BP = p[13];
        }
        

        
        //        U8 pi = p[11];
        //        dlcItem.PI = pi/10.0;
        
        if(p[12] == 0x00)
            dlcItem.SPO2_R = kPassKind_Pass;
        else if(p[12] == 0x01)
            dlcItem.SPO2_R = kPassKind_Fail;
        else
            dlcItem.SPO2_R = kPassKind_Others;
        
        
        
        if(dlcItem.BP_Flag == 0)
        {
//            dlcItem.BP = p[13];
            dlcItem.RPP = 0;
//            if (dlcItem.BP <  -60 || dlcItem.BP > 60) {
//                dlcItem.BP = 0;
//            }
            
            if (p[13]>=128) {
                dlcItem.BP = -((~p[13]+1)&0x7F);
            }else{
                dlcItem.BP = p[13];
            }
            
        }
        else if(dlcItem.BP_Flag == -1 || dlcItem.BP_Flag == 255)
        {
            dlcItem.BP = 0;
            dlcItem.RPP = 0;
            
        } else
        {
            
            P2U16(&p[10], dlcItem.RPP);
            dlcItem.BP = p[13];
            
            if (dlcItem.BP < 60 || dlcItem.BP > 200 || dlcItem.HR == 0) {
                dlcItem.BP = 0;
                dlcItem.RPP = 0;
            }
            else
            {
                
                if (dlcItem.RPP < 3000 || dlcItem.RPP > 30000 || dlcItem.BP < 60 || dlcItem.BP > 200) {
                    dlcItem.RPP = 0;
                }
                
            }
            
        }
        
        int value1 = p[14];
        //ImportantLog(@"%d", value);
        if (value1 == 0 || value1 == -1 || value1 == 255 || value1 < 3 || value1 > 100) {
            
            dlcItem.RR = 0;
            
        } else {
            
            dlcItem.RR = p[14];
            
        }
        
        
        
//                int value1 =p[12];
//                ImportantLog(@"------%d-----------", value);
//                if(value1 < MIN_Resonable_SPO2_Value || value1 > MAX_Resonable_SPO2_Value)
//                {
////                    dlcItem.BP = 0;
//                    dlcItem.RPP = 0;
//                } else {
//                    P2U16(&p[10], dlcItem.RPP);
////                    dlcItem.BP = p[13];
//                }
        
        
        
        
        
        //目前该结果给的全是0x00
        //        if(p[15] == 0x00)
        //            dlcItem.BPI_R = kPassKind_Pass;
        //        else if(p[15] == 0x01)
        //            dlcItem.BPI_R = kPassKind_Fail;
        //        else
        //            dlcItem.BPI_R = kPassKind_Others;
        //
        //        U8 vioce = p[16];
        //
        //        if(vioce == 0)
        //            dlcItem.bHaveVoiceMemo = NO;
        //        else
        //            dlcItem.bHaveVoiceMemo = YES;
        
        [arr addObject:dlcItem];
        
        //        [dlcItem release];
    }
    
    return arr;
}

+(NSArray *)parseSLMList_WithFileData:(NSData *)data
{
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = data.length;
    
    
    for(int left = dataLen; left >= 18; left -= 18)
    {
        U8 *p  = bytes + dataLen - left;
        
        //Sleep monitor item
        SLMItem *slmItem = [[SLMItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        
        slmItem.dtcStartDate = dtc;
        
        P2U32(&p[7], slmItem.totalTime);
        
        P2U16(&p[11], slmItem.LO2Time);
        
        
        P2U16(&p[13], slmItem.LO2Count);
        
        slmItem.LO2Value = p[15];
        slmItem.AverageSpo2 = p[16];
        
        if(p[17] == 0x00)
            slmItem.enPassKind = kPassKind_Pass;
        else if(p[17] == 0x01)
            slmItem.enPassKind = kPassKind_Fail;
        else
            slmItem.enPassKind = kPassKind_Others;
        
        [arr addObject:slmItem];
        
    }
    
    return arr;
}

+(SLMItem_InnerData *)parseSLMData_WithFileData:(NSData *)data
{
    SLMItem_InnerData *innerData = [[SLMItem_InnerData alloc] init] ;
    
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = data.length;
    if (dataLen%2 != 0) {
        DLog(@"Sleep data is incomplete!");
    }
    else
    {
        for(int left = dataLen; left >= 2; left -= 2){
            U8 *p = bytes + dataLen - left;
            U8 oxValue = p[0];
            [innerData.arrOXValue addObject:@(oxValue)];
            
            U8 pluseVal = p[1];
            [innerData.arrPluseValue addObject:@(pluseVal)];
        }
    }
    return innerData;
}

//解析用户列表
+(NSArray *)parseUserList_WithFileData:(NSData *)data
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    
    unsigned char *bytes = (unsigned char*)data.bytes;
    int dataLen = data.length;   // 27*i
    
    for(int left = dataLen; left >= 46; left -= 46){  //一个用户占27个字节
        unsigned char *p = bytes + dataLen - left;
        
        User *aUser = [[User alloc] init];
        aUser.ID = p[0];
        
        char nameBuff[17] = {0x00};
        int i = 0 ;
        for(i=0;((char *)(p+1))[i] != '\0' && i < 16; ++i)
        {
            nameBuff[i] = ((char *)(p+1))[i];
        }
        nameBuff[i] = '\0';
        aUser.name = [NSString stringWithUTF8String:nameBuff];  //[NSString stringWithCString:(char *)(p+1) length:16];
        aUser.ICO_ID = p[17];
        aUser.gender = (p[18] == 0 ? kGender_FeMale:kGender_Male);
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[19], dtc.year);
        dtc.month = p[21];
        dtc.day = p[22];
        aUser.dtcBirthday = dtc;
        
        U16 w = 0,h=0;
        P2U16(&p[23], w);
        P2U16(&p[25], h);
        aUser.weight = (double)w / 10;
        aUser.height = (double)h;
        
        char medicalBuff[19] = {0x00};
        int a = 0 ;
        for(a= 0; ((char *)(p+28))[a] != '\0' && a < 18; ++a)
        {
            medicalBuff[a] = ((char *)(p+28))[a];
            NSLog(@"%c",p[26]);
        }
        medicalBuff[a] = '\0';
//        aUser.medical_id = [NSString stringWithUTF8String:medicalBuff];  //[NSString stringWithCString:(char *)(p+1) length:16];
        aUser.medical_id = [NSString stringWithFormat:@"%s",medicalBuff];
//        if(aUser.medical_id)
        
        
        
        [arr addObject:aUser];
    }
    DLog(@"  解析完毕！！！");
    return arr;
}

// xuser
+ (NSArray *) paserXusrList_WithFileData:(NSData *)data
{
    NSMutableArray *arrList = [NSMutableArray array];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLength = data.length;
    
    for (int i = dataLength; i >= 72; i -= 72) {
        Xuser *xUser = [[Xuser alloc] init];
        
        unsigned char *p = bytes +dataLength - i;
        
        xUser.userID = p[0];
        
        int k = 0;
        char p_ID[32+1] = {0x00};
        for (k= 0; ((char *)(p+1))[k] != '\0' && k < 32; ++k) {
            p_ID[k] = ((char *)(p+1))[k];
        }
        p_ID[k] = '\0';
        xUser.patient_ID = [NSString stringWithUTF8String:p_ID];
        
        int j = 0;
        char name[32+1] = {0x00};
        for (j = 0; ((char *)(p+33))[j] != '\0' && j < 32; ++j) {
            name[j] = ((char *)(p+33))[j];
        }
        name[j] = '\0';
        xUser.name = [NSString stringWithUTF8String:name];
        
        xUser.sex = p[65];
        xUser.unit = p[66];
        
        U16 h = 0, w = 0, a = 0;
        P2U16(&p[67], h);
        P2U16(&p[69], w);
        P2U16(&p[71], a);
        xUser.height = (double)h;
        xUser.weight = (double)w / 10;
        xUser.age = (int)p[71];
        
        [arrList addObject:xUser];
    }
    
    DLog(@"  解析完毕！！！");
    return arrList;
}
// spotCheck
+(NSArray *)paserSpotCheckList_WithFileData:(NSData *)data
{
    NSMutableArray *arr = [NSMutableArray array];
    unsigned char *bytes = (unsigned char *)data.bytes;     //bytes是一个地址
    int dataLength = data.length;
    
    for (int left = dataLength; left >= 24; left -= 24) {
        
        U8 *p = bytes + dataLength - left;     // 如果bytes在内存中的地址位置是2000，dataLength为48，则分别解析2000~2023和2024~2047地址范围的数据
        SpotCheckItem *spcItem = [[SpotCheckItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];    //等同于  *(p+2)   即p是首地址，在p上向前便宜2个字节的地址：(p+2)，在用*取这个地址上的值，p[2]有一个默认用*取值的过程，这是编译器规定的
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        
        spcItem.dtcDate = dtc;
        spcItem.dateStr = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d", dtc.year,dtc.month,dtc.day,dtc.hour,dtc.minute,dtc.minute];
        
        P2U16(&p[7], spcItem.func);
        if (spcItem.func == 0 || spcItem.func == 2 || spcItem.func == 4 || spcItem.func == 6)
        {
            spcItem.isNoHR = YES;
        }else {
            spcItem.isNoHR = NO;
        }
        
        
        if (spcItem.func == 0 || spcItem.func == 1 || spcItem.func == 4 || spcItem.func == 5){
            spcItem.isNoOxi = YES;
        }else {
            spcItem.isNoOxi = NO;
        }
        
        
        if (spcItem.func == 0 || spcItem.func == 1 || spcItem.func == 2 || spcItem.func == 3) {
            spcItem.isNoTemp = YES;
        }else {
            spcItem.isNoTemp = NO;
        }
        
        
        
        P2U16(&p[9], spcItem.HR);
        P2U16(&p[11], spcItem.QRS);
        P2U16(&p[13], spcItem.ST);
        U8 result = p[15];
        spcItem.ecgResult = [NSString stringWithFormat:@"%d", result];
        
        spcItem.oxi = p[17];
        if (spcItem.oxi >= 93)
            spcItem.oxi_R = kPassKind_Pass;
        else if (spcItem.oxi > 70)
            spcItem.oxi_R = kPassKind_Fail;
        else
            spcItem.oxi_R = kPassKind_Others;
        
        U8 pi = p[18];
        spcItem.PI = pi/10.0;
        
        P2U16(&p[20], spcItem.temp);
        
        U8 resultKind1 = p[16];    //Ecg Face
        if(resultKind1 == 0x00)
            spcItem.enECG_PassKind = kPassKind_Pass;
        else if(resultKind1==0x01)
            spcItem.enECG_PassKind = kPassKind_Fail;
        else
            spcItem.enECG_PassKind = kPassKind_Others;
        
        U8 resultKind2 = p[19];      //Oxi Face
        if(resultKind2 == 0x00)
            spcItem.enOxi_PassKind = kPassKind_Pass;
        else if(resultKind2==0x01)
            spcItem.enOxi_PassKind = kPassKind_Fail;
        else
            spcItem.enOxi_PassKind = kPassKind_Others;
        
        U8 resultKind3 = p[22];    //Temp Face
        if(resultKind3 == 0x00)
            spcItem.enTemp_PassKind = kPassKind_Pass;
        else if(resultKind3==0x01)
            spcItem.enTemp_PassKind = kPassKind_Fail;
        else
            spcItem.enTemp_PassKind = kPassKind_Others;
        
        U8 voice = p[23];
        if(voice == 0)
            spcItem.bHaveVoiceMemo = NO;
        else
            spcItem.bHaveVoiceMemo = YES;
        
        [arr addObject:spcItem];
    }
    return arr;
}
//spc_innerData
+ (spcInner_Data *)paserSpcInnerData_WithFileData:(NSData *)data
{
#define ECG_DATA2MV(data)  (4033.0*data/32767.0/12.0/8.0)
#define  ECG_NORMAL_MIN_VAL (-5.0f)
#define  ECG_NORMAL_MAX_VAL (5.0f)
#define ECG_CONTENT_SAMPLE_REATE 500 //采样率
#define ECG_DATA_HEADER_LEN 19;
    
    if (!data) {
        return nil;
    }
    spcInner_Data *innerData = [[spcInner_Data alloc] init];
    U8 *bytes = (U8 *)data.bytes;
    U8 *p = bytes;
    
    U16 hrLength;//心率字节数
    P2U16(&p[0], hrLength);
    innerData.timeLength = hrLength/2;//每个hr两个byte
    
    U32 ECG_CONTENT_NUM = (((innerData.timeLength * ECG_CONTENT_SAMPLE_REATE)/2)+1);
    U32 totalWantBytes = ECG_CONTENT_NUM*2 + hrLength + ECG_DATA_HEADER_LEN;
    if(data.length < totalWantBytes)
    {
        return nil;
    }
    
    
    bytes += ECG_DATA_HEADER_LEN;
    p = bytes;//seek头大小
    for(int i = 0 ; i < innerData.timeLength*2;i++)
    {
        U16 hr = 0;
        P2U16(&p[i*2],hr);
        NSNumber *num = [NSNumber numberWithShort:hr];
        [innerData.arrEcgHeartRate addObject:num];
    }
    
    
    //解析波形数据
    bytes += hrLength;//seek心率数据长度
    for(int i=0; i < ECG_CONTENT_NUM-1; ++i)
    {
        void (^adjustEcgValue)(double *) = ^(double *pVal)
        {
            if(*pVal > ECG_NORMAL_MAX_VAL)
                *pVal = ECG_NORMAL_MAX_VAL;
            if( *pVal < ECG_NORMAL_MIN_VAL)
                *pVal = ECG_NORMAL_MIN_VAL;
        };
        
        double  ecgVal_i=0,ecgVal_i_1=0,ecgVal_Insert=0;
        //取得第i个值
        p = bytes + (i * 2);
        short ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        
        ecgVal_i = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i);
        //取得第i+1个值
        p = bytes + ((i+1) * 2);
        ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        //        P2U16(p,ecgData );
        ecgVal_i_1 = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i_1);
        //计算插入值
        ecgVal_Insert = (ecgVal_i + ecgVal_i_1)/2.0;
        adjustEcgValue(&ecgVal_Insert);
        
        NSNumber *ecgNum = nil;
        if (i == 0) {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i];
            [innerData.arrEcgContent addObject:ecgNum];
        }
        
        ecgNum = [NSNumber numberWithDouble:ecgVal_Insert];
        [innerData.arrEcgContent addObject:ecgNum];
        
        if(i != (ECG_CONTENT_NUM-1-1))
        {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i_1];
            [innerData.arrEcgContent addObject:ecgNum];
        }
    }
    
    return innerData;
}


+(ECGInfoItem_InnerData *)parseEcg_WithFileData:(NSData *)data
{
#define ECG_DATA2MV(data)  (4033.0*data/32767.0/12.0/8.0)
#define  ECG_NORMAL_MIN_VAL (-5.0f)
#define  ECG_NORMAL_MAX_VAL (5.0f)
#define ECG_CONTENT_SAMPLE_REATE 500 //采样率
#define ECG_DATA_HEADER_LEN 19;
    
    if (!data) {
        return nil;
    }
    DLog(@"解析ECG数据文件");
    ECGInfoItem_InnerData *innerData = [[ECGInfoItem_InnerData alloc]  init];
    U8 *bytes  = (unsigned char *)data.bytes;
    U8 *p = bytes;
    
    U16 hrLength;//心率字节数
    P2U16(&p[0], hrLength);
    innerData.timeLength = hrLength/2;//每个hr两个byte
    
    U32 ECG_CONTENT_NUM = (((innerData.timeLength * ECG_CONTENT_SAMPLE_REATE)/2)+1);
    U32 totalWantBytes = ECG_CONTENT_NUM*2 + hrLength + ECG_DATA_HEADER_LEN;
    if(data.length < totalWantBytes)
    {
        return nil;
    }
    
    U32 waveLength;//心电波形字节数
    P2U32(&p[2], waveLength);
    P2U16(&p[6], innerData.HR);
    P2U16(&p[8], innerData.ST);
    P2U16(&p[10], innerData.QRS);
    P2U16(&p[12], innerData.PVCs);
    P2U16(&p[14], innerData.QTc);
    
    U8 result = p[16];
    innerData.ecgResultDescrib = [NSString stringWithFormat:@"%d", result];
    
    //测量模式和滤波模式
    if(p[17] == 0x01)
        innerData.enLeadKind = kLeadKind_Hand;
    else if(p[17] == 0x02)
        innerData.enLeadKind = kLeadKind_Chest;
    else if(p[17] == 0x03)
        innerData.enLeadKind = kLeadKind_Wire;
    else if(p[17] == 0x04)
        innerData.enLeadKind = kLeadKind_Wire12;
    
    if (p[18]==0x00) {
        innerData.enFilterKind = kFilterKind_Normal;
    }else if (p[18]==0x01){
        innerData.enFilterKind = kFilterKind_Wide;
    }
    
    bytes += ECG_DATA_HEADER_LEN;
    p = bytes;//seek头大小
    for(int i = 0 ; i < innerData.timeLength*2;i++)
    {
        U16 hr = 0;
        P2U16(&p[i*2],hr);
        NSNumber *num = [NSNumber numberWithShort:hr];
        [innerData.arrEcgHeartRate addObject:num];
    }
    
    NSData *data1 = [data subdataWithRange:NSMakeRange(21  + hrLength,data.length - 21 - hrLength )];
    NSString *str = [NSString stringWithFormat:@"%@",data1];
    NSString *str1 =  [str stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString *str2 =  [str1 stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *str3 =  [str2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    innerData.dataStr = str3;
    
    
    //解析波形数据
    bytes += hrLength;//seek心率数据长度
    for(int i=0; i < ECG_CONTENT_NUM-1; ++i)
    {
        void (^adjustEcgValue)(double *) = ^(double *pVal)
        {
            if(*pVal > ECG_NORMAL_MAX_VAL)
                *pVal = ECG_NORMAL_MAX_VAL;
            if( *pVal < ECG_NORMAL_MIN_VAL)
                *pVal = ECG_NORMAL_MIN_VAL;
        };
        
        double  ecgVal_i=0,ecgVal_i_1=0,ecgVal_Insert=0;
        //取得第i个值
        p = bytes + (i * 2);
        short ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        
        ecgVal_i = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i);
        //取得第i+1个值
        p = bytes + ((i+1) * 2);
        ecgData = ((p[0])|(p[1]<<8)) & 0xffff;
        //        P2U16(p,ecgData );
        ecgVal_i_1 = ECG_DATA2MV(ecgData);
        adjustEcgValue(&ecgVal_i_1);
        //计算插入值
        ecgVal_Insert = (ecgVal_i + ecgVal_i_1)/2.0;
        adjustEcgValue(&ecgVal_Insert);
        
        NSNumber *ecgNum = nil;
        if (i == 0) {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i];
            [innerData.arrEcgContent addObject:ecgNum];
        }
        
        ecgNum = [NSNumber numberWithDouble:ecgVal_Insert];
        [innerData.arrEcgContent addObject:ecgNum];
        
        if(i != (ECG_CONTENT_NUM-1-1))
        {
            ecgNum = [NSNumber numberWithDouble:ecgVal_i_1];
            [innerData.arrEcgContent addObject:ecgNum];
        }
    }
    return innerData;
}

+(NSArray *)parseBPCheck_WithFileData:(NSData *)data
{
    U8 *bytes = (U8 *)data.bytes;
    int dataLen = data.length;
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    
    if (dataLen%12 != 0) {
        return nil;
    }
    else
    {
        for(int left = dataLen;left >= 12; left -= 12)
        {
            U8 *p = bytes + dataLen - left;
            
            BPCheckItem *item = [[BPCheckItem alloc] init];
            
            item.userID = p[0];
            
            NSDateComponents *dtc = [[NSDateComponents alloc] init];
            P2U16(&p[1], dtc.year);
            dtc.month =  p[3];
            
            if(dtc.month < 1)
                dtc.month = 1;
            if(dtc.month > 12)
                dtc.month = 12;
            
            dtc.day =  p[4];
            dtc.hour =  p[5];
            dtc.minute =  p[6];
            dtc.second =  p[7];
            item.dtcDate = dtc;
            
            P2U16(&p[8], item.BPIndex);
            
            item.rPresure = p[10];
            item.cPresure = p[11];
            
            //            ImportantLog(@"BPIndex %d, rPresuer %d, cPresuer %d", item.BPIndex, item.rPresure, item.cPresure);
            
            
            [ret addObject:item];
            
            //            [item release];
        }
    }
    
    return ret;
}

+(NSArray *)parseGlucoseList_WithFileData:(NSData *)data
{
    
#define GLUCOSE_DATA2VALUE(data) ((double)data/10.0)//((((double)data)/10.0) * 18.0)
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    U8 *bytes = (U8 *)data.bytes;
    int dataLen = data.length;
    
    
    for(int left = dataLen;left >= 10; left -= 10)
    {
        U8 *p = bytes + dataLen - left;
        GlucoseInfoItem *item = [[GlucoseInfoItem alloc] init];
        item.measureMethod = p[0];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[1], dtc.year);
        dtc.month =  p[3];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[4];
        dtc.hour =  p[5];
        dtc.minute =  p[6];
        dtc.second =  p[7];
        item.dtcMeasureTime = dtc;
        //         [dtc release];
        
        U16 data = 0;
        P2U16(&p[8], data);
        double value = GLUCOSE_DATA2VALUE(data);
        //ImportantLog(@"%f", value);
        if(value < MIN_Resonable_Glucose_Value)
            value = MIN_Resonable_Glucose_Value;
        if(value > MAX_Resonable_Glucose_Value)
            value = MAX_Resonable_Glucose_Value;
        
        
        item.Glucose_Value =  value;
        
        [ret addObject:item];
        //         [item release];
    }
    
    return ret;
}


+(NSArray *)parseSPO2List_WithFileData:(NSData *)data
{
    
#define SPO2_DATA2VALUE(data) (((int)data))
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    U8 *bytes = (U8 *)data.bytes;
    int dataLen = data.length;
    
    
    for(int left = dataLen;left >= 12; left -= 12)
    {
        U8 *p = bytes + dataLen - left;
        SPO2InfoItem *item = [[SPO2InfoItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcMeasureTime = dtc;
        //        [dtc release];
        
        item.measureMethod = p[7];
        
        U8 data = p[8];
        int value = SPO2_DATA2VALUE(data);
        //ImportantLog(@"%d", value);
        if(value < MIN_Resonable_SPO2_Value)
            value = MIN_Resonable_SPO2_Value;
        if(value > MAX_Resonable_SPO2_Value)
            value = MAX_Resonable_SPO2_Value;
        item.SPO2_Value =  value;
        
        if (value < 60 || value > 100) {
            item.SPO2_Value = 0;
        }
        
        //        P2U16(&p[9], item.PR);
        item.PR = p[9];
        
        U8 pi = p[10];
        item.PI = pi/10.0;
        
        U8 resultKind = p[11];
        if(resultKind == 0x00)
            item.enPassKind = kPassKind_Pass;
        else if(resultKind == 0x01)
            item.enPassKind = kPassKind_Fail;
        else
            item.enPassKind = kPassKind_Others;
        
        
        [ret addObject:item];
        //        [item release];
    }
    
    return ret;
}



+(NSArray *)parseTempList_WithFileData:(NSData *)data
{
    
#define TEMP_DATA2VALUE(data) (((double)data)/10.0)
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    U8 *bytes = (U8 *)data.bytes;
    int dataLen = data.length;
    
    
    for(int left = dataLen;left >= 11; left -= 11)
    {
        U8 *p = bytes + dataLen - left;
        TempInfoItem *item = [[TempInfoItem alloc] init];
        //        item.measureMethod = p[1];
        
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcMeasureTime = dtc;
        //ImportantLog(@"Temp时间解析结果:%d-%02d-%02d %02d:%02d:%02d",dtc.year,dtc.month,dtc.day,dtc.hour,dtc.minute,dtc.second);
        //        [dtc release];
        
        item.measureMode = p[7];
        
        U16 data =  0;//(p[9] | p[10]<<8);
        P2U16(&p[8], data);
        double value = TEMP_DATA2VALUE(data);
        //ImportantLog(@"%f", value);
        item.PTT_Value =  value;
        if (value < 0 || value > 100) {
            item.PTT_Value = 0;
        }
        
        U8 result = p[10];
        if(result == 0x00)
            item.enPassKind = kPassKind_Pass;
        else if(result == 0x01)
            item.enPassKind = kPassKind_Fail;
        else
            item.enPassKind = kPassKind_Others;
        
        [ret addObject:item];
        //        [item release];
    }
    
    return ret;
}

//relaxme
+(NSArray *)parseRelaxMeList_WithFileData:(NSData *)data
{
    NSMutableArray *arr= [NSMutableArray arrayWithCapacity:10];
    unsigned char *bytes = (unsigned char *)data.bytes;
    int dataLen = data.length;
    
    for(int left = dataLen; left >= 11; left -= 11)
    {
        U8 *p  = bytes + dataLen - left;
        
        //Relax  Me
        RelaxMeItem *relaxmeItem = [[RelaxMeItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        
        P2U16(&p[0], dtc.year);
        dtc.month = p[2];
        if(dtc.month > 12)
            dtc.month = 12;
        if(dtc.month < 1)
            dtc.month = 1;
        dtc.day = p[3];
        dtc.hour = p[4];
        dtc.minute = p[5];
        dtc.second = p[6];
        
        relaxmeItem.dtcDate = dtc;
        relaxmeItem.hrv = p[7];
        relaxmeItem.Relaxation = p[8];
        
        if (relaxmeItem.hrv < 0 || relaxmeItem.hrv > 100) {
            relaxmeItem.hrv = 0;
        }
        
        if (relaxmeItem.Relaxation < 0 || relaxmeItem.Relaxation > 100) {
            relaxmeItem.Relaxation = 0;
        }
        
        P2U16(&p[9], relaxmeItem.timemiao);
        
        [arr addObject:relaxmeItem];
        
    }
    
    return arr;
}


+(NSArray *)parsePedList_WithFileData:(NSData *)data
{
#define PED_DATA2VALUE100(data) (((double)data)/100.0)
#define PED_DATA2VALUE10(data) (((double)data)/10.0)
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    U8 *bytes = (U8 *)data.bytes;
    int dataLen = data.length;
    
    for(int left = dataLen;left >= 29; left -= 29)
    {
        U8 *p = bytes + dataLen - left;
        PedInfoItem *item = [[PedInfoItem alloc] init];
        
        NSDateComponents *dtc = [[NSDateComponents alloc] init];
        P2U16(&p[0], dtc.year);
        dtc.month =  p[2];
        if(dtc.month < 1)
            dtc.month = 1;
        if(dtc.month > 12)
            dtc.month = 12;
        dtc.day =  p[3];
        dtc.hour =  p[4];
        dtc.minute =  p[5];
        dtc.second =  p[6];
        item.dtcMeasureTime = dtc;
        
        P2U32(&p[7], item.step);
        
        int length = 0;
        P2U32(&p[11], length);
        item.distance = PED_DATA2VALUE100(length);
        
        int speed = 0;
        P2U32(&p[15], speed);
        item.speed = PED_DATA2VALUE10(speed);
        
        int calorie = 0;
        P2U32(&p[19], calorie);
        item.calorie = PED_DATA2VALUE100(calorie);
        
        int fat = 0;
        P2U16(&p[23], fat);
        item.fat = PED_DATA2VALUE100(fat);
        
        P2U32(&p[25], item.totalTime);
        
        [ret addObject:item];
    }
    
    return ret;
}


@end
