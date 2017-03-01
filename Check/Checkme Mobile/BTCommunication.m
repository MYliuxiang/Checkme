//
//  BTCommunication.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/4/21.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "BTCommunication.h"

#import "StartReadPkg.h"
#import "StartReadAckPkg.h"
#import "CommonAckPkg.h"
#import "ReadContentPkg.h"
#import "ReadContentAckPkg.h"
#import "EndReadPkg.h"
#import "StartWritePkg.h"
#import "WriteContentPkg.h"
#import "EndWritePkg.h"
#import "GetInfoAckPkg.h"
#import "GetInfoPkg.h"
#import "PingPkg.h"
#import "UpdataTimePkg.h"
#import "GetUpDataTimePkg.h"

@interface BTCommunication ()
@property(nonatomic,strong) NSData* preSendBuf; //用于重发的buf

/**
 *  the dataPool used to store data from the blueTooth
 */
@property (nonatomic,retain) NSMutableData *dataPool;


@property (nonatomic,retain) NSMutableData *miniDataPool;

@property (nonatomic,retain) NSMutableData *miniPlaymoviceDataPool;

/**
 *  当前状态，用来区分接到包后做不同处理
 */
@property(nonatomic,assign) int curStatus;

/**
 *  临时读写文件
 */
@property (nonatomic,strong) FileToRead* temReadFile;


@end

@implementation BTCommunication

+ (BTCommunication *)sharedInstance
{
    static BTCommunication *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });//开启线程来实现这个方法
    
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        _dataPool = [NSMutableData data];
        _miniDataPool = [NSMutableData data];
        _miniPlaymoviceDataPool = [NSMutableData data];
    }
    return self;
}

#pragma mark - ping主机相关
- (void) BeginPing
{
    PingPkg * pkg = [[PingPkg alloc]init];
    if (!pkg) {
        return;
    }
    _curStatus = BT_STATUS_WAITING_PING_ACK;      // 7
    [self sendCmdWithData:pkg.buf Delay:500];
}


#pragma mark - 读文件相关
- (void)BeginReadFileWithFileName:(NSString *)fileName fileType:(U8)type
{
    StartReadPkg* pkg = [[StartReadPkg alloc]initWithFileName:fileName];
    if (!pkg) {
        [self readFailed];
        return;
    }
    
    _curReadFile = [[FileToRead alloc]init];
    _curReadFile.fileName = fileName;
    _curReadFile.fileType = type;
    
    _curStatus = BT_STATUS_WAITING_START_READ_ACK;
    [self sendCmdWithData:pkg.buf Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];   //5000s
}

- (void)readSuccess
{
    [self performSelectorOnMainThread:@selector(read_success) withObject:nil waitUntilDone:NO];
}
- (void)read_success
{
    [self.curReadFile setEnLoadResult:kFileLoadResult_Success];
    
    self.curStatus = BT_STATUS_WAITING_NONE;
    
    self.temReadFile = nil;
    self.temReadFile = self.curReadFile;
    
    self.curReadFile = nil;
    
    [self clearDataPool];
    
    if([self.delegate respondsToSelector:@selector(readCompleteWithData:)]) {
        [self.delegate readCompleteWithData:self.temReadFile];
        
    }
}
- (void)readFailed
{
    [self performSelectorOnMainThread:@selector(read_failed) withObject:nil waitUntilDone:NO];
}

#pragma mark ----- 这里改了一下 ------
- (void)read_failed
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self];//取消超时计时器
    //读失败统一发送超时错误
    [self.curReadFile setEnLoadResult:kFileLoadResult_TimeOut];
    
    self.curStatus = BT_STATUS_WAITING_NONE;
    
//    if (_temReadFile) {
//        _temReadFile = nil;
//    }
//    _temReadFile = [[FileToRead alloc] init];
//    _temReadFile = _curReadFile;
//    _curReadFile = nil;
//    [self clearDataPool];

    self.temReadFile = nil;
    self.temReadFile = self.curReadFile;
    
    self.curReadFile = nil;
    
    [self clearDataPool];
    DLog(@"响应包错误");
    if([self.delegate respondsToSelector:@selector(readCompleteWithData:)]) {
        [self.delegate readCompleteWithData:self.temReadFile];
        
    }
}


