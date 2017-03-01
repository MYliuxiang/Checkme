//
//  UARTPeripheral.h
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTCommunication.h"

@protocol UARTPeripheralDelegate     //（protocol:协议）
//- (void) didReceiveData:(NSData *) data;
@optional
-(void) didReadHardwareRevisionString:(NSString *) string;
-(void)didConnectSuccess;
@end


@interface UARTPeripheral : NSObject <CBPeripheralDelegate>//蓝牙外设的代理实现(遵守协议)
@property (nonatomic,retain) CBPeripheral *peripheral;
@property (nonatomic,retain) CBCharacteristic *txCharacteristic;
@property (nonatomic,assign) id<UARTPeripheralDelegate> delegate;

+ (CBUUID *) uartServiceUUID;
+ (CBUUID *) devServiceUUID;

- (UARTPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate;

- (void) writeString:(NSString *) string;
- (void) writeRawData:(NSData *) data;
- (void) didConnect;
- (void) didDisconnect;
@end