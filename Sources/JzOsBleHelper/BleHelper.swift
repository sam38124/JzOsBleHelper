//
//  File.swift
//  
//
//  Created by Jianzhi.wang on 2020/11/4.
//

import Foundation
import CoreBluetooth
public class BleHelper:NSObject,CBCentralManagerDelegate, CBPeripheralDelegate {
    public init(_ callback:BleCallBack){
        self.callback=callback
        super.init()
    }
    var callback:BleCallBack! = nil
    var IsConnect=false
    var haveble=false
    open var bles:[CBPeripheral]=[CBPeripheral]()
    lazy var centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    // 儲存連上的 peripheral，此變數一定要宣告為全域
    open var connectPeripheral: CBPeripheral!
    // 記錄所有的 characteristic
    open var charDictionary = [String: CBCharacteristic]()
    open func isPaired() -> Bool {
        let user = UserDefaults.standard
        if let uuidString = user.string(forKey: "KEY_PERIPHERAL_UUID")
        {
            print("uuid是\(uuidString)")
            let uuid = UUID(uuidString: uuidString)
            let list = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            if list.count > 0 {
                connectPeripheral = list.first!
                connectPeripheral.delegate = self
                return true
            }
        }
        return false
    }
    open func isOpen()->Bool{
        var a=centralManager.state
        usleep(100*1000)
        return centralManager.state == .poweredOn
    }
    open func isScanning()->Bool{
        return centralManager.isScanning
    }
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 先判斷藍牙是否開啟，如果不是藍牙4.x ，也會傳回電源未開啟
        guard central.state == .poweredOn else {
            // iOS 會出現對話框提醒使用者
            DispatchQueue.main.async {
                self.callback.needOpen()
            }
            return
        }
        haveble=true
        if(isPaired()){
            unpair()}
        startScan()
    }
    
    open func startScan(){
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    open func stopScan(){
        centralManager.stopScan()
    }
    open func connect(_ device:CBPeripheral,_ second:Int){
        DispatchQueue.main.async {
            self.callback.onConnecting()
        }
        let user = UserDefaults.standard
        user.set(device.identifier.uuidString, forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        connectPeripheral = device
        connectPeripheral.delegate = self
        centralManager.connect(connectPeripheral, options: nil)
        DispatchQueue.global().async {
            var i=0
            while(i<second){
                sleep(1)
                i+=1
                if(self.IsConnect){break}
            }
            DispatchQueue.main.async {
                if(!self.IsConnect){ self.callback.onConnectFalse()}
            }
        }
    }
    
    open func disconnect(){
        unpair()
    }
    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {
            return
        }
        print(advertisementData)
        DispatchQueue.main.async {
            self.callback.scanBack(peripheral,advertisementData: advertisementData,rssi: RSSI)
        }
    }
    
    /* 3號method */
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 清除上一次儲存的 characteristic 資料
        charDictionary = [:]
        // 將觸發 4號method
        peripheral.discoverServices(nil)
    }
    /* 4號method */
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        for service in peripheral.services! {
            // 將觸發 5號method
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    /* 5號method */
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        self.IsConnect=true
        DispatchQueue.main.async {
            self.callback.onConnectSuccess()
        }
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("channelID:\(uuidString)")
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    /* 將資料傳送到 peripheral */
    open func sendData(_ data:Data,_ txchannel:String,_ rxchannel:String)  {
        guard let tx = charDictionary[txchannel] else {
            print("寫入失敗")
            return
        }
        guard let rx = charDictionary[rxchannel] else {
            print("寫入失敗")
            return
        }
        connectPeripheral.setNotifyValue(true, for: rx)
        connectPeripheral.writeValue(
            data,
            for: tx,
            type: .withoutResponse
        )
        DispatchQueue.main.async {
            self.callback.tx(BleBinary(data))
        }
    }
    
    open func writeUtf(_ data:String,_ txchannel:String,_ rxchannel:String){sendData(data.data(using: .utf8)!,txchannel,rxchannel)}
    open func writeHex(_ data:String,_ txchannel:String,_ rxchannel:String){sendData(data.HexToByte()!,txchannel,rxchannel)}
    open func writeBytes(_ data:[UInt8],_ txchannel:String,_ rxchannel:String){sendData(Data(data),txchannel,rxchannel)}
    open func writeData(_ data:Data,_ txchannel:String,_ rxchannel:String){sendData(data,txchannel,rxchannel)}
    
    /* 將資料傳送到 peripheral 時如果遇到錯誤會呼叫 */
    open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("寫入資料錯誤: \(error!)")
        }else{
            
        }
    }
    
    /* 取得 peripheral 送過來的資料 */
    open  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(error!)
            return
        }
        let data = characteristic.value
        DispatchQueue.main.async {
            self.callback.rx(BleBinary(data!))
        }
    }
    
    /* 斷線處理 */
    open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("連線中斷")
        IsConnect=false
        if isPaired() {
            centralManager.connect(connectPeripheral, options: nil)
        }
        DispatchQueue.main.async {
            self.callback.onConnectFalse()
        }
    }
    /* 解配對 */
    open func unpair() {
        let user = UserDefaults.standard
        user.removeObject(forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        guard connectPeripheral != nil else {
            return
        }
        centralManager.cancelPeripheralConnection(connectPeripheral)
        IsConnect=false
        DispatchQueue.main.async {
            self.callback.onConnectFalse()
        }
    }
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor?
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
            }
            
        }
    }
    open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("--------send-------")
        print()
    }
}
extension String{
    func HexToByte() -> Data? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
        
        let found = regex.firstMatch(in: trimmedString, options: [], range: NSMakeRange(0, trimmedString.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.count % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        
        let data = NSMutableData(capacity: trimmedString.count / 2)
        
        var index = trimmedString.startIndex
        while index < trimmedString.endIndex {
            let byteString = String(trimmedString[index ..< trimmedString.index(after: trimmedString.index(after: index))])
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.append([num] as [UInt8], length: 1)
            index = trimmedString.index(after: trimmedString.index(after: index))
        }
        
        //        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = trimmedString.index(after: trimmedString.index(after: index)) {
        //            let byteString = trimmedString.substring(with: (index ..< trimmedString.index(after: trimmedString.index(after: index))))
        //            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
        //            data?.append([num] as [UInt8], length: 1)
        //        }
        
        return data as Data?
    }
}