//读内容
- (void)readContent
{
    ReadContentPkg* pkg = [[ReadContentPkg alloc]initWithPkgNum:[_curReadFile curPkgNum]];
    if (pkg!=nil) {
        _curStatus = BT_STATUS_WAITING_READ_CONTENT_ACK;
        

        DLog(@"发送读内容命令包，等待包号 %d",_curReadFile.curPkgNum);

        
        [self sendCmdWithData: [pkg buf] Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];
    }
}
//读结束
- (void)endRead
{
    EndReadPkg* pkg = [[EndReadPkg alloc]init];
    if (pkg!=nil) {
        _curStatus = BT_STATUS_WAITING_END_READ_ACK;

        DLog(@"发送读结束命令包");

        [self sendCmdWithData:[pkg buf] Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];
    }
}

#pragma mark - 写文件相关
- (void)BeginWriteFile:(NSString *)fileName FileType:(U8)fileType andFileData:(NSData *)fileData
{
    _curReadFile = [[FileToRead alloc]initWithFileType:fileType];
    _curReadFile.fileName = fileName;
    _curReadFile.fileData = [fileData mutableCopy];
    if (_curReadFile.fileData==nil) {
        return;
    }
    _curReadFile.fileSize = _curReadFile.fileData.length;
    
    _curReadFile.lastPkgSize = _curReadFile.fileSize%WRITE_CONTENT_PKG_DATA_LENGTH;
    if (_curReadFile.lastPkgSize == 0) {//刚好整数包
        _curReadFile.totalPkgNum = _curReadFile.fileSize/WRITE_CONTENT_PKG_DATA_LENGTH;
        _curReadFile.lastPkgSize = WRITE_CONTENT_PKG_DATA_LENGTH + COMMON_PKG_LENGTH;
    }else{
        _curReadFile.totalPkgNum = _curReadFile.fileSize/WRITE_CONTENT_PKG_DATA_LENGTH + 1;
        _curReadFile.lastPkgSize += COMMON_PKG_LENGTH;
    }

    DLog(@"要发送的文件大小%d,总包数%d",_curReadFile.fileSize,_curReadFile.totalPkgNum);

    
    
    StartWritePkg* pkg;
    int delay;//超时时长
    
    if (_curReadFile.fileType == FILE_Type_Lang_Patch) {   //如果是语言包
        pkg = [[StartWritePkg alloc]initWithFileName:fileName fileSize:_curReadFile.fileSize cmd:CMD_WORD_LANG_UPDATE_START];
        delay = TIMEOUT_CMD_PATCHS_RESPOND_MS;
    }else if (_curReadFile.fileType == FILE_Type_App_Patch) {
        //如果是app包
        pkg = [[StartWritePkg alloc]initWithFileName:fileName fileSize:_curReadFile.fileSize cmd:CMD_WORD_APP_UPDATE_START];
        delay = TIMEOUT_CMD_PATCHS_RESPOND_MS;
    }else{
        //普通文件
        pkg = [[StartWritePkg alloc]initWithFileName:fileName fileSize:_curReadFile.fileSize cmd:CMD_WORD_START_WRITE];
        delay = TIMEOUT_CMD_GENERAL_RESPOND_MS;
    }
    
    if (!pkg) {
        [self writeFailed];
        return;
    }
    _curStatus = BT_STATUS_WAITING_START_WRITE_ACK;
    
#pragma mark - 执行底层读写函数
    [self sendCmdWithData:[pkg buf] Delay:delay];
}
//写内容，checkme 收到回应包后回调   此方法相当于NSURLConnectionDelegate 中的接收方法  是动态执行的
-(void)writeContent
{
    NSData* tempData;
    if (_curReadFile.curPkgNum<_curReadFile.totalPkgNum-1) {//不是最后一包
        NSRange range = {_curReadFile.curPkgNum*WRITE_CONTENT_PKG_DATA_LENGTH,WRITE_CONTENT_PKG_DATA_LENGTH};
        tempData = [_curReadFile.fileData subdataWithRange:(range)];
    }else if(_curReadFile.curPkgNum==_curReadFile.totalPkgNum-1){//最后一包
        NSRange range = {_curReadFile.curPkgNum*WRITE_CONTENT_PKG_DATA_LENGTH,_curReadFile.lastPkgSize - COMMON_PKG_LENGTH};
        tempData = [_curReadFile.fileData subdataWithRange:(range)];
    }else{//全部写完了
        DLog(@"全部写完了，调用endWrite 方法！");
        [self endWrite];
        return;
    }
    
    WriteContentPkg* pkg;
    int delay;//超时时长
    if (_curReadFile.fileType == FILE_Type_Lang_Patch) {
        //如果是语言包
        pkg = [[WriteContentPkg alloc]initWithBuf:tempData pkgNum:_curReadFile.curPkgNum cmd:CMD_WORD_LANG_UPDATE_DATA];
        delay = TIMEOUT_CMD_PATCHS_RESPOND_MS;
    }else if (_curReadFile.fileType == FILE_Type_App_Patch) {
        //如果是app包
        pkg = [[WriteContentPkg alloc]initWithBuf:tempData pkgNum:_curReadFile.curPkgNum cmd:CMD_WORD_APP_UPDATE_DATA];
        delay = TIMEOUT_CMD_PATCHS_RESPOND_MS;
    }else{
        //普通文件
        pkg = [[WriteContentPkg alloc]initWithBuf:tempData pkgNum:_curReadFile.curPkgNum cmd:CMD_WORD_WRITE_CONTENT];
        delay = TIMEOUT_CMD_GENERAL_RESPOND_MS;
    }
    
    if (!pkg) {
        DLog(@"创建写内容包失败");
        [self writeFailed];//写失败处理
        return;
    }
    
#pragma mark - 发送通知    用于下载界面更新写入进度条数据
    [self.delegate postCurrentWriteProgress:_curReadFile];
    
    
    _curReadFile.curPkgNum ++;
    _curStatus = BT_STATUS_WAITING_WRITE_CONTENT_ACK;
    _preSendBuf = [pkg buf];//用于重发
    [self sendCmdWithData:[pkg buf] Delay:delay];
}
//发送写结束命令
-(void)endWrite
{
    EndWritePkg* pkg;
    DLog(@"_curReadFile.curPkgNum = %d", _curReadFile.curPkgNum);
    
    
    if (_curReadFile.curPkgNum == _curReadFile.totalPkgNum) { //如果全部写完了
        if (_curReadFile.fileType == FILE_Type_Lang_Patch) { //如果是语言包
            pkg = [[EndWritePkg alloc]initWithCmd:CMD_WORD_LANG_UPDATE_END];
        }else if (_curReadFile.fileType == FILE_Type_App_Patch) { //如果是app包   特殊情况
            DLog(@"app包，直接调用writeSuccess!");
            [self writeSuccess];
            pkg = [[EndWritePkg alloc]initWithCmd:CMD_WORD_APP_UPDATE_END];
        }else{ //如果是普通文件
            pkg = [[EndWritePkg alloc]initWithCmd:CMD_WORD_END_WRITE];
        }
    } else { //如果没写完
        [self writeFailed];
//        _currentPeripheral = nil;
        self.peripheral = nil;
        
        return;
    }
    
    DLog(@"发送写结束命令包");
    _curStatus = BT_STATUS_WAITING_END_WRITE_ACK;
    
    [self sendCmdWithData:[pkg buf] Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];
}
- (void)writeSuccess
{
    //发送成功信息
    self.curStatus = BT_STATUS_WAITING_NONE;
    [self clearDataPool];
    if([self.delegate respondsToSelector:@selector(writeSuccessWithData:)]) {
        [self.delegate writeSuccessWithData:self.curReadFile];
    }
}
- (void)writeFailed
{
    self.curReadFile = nil;  //把当前读取的数据置为空
    self.curStatus = BT_STATUS_WAITING_NONE;
    [self clearDataPool];
    if([self.delegate respondsToSelector:@selector(writeFailedWithData:)]) {
         //发送失败信息
        [self.delegate writeFailedWithData:self.curReadFile];
    }
}


