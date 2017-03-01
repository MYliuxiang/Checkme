//
//  BTUtils.h
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UARTPeripheral.h"
#import "BTCommunication.h"

//遵守中央管理以及外设服务的代理协议...
@interface BTUtils : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate, UARTPeripheralDelegate>

@property (nonatomic,retain) UARTPeripheral *currentPeripheral;
@property (nonatomic,retain) CBCentralManager *centralManager;
@property (nonatomic,strong) FileToRead *curReadFile;
//驱动相关
+(BTUtils *)GetInstance;
-(void)openBT;
-(void)beginScan;
-(void)connectToPeripheral:(CBPeripheral *)peripheral;
-(void)stopScan;

@end
