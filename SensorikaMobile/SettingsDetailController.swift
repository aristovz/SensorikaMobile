//
//  SettingsDetailController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 17.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsDetailController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var dashLine: UIView!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var sidField: UITextField!
    @IBOutlet weak var abreviationField: UITextField!
    @IBOutlet weak var mainFreqField: UITextField!
    @IBOutlet weak var ampField: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorPicker: UIView!
    
    var currentSensor: Sensor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashLine.addDashedLine()
        
        for i in 0..<self.tableView.numberOfSections
        {
            for j in 0..<self.tableView.numberOfRows(inSection: i)
            {
                if let cell = tableView.cellForRow(at: IndexPath(row: j, section: i)) {
                    cell.viewWithTag(1)?.addDashedLine()
                }
            }
        }
        
        saveButtonOutlet.layer.cornerRadius = saveButtonOutlet.frame.height / 2
        saveButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        saveButtonOutlet.layer.borderWidth = 1
        
        colorView.layer.cornerRadius = colorView.frame.height / 2
        colorView.layer.borderColor = UIColor.buttonBorder.cgColor
        colorView.layer.borderWidth = 2
        
        // ColorPickerView initialisation
        let colorPickerframe = self.colorPicker.bounds
        let colorPicker = ColorPickerView(frame: colorPickerframe)
        colorPicker.didChangeColor = { [unowned self] color in
            self.colorView.backgroundColor = color
        }
        self.colorPicker.addSubview(colorPicker)
        
        if let sensor = currentSensor {
            nameField.text = sensor.Name
            sidField.text = sensor.Sid
            abreviationField.text = sensor.Abbreviation
            mainFreqField.text = "\(sensor.mainfreq)"
            ampField.text = "\(sensor.Amplitude)"
            colorView.backgroundColor = sensor.Color
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if let sensor = currentSensor {
            if let sensorObject = uiRealm.object(ofType: SensorObject.self, forPrimaryKey: sensor.ID) {
                try! uiRealm.write {
                    if let mainFreq = Double(mainFreqField.text!.replacingOccurrences(of: ",", with: ".")) {
                        sensorObject.mainfreq = mainFreq
                    }
                    
                    if let amp = Double(ampField.text!.replacingOccurrences(of: ",", with: ".")) {
                        sensorObject.amp = amp
                    }
                    
                    sensorObject.name = nameField.text!
                    sensorObject.sid = sidField.text!
                    sensorObject.abbreviation = abreviationField.text!
                    sensorObject.color = colorView.backgroundColor!.toHexString()
                }
                
                Global.SENSORS.LoadSensor(id: sensor.ID)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
