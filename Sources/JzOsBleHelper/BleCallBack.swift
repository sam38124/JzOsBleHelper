//
//  File.swift
//  
//
//  Created by Jianzhi.wang on 2020/11/4.
//
import Foundation
import CoreBluetooth
public protocol BleCallBack {
    func onConnecting()
    func onConnectFalse()
    func onConnectSuccess()
    func rx(_ a: BleBinary)
    func tx(_ b: BleBinary)
    func scanBack(_ device: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber)
    func needOpen()
}

