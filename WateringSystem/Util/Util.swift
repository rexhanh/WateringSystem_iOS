//
//  Util.swift
//  WateringSystem
//
//  Created by Yuanrong Han on 3/22/21.
//

import Foundation
import UIKit
import CoreBluetooth
extension UIColor {
    static var sunYellow : UIColor {
        return UIColor(displayP3Red: 252/255, green: 186/255, blue: 3/255, alpha: 1)
    }
    
    static var skyBlue : UIColor {
        return UIColor(displayP3Red: 62/255, green: 176/255, blue: 247/255, alpha: 1)
    }
}

struct BLE_Device {
    static let defaultserviceUUID = CBUUID(string: "FFE0")
    static let defaultcharacteristicUUID = CBUUID(string: "FFE1")
    var serviceUUID : CBUUID?
    var characteristicUUID : CBUUID?
}

protocol dataSendingDelegateProtocol {
    func sendBackUpdatedPlantData(data: Plant)
}

class Util {
    static func sensorValueRecover(from value: UInt8) -> Int {
        return Int(value) * 1024 / 256
    }
}
