//
//  BTDefines.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#ifndef Checkme_Mobile_BTDefines_h
#define Checkme_Mobile_BTDefines_h

/**
 *  fileType  for request listData through blueTooth
 */
#define FILE_Type_None 0x00
#define FILE_Type_UserList 0x01
#define FILE_Type_xuserList  0x0E
#define FILE_Type_SpotCheckList 0x0F
#define FILE_Type_BPCheckList 0x0A
#define FILE_Type_DailyCheckList 0x02
#define FILE_Type_EcgList 0x03
#define FILE_Type_SPO2List 0x05
#define FILE_Type_TempList 0x06
#define FILE_Type_SleepMonitorList 0x04
#define FILE_Type_PedList 0x0B
#define FILE_Type_RealaxList 0x08


/**
 *  FileType for request detailData through blueTooth
 */
#define FILE_Type_EcgDetailData 0x07
#define FILE_Type_ECGVoiceData 0x08
#define FILE_Type_SleepMonitorDetailData 0x09
#define FILE_Type_SpcDetailData 0x10
#define FILE_Type_SpcVoiceData 0x11

#define FILE_Type_Lang_Patch 0x0C
#define FILE_Type_App_Patch 0x0D


/**
 *  fileName for data reading and writing through blueTooth
 */
#define Hospital_Home_USER_LIST_FILE_NAME       @"xusr.dat"
#define SPC_LIST_FILE_NAME          @"%dspc.dat" //
#define Home_USER_LIST_FILE_NAME         @"*usr.dat"
#define ECG_LIST_FILE_NAME          @"%decg.dat"
#define ECG_LIST_FILE_SAVE_NAME          @"%@ecg*.dat"

#define SLM_LIST_FILE_NAME          @"slm.dat"
//#define DLC_LIST_FILE_NAME          @"%ddlc.dat"  //每日（原来）
#define DLC_LIST_FILE_NAME          @"%dbdc.dat" //新的 body
#define DLC_LIST_FILE_SAVE_NAME         @"%@bdc*.dat" //存放 body

#define SPO2_FILE_NAME          @"%doxi.dat"
#define BPCheck_FILE_NAME          @"bpcal.dat"
#define TEMP_FILE_NAME          @"%dtmp.dat"
#define PED_FILE_NAME          @"%dped.dat"   //
#define RELAXME_FILE_NAME          @"%dhrv.dat"  //relaxme

/**
 *  fileName for data storing to local place
 */
#define DLC_DATA_USER_TIME_FILE_NAME          @"%@_DLC_Data-%@-%@*" //
#define DLC_VOICE_DATA_USER_TIME_FILE_NAME    @"%@_DLC_Voice_Data-%@-%@*" //

#define ECG_DATA_USER_TIME_FILE_NAME          @"%@ECG_Data-%@-%@*"
#define ECG_VOICE_DATA_USER_TIME_FILE_NAME    @"%@ECG_Voice_Data-%@-%@*"

#define SPC_DATA_USER_TIME_FILE_NAME          @"%d_SPC_Data-%@-%@"     //
#define SPC_VOICE_DATA_USER_TIME_FILE_NAME    @"%d_SPC_Voice_Data-%@-%@"    //

#define SPO2_DATA_USER_TIME_FILE_NAME          @"%d_SPO2_Data-%@-%@"
#define SPO2_DATA_USER_TIME_FILE_SAVE_NAME     @"%@SPO2_Data-%@-%@*"


#define TEMP_DATA_USER_TIME_FILE_NAME          @"%dTEMP_Data-%@-%@"
#define TEMP_DATA_USER_TIME_FILE_SAVE_NAME     @"%@TEMP_Data-%@-%@*"

#define SLM_DATA_USER_TIME_FILE_NAME          @"SLM_Data-%@-%@"

#define PED_DATA_USER_TIME_FILE_NAME          @"%d_PED_Data-%@-%@"     //
#define PED_DATA_USER_TIME_FILE_SAVE_NAME     @"%@_PED_Data-%@-%@*"     //


#define RELAXME_DATA_USER_TIME_FILE_NAME          @"%d_RELAXME_Data-%@-%@"     //
#define RELAXME_DATA_USER_TIME_FILE_SAVE_NAME     @"%@_RELAXME_Data-%@-%@*"     //