#pragma mark - 获取设备信息相关
- (void) BeginGetInfo
{
    DLog(@"发送获取设备信息命令包");
    GetInfoPkg *pkg = [[GetInfoPkg alloc]init];
    _curStatus = BT_STATUS_WAITING_GET_INFO_ACK;     // 9
    [self sendCmdWithData:pkg.buf Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];
}

#pragma mark - 更新设备时间
- (void) upDataTime
{
    DLog(@"发送更新设备时间命令包");
    UpdataTimePkg *pkg = [[UpdataTimePkg alloc] init];
    _curStatus = BT_STATUS_WAITING_UPDATA_TIME_ACK;
    [self sendCmdWithData:pkg.buf Delay:TIMEOUT_CMD_PATCHS_RESPOND_MS];


}


#pragma mark - 底层读写函数
//中心设备与外设之间通信   通过NSData类型数据进行通讯   cmd
-(void)sendCmdWithData:(NSData *)cmd Delay:(int)delay
{
    DLog(@"执行底层读写函数！！！");
    [self clearDataPool];
#ifndef BUF_LENGTH
#define BUF_LENGTH 132
#endif
    for (int i=0; i*BUF_LENGTH<cmd.length; i++) {
        NSRange range = {i*BUF_LENGTH,((i+1)*BUF_LENGTH)<cmd.length?BUF_LENGTH:cmd.length-i*BUF_LENGTH};
        NSData* subCMD = [cmd subdataWithRange:range];
        

        //写数据
        if (self.peripheral.state==CBPeripheralStateConnected) {
            //写特性值
            DLog(@"写特性值 Characteristic：%@", self.characteristic);
            [self.peripheral writeValue:subCMD forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(cmdTimeout) withObject:nil afterDelay:delay/1000.0];
    DLog(@"进入超时倒计时 共%f秒", delay/1000.0);
}

-(void)cmdTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    DLog(@"超时，终止");
    
    //判断当前状态
    if (_curStatus == BT_STATUS_WAITING_START_WRITE_ACK || _curStatus == BT_STATUS_WAITING_WRITE_CONTENT_ACK || _curStatus == BT_STATUS_WAITING_END_WRITE_ACK) {
        self.curStatus = BT_STATUS_WAITING_NONE;
        [self writeFailed];
    }else if (_curStatus == BT_STATUS_WAITING_START_READ_ACK || _curStatus == BT_STATUS_WAITING_READ_CONTENT_ACK || _curStatus == BT_STATUS_WAITING_END_READ_ACK) {
        self.curStatus = BT_STATUS_WAITING_NONE;
        [self readFailed];
    }else if (_curStatus == BT_STATUS_WAITING_PING_ACK) {
        self.curStatus = BT_STATUS_WAITING_NONE;
        if([self.delegate respondsToSelector:@selector(pingFailed)]) {
            [self.delegate pingFailed];
        }
    } else {
        
        [self writeFailed];//warning
    }
    
   
}

//接受到数据
-(void)didReceiveData:(NSData *)data
{
    if ([UserDefault boolForKey:@"ISAIRTRACE"]) {
        
        //airtrace 的解析
        _curStatus= BT_STATUS_WAITING_TRACE;
        
        if(data.length > 0)
        {
            [_miniDataPool appendData:data];
            
            int length;
            
            if (_miniDataPool.length > 3) {
                U8* h = (U8 *)data.bytes;
                if (h[0] != 0xA5 || h[1] != 0x5A) {  //如果包头错误
                    DLog(@"包头错误");
                    [_miniDataPool setLength:0];
                    return;
                } else{ //如果包头正确 解析包大小
                    length = h[2];
                }
            }
            if (data.length == 4) {
                
                
            }
            
            //包头正确解析包类型
            if (_miniDataPool.length % length == 0 && _miniDataPool.length != 0) {
                char type;
                U8 *p = (U8 *)data.bytes;
                type = p[3];   //检查第4个字节
                if (type == 0x01) {  //第一部分为心电
                    type = p[24];
                    if (type == 0x02) { ///表示既有心电又有血氧
                        
                        //解析
                        if ([DataArrayModel sharedInstance].isluzhi == YES) {
                            
                            Byte * resultByte = (Byte *)[data bytes];
                            NSString *hexStr=@"";
                            for(int i=0;i<[data length];i++)
                            {
                                NSString *newHexStr = [NSString stringWithFormat:@"%x",resultByte[i]&0xff];
                                ///16进制数
                                if([newHexStr length]==1)
                                    hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                                else
                                    hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
                            }
                            //                        NSLog(@"===========hexStr:%@",hexStr);
                            
                            [[DataArrayModel sharedInstance].dataMutableArray addObject:hexStr];
                            
                        }
                        
                        Packge *pkg = [DataPaser paserMiniDataWithBuff:data andType:type_ECG_oxi];
                        if ([_delegate respondsToSelector:@selector(realTimeCallBackWithPack:)]) {
                            [_delegate realTimeCallBackWithPack:pkg];

                        }
//                        [_delegate realTimeCallBackWithPack:pkg];
                        [_miniDataPool setLength:0];
                    } else { ///表示只有心电
                        
                        if ([DataArrayModel sharedInstance].isluzhi == YES) {
                            
                            Byte * resultByte = (Byte *)[data bytes];
                            NSString *hexStr=@"";
                            for(int i=0;i<[data length];i++)
                            {
                                NSString *newHexStr = [NSString stringWithFormat:@"%x",resultByte[i]&0xff];
                                ///16进制数
                                if([newHexStr length]==1)
                                    hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                                else
                                    hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
                            }
                            
                            
                            [[DataArrayModel sharedInstance].dataMutableArray addObject:hexStr];
                            
                        }
                        
                        Packge *pkg = [DataPaser paserMiniDataWithBuff:data andType:type_ECG];
                        [_delegate realTimeCallBackWithPack:pkg];
                        [_miniDataPool setLength:0];
                    }
                } else if (type == 0x02) { //第一部分为血氧
                    //表示只有血氧
                    //解析
                    if ([DataArrayModel sharedInstance].isluzhi == YES) {
                        
                        Byte * resultByte = (Byte *)[data bytes];
                        NSString *hexStr=@"";
                        for(int i=0;i<[data length];i++)
                        {
                            NSString *newHexStr = [NSString stringWithFormat:@"%x",resultByte[i]&0xff];
                            ///16进制数
                            if([newHexStr length]==1)
                                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
                            else
                                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
                        }
                        
                        [[DataArrayModel sharedInstance].dataMutableArray addObject:hexStr];
                        
                    }
                    Packge *pkg = [DataPaser paserMiniDataWithBuff:data andType:type_oxi];
                    [_delegate realTimeCallBackWithPack:pkg];
                    [_miniDataPool setLength:0];
                    
                } else if (type == 0xF1) {  //其他类型
                    
                }
                
            
            }
        }
    
    }else{
    if(_curStatus==BT_STATUS_WAITING_NONE)
        return;
    if(data.length > 0)
    {
        if(_curStatus != BT_STATUS_WAITING_TRACE){
        if (data.length > 3 || data.length <= 44) {
            U8* h = (U8 *)data.bytes;
            //判断是不是minimoter连接
            if (h[0] != 0xA5 || h[1] != 0x5A) {
                
                [self addDataToPool:data];
                [UserDefault setBool:NO forKey:@"ISAIRTRACE"];
                [UserDefault synchronize];
                //                return;
            }else{
                                 NSLog(@"-----连接了minimoter蓝牙");
                                _curStatus= BT_STATUS_WAITING_TRACE;
                [UserDefault setBool:YES forKey:@"ISAIRTRACE"];
                [UserDefault synchronize];
                [self.delegate isAirtrace];
                                 return;
                
            }
        }
        }
    }
    }
}


#pragma mark -----读取播放列表数据 -----------------------
- (void)didReceivePlayMoviceData:(NSData *)playMoviceData
{
    
    //    NSLog(@"===============================================%lu",(unsigned long)playMoviceData.length);
    
    if(playMoviceData.length > 0)
    {
        [_miniPlaymoviceDataPool appendData:playMoviceData];
        
        int length;
        
        if (_miniPlaymoviceDataPool.length > 3) {
            U8* h = (U8 *)playMoviceData.bytes;
            if (h[0] != 0xA5 || h[1] != 0x5A) {  //如果包头错误
                DLog(@"包头错误");
                [_miniPlaymoviceDataPool setLength:0];
                return;
            } else{ //如果包头正确 解析包大小
                length = h[2];
            }
        }
        
        
        //包头正确解析包类型
        if (_miniPlaymoviceDataPool.length % length == 0 && _miniPlaymoviceDataPool.length != 0) {
            char type;
            U8 *p = (U8 *)playMoviceData.bytes;
            type = p[3];   //检查第4个字节
            if (type == 0x01) {  //第一部分为心电
                type = p[24];
                if (type == 0x02) { ///表示既有心电又有血氧
                    Packge *pkg = [DataPaser paserMiniDataWithBuff:playMoviceData andType:type_ECG_oxi];
                    [_playMoviceDelegate realTimeCallBackWithPlaymovicePack:pkg];
                    [_miniPlaymoviceDataPool setLength:0];
                } else { ///表示只有心电
                    
                    
                    Packge *pkg = [DataPaser paserMiniDataWithBuff:playMoviceData andType:type_ECG];
                    [_playMoviceDelegate realTimeCallBackWithPlaymovicePack:pkg];
                    [_miniPlaymoviceDataPool setLength:0];
                }
            } else if (type == 0x02) { //第一部分为血氧
                //表示只有血氧
                //解析
                Packge *pkg = [DataPaser paserMiniDataWithBuff:playMoviceData andType:type_oxi];
                [_playMoviceDelegate realTimeCallBackWithPlaymovicePack:pkg];
                [_miniPlaymoviceDataPool setLength:0];
                
            } else if (type == 0xF1) {  //其他类型
                
            }
        }
    }
}



-(void)addDataToPool:(NSData *)data            //  动态执行
{
    [_dataPool appendData:data];
    unsigned long dataLen = _dataPool.length;
    
    if(dataLen<[self calWantBytes]){  //蓝牙数据池的数据长度 小于回应包的长度
        return;
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self processAckBuf:_dataPool];
        
        [self clearDataPool];
    }
}

