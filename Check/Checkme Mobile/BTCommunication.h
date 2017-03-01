//
//  BTCommunication.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/4/21.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTDefines.h"
#import "TypesDef.h"
#import "DataArrayModel.h"
#import "Packge.h"
#import "DataPaser.h"

#define  TIMEOUT_CMD_GENERAL_RESPOND_MS 5000.0 //普通文件超时
#define  TIMEOUT_CMD_PATCHS_RESPOND_MS 80000.0 //升级包超时
typedef U8 FileType_t;

/**
 FileLoadResult
 */
typedef  enum
{
    kFileLoadResult_Success,
    kFileLoadResult_TimeOut,
    kFileLoadResult_Fail,
    kFileLoadResult_NotExist
}FileLoadResult_t;

@class FileToRead;

@protocol BTCommunicationDelegate <NSObject>
///ping hosts successfully
@optional
- (void)pingSuccess;//ping 成功时

///ping hosts failed
@optional
- (void)pingFailed;  //ping 失败时


/**
 *  Send the current progress of reading
 *
 *  @param progress  progress value
 */
@required
- (void)postCurrentReadProgress:(double)progress;

/**
 *  Read file complete
 */
@optional
- (void)readCompleteWithData:(FileToRead *)fileData;

/**
 *  Send the current progress of writing
 *
 *  @param progress the data been written currently
 */
@required
- (void)postCurrentWriteProgress:(FileToRead *)fileData;

/**
 *  Write file successfully
 *
 *  @param fileData the data been written complete
 */
@optional
-(void)writeSuccessWithData:(FileToRead *)fileData;

/**
 *  Write file failed
 *
 *  @param fileData the data been written complete
 */
@optional
-(void)writeFailedWithData:(FileToRead *)fileData;
/**
 *  Get device information successfully
 */
@optional
-(void)getInfoSuccessWithData:(NSData *)data;

/// Get device information failed
@optional
-(void)getInfoFailed;


//airtrace 代理方法
- (void) realTimeCallBackWithPack:(Packge *)pkg;

- (void) isAirtrace;

/**
 *  UPData time for device  successfully
 */
@optional
-(void)updataTimeSuccess;



/// UPData time for device failed
@optional
-(void)updataTimeFailed;


@end

@protocol BTCommunicationPlayMoviceDelegate <NSObject>

- (void) realTimeCallBackWithPlaymovicePack:(Packge *)playmovicePack;

@end


@interface BTCommunication : NSObject <CBPeripheralDelegate>

/// Peripheral device
@property (nonatomic,retain) CBPeripheral *peripheral;

/// Characteristic value
@property (nonatomic,retain) CBCharacteristic *characteristic;

/// delegate
@property (nonatomic, assign) id<BTCommunicationDelegate> delegate;

@property (nonatomic, assign) id<BTCommunicationPlayMoviceDelegate> playMoviceDelegate;


/**
 *  Singleton
 *
 *  @return Returns the current instance
 */
+ (BTCommunication *) sharedInstance;


- (void)didReceivePlayMoviceData:(NSData *)playMoviceData;

/**
 *  When you configure the Bluetooth，when the Bluetooth receiving the data in the callback method "peripheral: didUpdateValueForCharacteristic: error:" in CBPeripheralDelegate, this method must be called
 *
 *  @param data the data been received
 */
-(void)didReceiveData:(NSData *)data;

///  current file been read or written
@property (nonatomic,strong) FileToRead* curReadFile;

///  Start ping hosts
- (void)BeginPing;  //开始ping

#pragma mark - 读文件相关
/**
 *  Read files from a handheld device via Bluetooth
 *
 *  @param fileName File name to be read
 *  @param type     File types to be read
 */
- (void)BeginReadFileWithFileName:(NSString*)fileName fileType:(U8)type;

#pragma mark - 写文件相关
/**
 *  Writes data to handheld devices via Bluetooth
 *
 *  @param fileName File name to be written
 *  @param fileType File types to be written
 */
- (void)BeginWriteFile:(NSString*)fileName FileType:(U8)fileType andFileData:(NSData *)fileData;

///  Get device information
- (void)BeginGetInfo;

//  UPData Time for device
- (void)upDataTime;

///  others， you can use it when write file failed and will trigger proxy mode
-(void)writeFailed;

/**
 *  if it is loading file or not
 *
 *  @return return YES when some data is being loaded, otherwise return NO
 */
-(BOOL)bLoadingFileNow;

/**
 *  return current load fileType
 *
 *  @return return current load fileType
 */
-(FileType_t)curLoadFileType;
@end


/**
 *  this is a class to describe the completeed current loading or writing file
 */
@interface FileToRead : NSObject

///  file name
@property (nonatomic,assign) NSString *fileName;

///  file type
@property (nonatomic,assign) U8 fileType;

/// file size
@property (nonatomic,assign) U32 fileSize;

///  number of packages
@property (nonatomic,assign) U32 totalPkgNum;

///  current reading or writing number of packages
@property (nonatomic,assign) U32 curPkgNum;

///  the size of the last package
@property (nonatomic,assign) U32 lastPkgSize;

///  the contents of file being read or writen
@property (nonatomic,retain) NSMutableData *fileData;

///   the result analysis of reading or writing
@property (nonatomic,assign) FileLoadResult_t enLoadResult;

/**
 *  init method
 *
 *  @param fileType fileType
 *
 *  @return Returns the current instance
 */
- (instancetype)initWithFileType:(U8)fileType;

///  others not important
+(NSString *)descOfFileType:(FileType_t)kind;
-(NSString *)loadStateDesc;
@end
