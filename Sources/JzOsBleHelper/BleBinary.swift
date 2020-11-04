//
//  File.swift
//  
//
//  Created by Jianzhi.wang on 2020/11/4.
//

import Foundation
public class BleBinary {
    var data:Data! = nil
    init (_ data:Data){
        self.data=data
    }
    public func readUTF()->String?{
        
        return String(data: data!, encoding: String.Encoding.utf8) as String?
    }
    public func readBytes()->[UInt8]{
        return [UInt8](data)
    }
    public func readHEX()->String{
        var tempstring=""
        for i in data{
            tempstring = tempstring+String(format:"%02X",i)
        }
        return tempstring
    }
}
