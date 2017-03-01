//
//  BTUtils.m
//  Checkme Mobile
//
//  Created by Joe on 14/9/20.
//  Copyright (c) 2014年 VIATOM. All rights reserved.
//

#import "BTUtils.h"
#import "CheckmeInfo.h"

@interface BTUtils()

@end

@implementation BTUtils

+(BTUtils *)GetInstance
{
    static BTUtils *inst = nil;//定义一个静态的BTUtils
    if(!inst){
        inst = [[BTUtils alloc] init];
    }
    return inst;
}

-(id)init
{
    self = [super init];
    if(self){

    }
    return self;
}


#pragma mark - 连接扫描相关  自定义方法
//打开蓝牙 创建CBCentralManager实例
-(void)openBT
{
    _centralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

//开始扫描
-(void)beginScan
{
    //扫描所有可连接设备
    [self.centralManager scanForPeripheralsWithServices:nil /*@[UARTPeripheral.devServiceUUID]*/ options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
}
//停止扫描
-(void)stopScan
{
    [self.centralManager stopScan];//停止扫描操作  (关闭中央设备的扫描操作)
}

#pragma mark - 点击外设列表,执行连接外设的方法
//点击外设蓝牙列表的某item 执行连接到外设方法（自己写的方法）
-(void)connectToPeripheral:(CBPeripheral *)peripheral
{
    _currentPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
    [BTCommunication sharedInstance].peripheral = peripheral;
    
    DBG(@"%@", _centralManager.delegate);
    
    //中心设备执行连接蓝牙的方法
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}
// ************************************************************


//实现中央设备的代理方法
#pragma mark - CBCentralManagerDelegate
#pragma mark - 主设备状态改变的委托代理事件
//协议中的方法     检测中心设备蓝牙状态  无论蓝牙是否开启都进入此方法 自动调用此方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
//    if (central.state != CBCentralManagerStatePoweredOn) {   //当蓝牙关闭时  发送关闭通知   在rootViewController中实现回调方法
//        // In a real app, you'd deal with all the states correctly
//        
//        //运行app时 如果手机蓝牙没有打开 会调用通知的回调方法
//        [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_BTPowerOff object:self userInfo:nil];
//        return;
//    }
//    
//    //当蓝牙开启时  发送开启通知   在rootViewController中实现回调方法
//    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_BTPowerOn object:self userInfo:nil];
//    // ... so start scanning
 
#warning 将上面的做了个修改
    if (central.state == CBCentralManagerStatePoweredOn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_BTPowerOn object:self userInfo:nil];
        
    }
    
    //运行app时 如果手机蓝牙没有打开 会调用通知的回调方法
            [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_BTPowerOff object:self userInfo:nil];
    
}


#warning 群主大神说这里做了限制？？？
/** 
 * 发现外围设备 
 * 
 * @param central 中心设备 
 * @param peripheral 外围设备 
 * @param advertisementData 特征数据 
 * @param RSSI 信号质量（信号强度） 
 */
//发现设备     协议中的可选方法      当中心设备找到外设时 自动调用此方法 可以调多次
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    if(!_currentPeripheral && peripheral.name){
//        //发现外设，调用通知
//        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:peripheral,Key_FindAPeripheral_Content, nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FindAPeripheral object:self userInfo:usrInfo];
//   // NSLog(@"这里的这个方法会被调用很多次...........一直会被调用的");
//   
//   }
    
    if(!_currentPeripheral && peripheral.name)
    {
        //发现外设，调用通知
        //        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:peripheral,Key_FindAPeripheral_Content, nil];
        //        NSLog(@"---%@",advertisementData[@"kCBAdvDataLocalName"]);
        NSMutableDictionary *mutDic = [NSMutableDictionary new];
        [mutDic setValue:peripheral forKey:Key_FindAPeripheral_Content];//kCBAdvDataLocalName
       [mutDic setValue:advertisementData[@"kCBAdvDataLocalName"] forKey:@"BLEName"]; //kCBAdvDataIsConnectable   kCBAdvDataLocalName
        [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_FindAPeripheral object:self userInfo:mutDic];
//        [mutDic copy];
    }
   
}
//当点击连接某个蓝牙时回调   协议中的可选方法   当中心设备连接到外设时 自动调用此方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didConnect];
    }
    
}
//连接失败回调   协议中的可选方法      当中心设备与外设连接失败时 自动调用此方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DLog(@"与外设连接失败 Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

//断开连接时回调   协议中的可选方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didDisconnect];
        
        if (error) {
            
            DLog(@"didDisconnect error is = %@", error);
            DLog(@"断开了连接，手动再次连接");
            //当外设蓝牙被关闭时的提示性文字信息
//            [SVProgressHUD showErrorWithStatus:DTLocalizedString(@"Please wait for current download completed", nil) duration:2];
#warning 当外设蓝牙 与 主设之间断开了连接时的提示性文字信息  (自己加的,暂时不用...不再设计范围内不允许自己随意添加)
          //  [SVProgressHUD showErrorWithStatus:@"外设蓝牙已经被关闭了,请再次手动打开" duration:2];
            

            [self connectToPeripheral:peripheral];
        }
    }
}

#pragma mark - UARTPeripheral delegate
//连接成功回调
-(void)didConnectSuccess
{
    // 在rootViewController中   有pingCheckme 的回调
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfName_ConnectPeriphralSuccess object:self userInfo:nil];
}



@end