//蓝牙 写
//#define START_WRITE_PKG_LENGTH 23
//#define START_WRITE_ACK_LENGTH 5
//#define WRITE_CONTENT_PKG_FRONT_LENGTH 6
#define WRITE_CONTENT_PKG_DATA_LENGTH 512
#define WRITE_CONTENT_ACK_LENGTH 5
//#define END_WRITE_PKG_LENGTH 4
//#define END_WRITE_ACK_LENGTH 5
//蓝牙 读
//#define COMMON_ACK_LENGTH 5
//#define START_READ_PKG_LENGTH 23
//#define START_READ_ACK_LENGTH 9
//#define READ_CONTENT_PKG_LENGTH 6
//#define READ_CONTENT_ACK_FRONT_LENGTH 6
#define READ_CONTENT_ACK_DATA_LENGTH 512
//#define END_READ_PKG_LENGTH 4
//#define END_READ_ACK_LENGTH 5
//蓝牙 删除数据
#define DEL_INFO_PKG_LENGTH 23
#define DEL_INFO_ACK_PKG_LENGTH 5
//蓝牙 获取设备信息
//#define GET_INFO_PKG_LENGTH 23
//#define GET_INFO_ACK_PKG_LENGTH 28
//蓝牙 文件名长
#define BT_WRITE_FILE_NAME_MAX_LENGTH 30
#define BT_READ_FILE_NAME_MAX_LENGTH 30
//蓝牙 命令字
#define CMD_WORD_START_WRITE  0x00
#define CMD_WORD_WRITE_CONTENT  0x01
#define CMD_WORD_END_WRITE  0x02
#define CMD_WORD_START_READ  0x03
#define CMD_WORD_READ_CONTENT  0x04
#define CMD_WORD_END_READ  0x05

#define CMD_WORD_START_LIST  0x07
#define CMD_WORD_LIST_CONTENT  0x08
#define CMD_WORD_END_LIST  0x09
#define CMD_WORD_DEL_INFO  0x0A

#define CMD_WORD_LANG_UPDATE_START 0x0A
#define CMD_WORD_LANG_UPDATE_DATA 0x0B
#define CMD_WORD_LANG_UPDATE_END 0x0C
#define CMD_WORD_APP_UPDATE_START 0x0D
#define CMD_WORD_APP_UPDATE_DATA 0x0E
#define CMD_WORD_APP_UPDATE_END 0x0F

#define CMD_WORD_GET_INFO  0x14
#define CMD_WORD_PING  0x15
#define CMD_WORD_ACK_PKG  0xFF
#define CMD_WORD_UPTIME  0x16


#define BT_STATUS_WAITING_NONE 0
#define BT_STATUS_WAITING_TRACE 11

#define BT_STATUS_WAITING_START_WRITE_ACK 1
#define BT_STATUS_WAITING_WRITE_CONTENT_ACK 2
#define BT_STATUS_WAITING_END_WRITE_ACK 3
#define BT_STATUS_WAITING_START_READ_ACK 4
#define BT_STATUS_WAITING_READ_CONTENT_ACK 5
#define BT_STATUS_WAITING_END_READ_ACK 6
#define BT_STATUS_WAITING_PING_ACK 7

#define BT_STATUS_WAITING_DEL_INFO_ACK 8
#define BT_STATUS_WAITING_GET_INFO_ACK 9
#define BT_STATUS_WAITING_UPDATA_TIME_ACK 10


#define BT_ERR_OK 0x0
#define BT_ERR_START_WRITE_OK 0x0
#define BT_ERR_START_WRITE_NO_SPACE 0x01
#define BT_ERR_START_WRITE_OPEN_FAILED 0x02
#define BT_ERR_START_WRITE_OTHERS (byte)0xFF

//新蓝牙通信协议
#define COMMON_PKG_LENGTH 8
#define COMMON_ACK_PKG_LENGTH 12
#define READ_CONTENT_ACK_PKG_FRONT_LENGTH 8
#define GET_INFO_ACK_PKG_LENGTH (COMMON_PKG_LENGTH + 256)
#define UPData_TIME_ACK_PKG_LENGTH 4


#define ACK_CMD_OK 0
#define ACK_CMD_BAD 1

//airtrace 参数
#define type_other       0x00
#define type_ECG         0x01
#define type_oxi         0x02
#define type_resp        0x03
#define type_art         0x04
#define type_ECG_oxi     0x05


#define LE_P2U16(p,u) do{u=0;u = (p)[0]|((p)[1]<<8);}while(0)

#define LE_P2U32(p,u) do{u=0;u = (p)[0]|((p)[1]<<8)|((p)[2]<<16)|((p)[3]<<24);}while(0)

#define BE_P2U16(p,u) do{u=0;u = ((p)[0]<<8)|((p)[1]);}while(0)
#define BE_P2U32(p,u) do{u=0;u = ((p)[0]<<24)|((p)[1]<<16)|((p)[2]<<8)|((p)[3]);}while(0)

#define P2U16(p,u) LE_P2U16((p),(u))
#define P2U32(p,u) LE_P2U32((p),(u))

#endif
