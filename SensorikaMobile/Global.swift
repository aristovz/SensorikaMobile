//
//  Global.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 16.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import UIKit

class Global {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static var SENSORS = SensorsArray()
    
    static var measureLength = 60
    
    static var standartMask = "4 6 8 10 20 40 60"
    
    static func TriangleSquare(a: Double, b: Double, angle_rad: Double) -> Double {
        return a * b * sin(angle_rad) / 2
    }
}