-(void)clearDataPool
{
    DLog(@"clear data pool！");
    [_dataPool setLength:0];
}

-(U32)calWantBytes    //获取回应包的长度
{
    switch (_curStatus) {
        case BT_STATUS_WAITING_START_READ_ACK:
            return COMMON_ACK_PKG_LENGTH;
            
        case BT_STATUS_WAITING_READ_CONTENT_ACK:
            if (_curReadFile.curPkgNum==_curReadFile.totalPkgNum-1) {
                return _curReadFile.lastPkgSize;
            }else{
                return READ_CONTENT_ACK_PKG_FRONT_LENGTH + READ_CONTENT_ACK_DATA_LENGTH;
            }
            
        case BT_STATUS_WAITING_END_READ_ACK:
            return COMMON_ACK_PKG_LENGTH;
        case BT_STATUS_WAITING_START_WRITE_ACK:
            return COMMON_ACK_PKG_LENGTH;
        case BT_STATUS_WAITING_WRITE_CONTENT_ACK:
            return COMMON_ACK_PKG_LENGTH;
        case BT_STATUS_WAITING_END_WRITE_ACK:
            return COMMON_ACK_PKG_LENGTH;
        case BT_STATUS_WAITING_GET_INFO_ACK:
            return GET_INFO_ACK_PKG_LENGTH;
        case BT_STATUS_WAITING_UPDATA_TIME_ACK:
            return UPData_TIME_ACK_PKG_LENGTH;
        default:
            return 0;
    }
}

