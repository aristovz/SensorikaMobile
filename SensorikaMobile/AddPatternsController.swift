//
//  AddPatternsController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 22.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit
import Realm

class AddPatternsController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var dashLine: UIView!
    @IBOutlet weak var squareField: UITextField!
    
    @IBOutlet weak var maskField: UITextField!
    
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    var currentMeasureObject: MeasureObject? = nil
    var currentMeasure: Measure? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dashLine.addDashedLine()
        
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.buttonBorder.cgColor
        
        deleteButtonOutlet.isHidden = currentMeasureObject == nil
        
        if let measure = currentMeasureObject {
            nameField.text = measure.name
            maskField.text = measure.mask
            
            currentMeasure = Measure(measureObject: measure, sensArray: Global.SENSORS)
            currentMeasure?.useTimeMask = true
            currentMeasure?.SetTimeMask(mrows: measure.getMaskValues())
            currentMeasure?.CalculateMeasureStatistic(calcSensorStatistic: true)
            
            squareField.text = String(format: "%g", currentMeasure!.CalculateSquare())
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if Double(squareField.text!.replacingOccurrences(of: ",", with: ".")) != nil {
            if currentMeasureObject != nil {
                try! uiRealm.write {
                    currentMeasureObject?.name = nameField.text!
                    //currentMeasureObject?.square = Double(squareField.text!)!
                    currentMeasureObject?.mask = maskField.text!
                }
            }
            else {
                try! uiRealm.write {
                    let measureObject = MeasureObject(value: ["id" : MeasureObject.incrementID!, "name" : nameField.text!, "mask" : maskField.text!, "square" : Double(squareField.text!.replacingOccurrences(of: ",", with: "."))!])
                    uiRealm.add(measureObject)
                }
            }
        }
        else {
            squareField.shake()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        try! uiRealm.write {
            uiRealm.delete(uiRealm.objects(FreqDataObject.self).filter("measure.id == \(currentMeasureObject!.id)"))
            uiRealm.delete(currentMeasureObject!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
