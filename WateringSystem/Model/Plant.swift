//
//  Plant.swift
//  WateringSystem
//
//  Created by Yuanrong Han on 3/22/21.
//

import UIKit
class Plant {
    var moisture : CGFloat
    var light : CGFloat
    var name : String
    var plantImage : UIImage
    init(moisture: CGFloat, light:CGFloat, name:String, plantImage:UIImage) {
        self.moisture = moisture
        self.light = light
        self.name = name
        self.plantImage = plantImage
    }
    func updateMoisture(to moisture: CGFloat) -> Void {
        self.moisture = moisture
    }
    
    func getMoisturePercentage() -> CGFloat {
        let actualPercent = -self.moisture * 1/1024 + 1.2
        let resPercent = actualPercent >= 0.9 ? 1 : actualPercent
        return resPercent
    }
    func updateLight(to light: CGFloat) -> Void {
        self.light = light
    }
    func getLightPercentage() -> CGFloat {
        let actualPercent = (1024 - self.light) / 1024
        let resPercent = actualPercent >= 0.9 ? 1 : actualPercent
        return resPercent
    }
}
