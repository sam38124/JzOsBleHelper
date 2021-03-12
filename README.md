[![Platform](https://img.shields.io/badge/平台-%20IOS%20-brightgreen.svg)](https://github.com/sam38124)
[![characteristic](https://img.shields.io/badge/特點-%20輕量級%20%7C%20簡單易用%20%20%7C%20穩定%20-brightgreen.svg)](https://github.com/sam38124)
# JzOsBleHelper
一套高效且敏捷的IOS Ble溝通框架，幫助開發者快速部署你的藍牙應用．另外支持android版本

[android版本](https://github.com/sam38124/JzBleHelper)
## 目錄
* [如何導入到專案](#Import)
* [藍牙掃描以及連線](#scan)
* [訊息傳送](#send)
* [關於我](#About)


<<a name="Import"></a>
## 如何導入到項目
> 支持SwiftPackage。 <br/>

## 如何使用
### 1.在要監聽藍牙的地方繼承BleCallBack


```swift
class ViewController: UIViewController,BleCallBack {
    
    var bles:[CBPeripheral]=[CBPeripheral]()
    
    //連線中的回調
    func onConnecting() {
        print("onConnecting")
    }
    //連線失敗時回調
    func onConnectFalse() {
        print("onConnectFalse")
    }
    //連線成功時回調
    func onConnectSuccess() {
        print("onConnectSuccess")
    }
    
    //三種方式返回接收到的藍芽訊息
    func rx(_ a: BleBinary) {
        print("rx:\(a.readHEX())")
        print("rx:\(a.readUTF())")
        print("rx:\( a.readBytes())")
    }
    
    //三種方式返回傳送的藍芽訊息
    func tx(_ b: BleBinary) {
        print("tx:\(b.readHEX())")
        print("tx:\(b.readUTF())")
        print("tx:\( b.readBytes())")
    }
    
    //返回搜尋到的藍芽,可將搜尋到的藍芽儲存於陣列中，可用於之後的連線
    func scanBack(_ device: CBPeripheral) {
        if(!bles.contains(device)){
            bles.append(device)
        }
    }
    
    //藍芽未打開，經聽到此function可提醒使用者打開藍芽
    func needOpen() {
        print("noble")
    }
    
   }

```

#### 宣告BleHelper並且開始使用
```swift
lazy var helper=BleHelper(self)
```

## 藍牙掃描以及連線

<a name="scan"></a>
#### 開始掃描
```swift
  helper.startScan()
```
#### 開始連線
```swift
   helper.connect(bles[0], 10)
```

#### 停止掃描藍牙
```swift
   helper.stopScan()
```
#### 藍牙斷線
```swift
  helper.disconnect()
```

<a name="send"></a>
## 訊息傳送
#### 四種方式向藍牙傳送Hello Ble的訊息，RxChannel為要接收資料的特徵值，TxChannel為要傳送資料的特徵值！
##### TxChannel以及RxChannel的UUID必需由藍牙的開發者定義<br>
##### 格式範例:8D81<br>
##### HexString
```swift
 helper.writeHex("48656C6C6F20426C65", TxChannel, RxChannel)
```
##### UTF-8
```swift
helper.writeUtf("Hello Ble", TxChannel, RxChannel)
```
##### Bytes
```swift
helper.writeBytes([0x48,0x65,0x6C,0x6C,0x6F,0x20,0x42,0x6C,0x65], TxChannel, RxChannel)
```
##### Data
```helper
helper.writeData("Hello Ble".data(using: .utf8), TxChannel, RxChannel)
```
<a name="About"></a>
### 關於我
橙的電子android and ios developer

*line:sam38124

*gmail:sam38124@gmail.com

