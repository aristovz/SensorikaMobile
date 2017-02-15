//
//  MeasureProfile.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 15.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation

enum ProfileAction: Int {
    case ReadToMemory = 0
    case Changed = 1
    case Deleted = 2
    case Created = 3
    case RenewFromMemory = 4
}

public class MeasureProfile
{
    private var positions = SensorsArray()
    var duration: Double = 0
    var maskID = 0
    var id = 0
    private var action = ProfileAction.ReadToMemory
    private var measureName = ""
    private var isStand = false
    //bool measureSaved = false;
    var startMeasureTime = Date()
    
    init() {
        for _ in 0..<8 {
            positions.sensors.append(nil)
        }
    }

    var Positions: SensorsArray
    {
        get { return positions }
        set { positions = newValue }
    }
    
    func ResetPositions() {
        for k in 0..<positions.sensors.count {
            positions.sensors[k] = nil
        }
    }
    
    var Standart: Bool {
        get { return isStand }
        set { isStand = newValue }
    }
    
    var StartMeasureTime: Date {
        get { return startMeasureTime }
        set { startMeasureTime = newValue }
    }
    
    var FullMeasureName: String {
        get {
            let sDateTime = startMeasureTime.ToShortDateString() + " " + startMeasureTime.ToShortTimeString();
            return "\(measureName) (\(sDateTime)) [\(Int(duration)) сек.]"
        }
    }
    
    var Action: ProfileAction {
        get { return action }
        set { action = newValue }
    }
    
    var MaskID: Int {
        get { return maskID }
        set { maskID = newValue }
    }
    
    var Duration: Double {
        get { return duration }
        set { duration = newValue }
    }
    
    subscript(index: Int) -> Sensor? {
        get {
            if (index >= 0 && index < 8) { return positions[index] }
            return nil
        }
        set {
            positions[index] = newValue
        }
    }
    
    var ProfileSelected: Bool {
        get {
            for i in 0..<positions.Items.count {
                if positions[i] != nil { return true }
            }
            
            return false
        }
    }
    
    var ID: Int {
        get { return id }
        set { id = newValue }
    }
    
    var MeasureName: String {
        get { return measureName }
        set { measureName = newValue }
    }
    
    /*
     public bool MeasureSaved
     {
     get { return measureSaved; }
     set { measureSaved = value; }
     }
     */
}
