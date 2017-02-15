//
//  Extensions.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 15.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation

extension Date {
    func ToShortDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD.MM.yyyy"
        return dateFormatter.string(from: self)
    }
    
    func ToShortTimeString() -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM"
        return dateFormatter.string(from: self)
    }
}