#pragma mark - checkme回应包
-(void)processAckBuf:(NSData*)buf
{
    DLog(@"进入到processAckBuf方法！！！");
    switch (_curStatus) {
        case BT_STATUS_WAITING_PING_ACK: {     //  7
            CommonAckPkg* cap = [[CommonAckPkg alloc]initWithBuf:buf];
            if (cap!=nil && [cap cmdWord]==ACK_CMD_OK) {
                DLog(@"接收到ping主机回应包： Ping成功");
                
                self.curStatus = BT_STATUS_WAITING_NONE;     // 0
                if([self.delegate respondsToSelector:@selector(pingSuccess)]) {
                    [self.delegate pingSuccess];
                }
                [self clearDataPool];
            }else{
                //后续处理
                DLog(@"Ping失败");
                self.curStatus = BT_STATUS_WAITING_NONE;
              
                if([self.delegate respondsToSelector:@selector(pingFailed)]) {
                    [self.delegate pingFailed];
                }
                [self clearDataPool];
            }
            DLog(@"ping主机相关回应包全部处理完成！");
            break;
            
        }
            break;
        case BT_STATUS_WAITING_START_READ_ACK:{     //  4
            DLog(@"接收到读开始响应包");
            StartReadAckPkg * srap = [[StartReadAckPkg alloc]initWithBuf:buf];
            if (srap!=nil&&[srap cmdWord] == ACK_CMD_OK) {
                if ([srap fileSize]<=0) {
                    DLog(@"文件大小错误,终止读");
                    [self readFailed];
                }else{
                    [self setCurReadFileVals: [srap fileSize]];
                    DLog(@"开始读内容");
                    [self readContent];
                }
            }else{
                //后续处理
                DLog(@"响应包错误,文件可能不存在");
                [self readFailed];
            }
            break;
        }
        case BT_STATUS_WAITING_READ_CONTENT_ACK:{
            DLog(@"接收到读内容响应包");
            ReadContentAckPkg* rcap = [[ReadContentAckPkg alloc]initWithBuf:buf];
            if (rcap!=nil) {
                //追加到当前文件尾部
                [_curReadFile.fileData appendData:[rcap dataBuf]];
                _curReadFile.curPkgNum ++;
                
#pragma mark - 读内容进度条更新   如从checkme下载详细数据时 会用到下载进度
                //抛出进度条更新
//             [self.delegate postCurrentReadProgress:(double)_curReadFile.curPkgNum/(double)_curReadFile.totalPkgNum];
               
                if([self.delegate respondsToSelector:@selector(postCurrentReadProgress:)]) {
                    
                    [self.delegate postCurrentReadProgress:(double)_curReadFile.curPkgNum/(double)_curReadFile.totalPkgNum];
                }
 
               if (_curReadFile.curPkgNum == _curReadFile.totalPkgNum) {//已读完最后一包
                    [self endRead];
                }else{
                    [self readContent];
                }
            }else{
                //创建包错误，或许处理
                DLog(@"响应包错误");
                [self readFailed];
            }
            break;
        }
        case BT_STATUS_WAITING_END_READ_ACK:{
            DLog(@"接收到读结束响应包");
            CommonAckPkg* cap = [[CommonAckPkg alloc]initWithBuf:buf];
            if (cap!=nil&&[cap cmdWord] == ACK_CMD_OK) {
                //读结束后处理
                [self readSuccess];
            }else{
                //后续处理
                [self readFailed];
            }
            break;
        }
            
#pragma mark - 写入相关
        case BT_STATUS_WAITING_START_WRITE_ACK:{     //  1
            DLog(@"接收到写开始响应包");
            CommonAckPkg* cap = [[CommonAckPkg alloc]initWithBuf:buf];
            if (cap!=nil&&[cap cmdWord] == ACK_CMD_OK) {
                
                DLog(@"回应包数据：cap = %@ ", cap);
                [self writeContent];
            }else{
                DLog(@"响应包错误");
                [self writeFailed];
            }
            break;
        }
        case BT_STATUS_WAITING_WRITE_CONTENT_ACK:{
            DLog(@"接收到写内容响应包");
            CommonAckPkg* cap = [[CommonAckPkg alloc]initWithBuf:buf];
            if (cap!=nil && [cap cmdWord]==ACK_CMD_OK) {
                [self writeContent];
            }else{
                DLog(@"响应包错误");
                //如果是第一次错误，则重发，否则写失败
                if (_preSendBuf) {
                    DLog(@"重发");
                    [self sendCmdWithData:_preSendBuf Delay:TIMEOUT_CMD_GENERAL_RESPOND_MS];
                    _preSendBuf = nil;
                }else{
                    [self writeFailed];
                }
            }
            break;
        }
        case BT_STATUS_WAITING_END_WRITE_ACK:{
            DLog(@"接收到写结束响应包");
            CommonAckPkg* cap = [[CommonAckPkg alloc]initWithBuf:buf];
            if (cap!=nil && [cap cmdWord]==ACK_CMD_OK) {
                DLog(@"写文件完成");
                [self writeSuccess];
            }else{
                //后续处理
                DLog(@"响应包错误");
                [self writeFailed];
            }
            break;
        }
        case BT_STATUS_WAITING_GET_INFO_ACK:{    //  9
            GetInfoAckPkg *giap = [[GetInfoAckPkg alloc]initWithBuf:buf];
            if (giap!=nil && [giap cmdWord]==ACK_CMD_OK) {
                
                DLog(@"读取设备信息完成");
                self.curStatus = BT_STATUS_WAITING_NONE;      // 0
                if([self.delegate respondsToSelector:@selector(getInfoSuccessWithData:)]) {
                    
                    [self.delegate getInfoSuccessWithData:giap.infoData];
                }
            
            }else{
                DLog(@"读取设备信息错误");
                self.curStatus = BT_STATUS_WAITING_NONE;      // 0
               
                if([self.delegate respondsToSelector:@selector(getInfoFailed)]) {
                    
                    [self.delegate getInfoFailed];
                }
            }
            DLog(@"读取设备信息相关的回应包已完成！");
        }
            break;
          //同步时间
        case BT_STATUS_WAITING_UPDATA_TIME_ACK:{
        
            GetUpDataTimePkg *giap = [[GetUpDataTimePkg alloc]initWithBuf:buf];
            if (giap!=nil && [giap cmdWord]==ACK_CMD_OK) {
                
                DLog(@"更新时间操作成功");
                self.curStatus = BT_STATUS_WAITING_NONE;      // 0
                if([self.delegate respondsToSelector:@selector(updataTimeSuccess)]) {
                    
                    [self.delegate updataTimeSuccess];
                }
                
            }else{
                DLog(@"更新时间错误");
                self.curStatus = BT_STATUS_WAITING_NONE;      // 0
                
                if([self.delegate respondsToSelector:@selector(updataTimeFailed)]) {
                    
                    [self.delegate updataTimeFailed];
                }
            }
            DLog(@"更新时间操作完成！");
        
        }
            break;
        default:
            break;
    }
    
}

