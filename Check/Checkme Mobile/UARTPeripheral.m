//
//  UARTPeripheral.m
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import "UARTPeripheral.h"
#import "NSDate+Additional.h"
#import "AppDelegate.h"

@interface UARTPeripheral ()
@property (nonatomic,retain) CBService *uartService;
@property (nonatomic,retain) CBCharacteristic *rxCharacteristic;


@property (nonatomic,retain) CBService *devService;
@property (nonatomic,retain) CBCharacteristic *devRxCharacteristic;
@property (nonatomic,retain) CBCharacteristic *devTxCharacteristic;

@end


@implementation UARTPeripheral

//@synthesize 会生成set、get方法
//@dynamic 不会生成set、get方法

@synthesize peripheral = _peripheral;//外设
@synthesize delegate = _delegate; //设置代理

@synthesize uartService = _uartService; //服务
@synthesize rxCharacteristic = _rxCharacteristic;
@synthesize txCharacteristic = _txCharacteristic;
@synthesize devService = _devService;
@synthesize devRxCharacteristic = _devRxCharacteristic;
@synthesize devTxCharacteristic = _devTxCharacteristic;


//蓝牙通用的异步收发器  服务的UUID
+ (CBUUID *) uartServiceUUID
{
  //return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"];
}


//周边设备 (外设) 服务的UUID
+ (CBUUID *) devServiceUUID
{
    return [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"];
}


//写特征值
+ (CBUUID *) txCharacteristicUUID   //data going to the module
{
    //return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"];
}

//写外设特性值
+ (CBUUID *) devTxCharacteristicUUID   //data going to the module
{
//    return [CBUUID UUIDWithString:@"BA04C4B2-892B-43BE-B69C-5D13F2195392"];
    return [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"];
}


//读特性值
+ (CBUUID *) rxCharacteristicUUID  //data coming from the module
{
    //return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
    return [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"];
}

//读外设特性值
+ (CBUUID *) devRxCharacteristicUUID  //data coming from the module
{
    return [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"];
}


//设备信息的服务UUID
+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}


//硬件修订字符的UUID
+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

//================================自定义的方法==============*****
- (UARTPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate
{
    if (self = [super init])
    {
        self.peripheral = peripheral;
        _peripheral.delegate = self;//成为代理
        self.delegate = delegate;//设置代理
    }
    return self;
}
//当CBCentralPeripheral 中连接到外设时 这里要立即执行discoverServices 方法 来了解周边提供什么样的服务
//还会引发 didDiscoverServices代理方法
- (void) didConnect
{
    DLog(@"peripheral手动调用discoverServices 方法！！！");
    //查询蓝牙服务  (在连接到外设蓝牙设备时,就需要立即执行这个方法)
    [_peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID, self.class.devServiceUUID]];
    DLog(@" start discover service!!!");
}
- (void) didDisconnect
{
    [AppDelegate GetAppDelegate].isOffline = true;  //Method.property    方法.属性
   
}

//写入
- (void) writeString:(NSString *) string
{
    NSString *string1 = [NSString stringWithString:string];
    
    string1 = [string1 stringByAppendingString:@"\r"];  //这里的意思是,在 string1  后 面拼接 \r  若使用的是 stringByAppendingPathComponent 则不需要加上 \ 来拼接,因为 stringByAppendingPathComponent 会自动帮你把 \r 拼接上
    
    //string1 = [string1 stringByAppendingPathComponent:@"r"];  上面那句跟这句表达的是一个含义
    
    NSData *data = [NSData dataWithBytes:string1.UTF8String length:string1.length];//设置字符编码格式以及长度
    
    [self.peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];//（特征 写 与 出 响应）这里的type值是一个枚举类型的值  还有一个枚举值是CBCharacteristicWriteWithResponse
}

#warning 数据的写入...
- (void) writeRawData:(NSData *) data
{
    /**
     *  CBPeripheralStateDisconnected = 0,  没有连接的状态 （断开连接）
        CBPeripheralStateConnecting,    连接
        CBPeripheralStateConnected,     连接状态
        CBPeripheralStateDisconnecting   断开连接状态
     */
    if (self.peripheral.state == CBPeripheralStateConnected) {//连接状态
        
        //写特性值
        DLog(@"写特性值 Characteristic：%@", self.txCharacteristic);
        [self.peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}
//======================================================*****

#pragma CBPeripheral delegate

//***************************** 连接部分  ********************************************
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    DLog(@"Found correct service 找到了需要的服务，peripheral手动调用discoverCharacteristics方法！");
    if (error)
    {
        DLog(@"Error discovering services: %@", error);//打印错误信息(服务的错误信息打印)
        return;
    }
    
    for (CBService *s in [peripheral services]) //遍历所有的服务..
    {
        if ([s.UUID isEqual:self.class.uartServiceUUID])
        {
            self.uartService = s;
            
            [self.peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:self.uartService];
        }
        else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }
        else if ([s.UUID isEqual:self.class.devServiceUUID])
        {
            self.devService = s;
            [self.peripheral discoverCharacteristics:@[self.class.devTxCharacteristicUUID, self.class.devRxCharacteristicUUID] forService:self.devService];
        }
    }
}


//外围设备寻找到特征后
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DLog(@"自动进入到didDiscoverCharacteristicsForService 代理方法!!!");
    if (error)
    {
        DLog(@"Error discovering characteristics: %@", error);
        return;
    }
    
    if(!_rxCharacteristic || !_txCharacteristic)
    {
        for (CBCharacteristic *c in [service characteristics])
        {
            if ([c.UUID isEqual:self.class.rxCharacteristicUUID] || [c.UUID isEqual:self.class.devRxCharacteristicUUID])
            {
                DLog(@"Found RX characteristic  :%@", c);
                self.rxCharacteristic = c;
                [BTCommunication sharedInstance].characteristic = _txCharacteristic;
                
                [self.peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
                
            }
            else if ([c.UUID isEqual:self.class.txCharacteristicUUID] || [c.UUID isEqual:self.class.devTxCharacteristicUUID])
            {
                DLog(@"Found TX characteristic  :%@", c);
                self.txCharacteristic = c;
                [BTCommunication sharedInstance].characteristic = _txCharacteristic;
            }
        }
        if(_txCharacteristic && _rxCharacteristic)
               //发送连接成功通知
                [_delegate didConnectSuccess];
    }
}
//************************************************************************************

#pragma mark - 数据传输的重要部分，处理蓝牙发过来的数据
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"进入到didUpdateValueForCharacteristic 方法！！！");
    if (error)
    {
        DLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
//    ImportantLog(@"动态接收到数据--%d--Bytes",characteristic.value.length);
    
    if (characteristic == self.rxCharacteristic)
    {
        //NSString *string = [NSString stringWithUTF8String:[[characteristic value] bytes]];
        
//        [_delegate didReceiveData:characteristic.value];
        [[BTCommunication sharedInstance] didReceiveData:characteristic.value];
        
    }
    else if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID])
    {
    }
}
@end