-(void)setCurReadFileVals:(U32)fileSize
{
    DLog(@"获取_curReadFile的相关属性");
    if (!_curReadFile) {
        DLog(@"调用错误，_curReadFile未初始化");
        [self readFailed];
        return;
    }
    if(fileSize<=0){
        return;
    }
    _curReadFile.fileData = [NSMutableData data];
    _curReadFile.curPkgNum = 0;
    _curReadFile.fileSize = fileSize;
    _curReadFile.lastPkgSize = fileSize%READ_CONTENT_ACK_DATA_LENGTH;
    if (_curReadFile.lastPkgSize == 0) {//刚好整数包
        _curReadFile.totalPkgNum = fileSize/READ_CONTENT_ACK_DATA_LENGTH;
        _curReadFile.lastPkgSize = READ_CONTENT_ACK_DATA_LENGTH + READ_CONTENT_ACK_PKG_FRONT_LENGTH;
    }else{
        _curReadFile.totalPkgNum = fileSize/READ_CONTENT_ACK_DATA_LENGTH + 1;
        _curReadFile.lastPkgSize += READ_CONTENT_ACK_PKG_FRONT_LENGTH;
    }
    DLog(@"要接受的文件大小%d,总包数%d",_curReadFile.fileSize,_curReadFile.totalPkgNum);
}

-(BOOL)bLoadingFileNow
{
    return  self.curReadFile != nil;
}

-(FileType_t)curLoadFileType
{
    if(![self bLoadingFileNow])
    {
        return  FILE_Type_None;
    } else
        return _curReadFile.fileType;
}
@end


@implementation FileToRead

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//传入不同文件种类，可以是普通文件或者升级包
- (instancetype)initWithFileType:(U8)fileType
{
    self = [super init];
    if (self) {
        _fileType = fileType;
    }
    return self;
}

+(NSString *)descOfFileType:(FileType_t)kind
{
    NSString *desc = @"";
    switch (kind) {
        case FILE_Type_None:
            desc = @"None";
            break;
        case FILE_Type_UserList:
            desc = @"User list file";
            break;
        case FILE_Type_EcgList:
            desc = @"ECG file list";
            break;
        case FILE_Type_EcgDetailData:
            desc = @"ECG data files";
            break;
        default:
            break;
    }
    return desc;
}

-(NSString *)loadStateDesc
{
    //    NSString *fileDesc = [FileToRead descOfFileType:_fileType];
    NSString *result = @"";
    switch (_enLoadResult) {
        case kFileLoadResult_Fail:
            result = @"Data load failed";
            break;
        case kFileLoadResult_Success:
            result = @"Data load success";
            break;
        case kFileLoadResult_TimeOut:
            result = @"Data load timeout";
            break;
        case kFileLoadResult_NotExist:
            result = @"Data is not exist";
            break;
        default:
            break;
    }
    
    NSString *desc = [NSString stringWithFormat:@"%@",result];
    return desc;
}
@end
