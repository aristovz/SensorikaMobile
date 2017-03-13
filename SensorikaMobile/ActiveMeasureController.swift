//
//  ActiveMeasureController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit
import KDCircularProgress
import RealmSwift

class ActiveMeasureController: UIViewController {

    @IBOutlet weak var dashLine: UIView!
    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var standartNameLabel: UILabel!
    
    @IBOutlet weak var currentSquare: UILabel!
    @IBOutlet weak var standartSquare: UILabel!
    
    @IBOutlet weak var measureButtonOutlet: UIButton!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBOutlet weak var ativityIndicator: UIActivityIndicatorView!
    
    var timer: Timer!
    //var timerTick = 0
    
    var standartMeasureObject: MeasureObject? = nil
    var standartMeasure: Measure? = nil
    let currentMeasure = Measure(number_of_used_sensors: 4)
    var newMeasure: MeasureObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashLine.addDashedLine()
        
        measureButtonOutlet.layer.cornerRadius = measureButtonOutlet.frame.height / 2
        
        measureButtonOutlet.layer.borderWidth = 3
        measureButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        saveButtonOutlet.layer.borderWidth = 1
        saveButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        saveButtonOutlet.setTitleColor(.gray, for: .normal)
        
        saveButtonOutlet.isEnabled = false
        
        if let measure = standartMeasureObject {
            standartMeasure = Measure(measureObject: measure, sensArray: Global.SENSORS)
            standartMeasure?.SetTimeMask(mrows: measure.getMaskValues())
            
            standartSquare.text = String(format: "%g", standartMeasure!.CalculateSquare())
            standartNameLabel.text = "Стандарт: \(measure.name)"
        }
        
        if newMeasure != nil {
            saveButtonOutlet.isHidden = false
            standartSquare.isHidden = true
            standartNameLabel.isHidden = true
        }
        else {
            saveButtonOutlet.isHidden = true
            standartSquare.isHidden = false
            standartNameLabel.isHidden = false
        }
        
        Global.SENSORS.Items.map { $0?.StartMeasure() }
        
        for k in 0..<Global.SENSORS.sensors.count {
            Global.SENSORS[k]?.AddSensorData(time: Date(), freq: 0)//(sensor?.mainfreq ?? 0)  - 25.0 + randomNum)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: Date(), repeats: true)
        
        ativityIndicator.startAnimating()
    }
    
    let freqs = [[[0, 0, 0, 0, 0, -1, 0],
                  [0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0],
                  [-1, -1, 0, 0, 0, 0, 0]],
                 [[0, 0, 0, 0, 0, -1, -2],
                  [0, 0, -1, -1, 0, 0, -1],
                  [0, 0, -1, -1, 0, -2, -2],
                  [0, 1, 0, 0, 0, -1, 0]],
                 [[0, 0, 0, -1, -1, -1, -2],
                  [0, -1, -1, -1, -1, -2, -2],
                  [0, -1, -1, 1, -1, -2, -2],
                  [0, -1, -1, -1, -2, -2, -3]],
                 [[0, 0, -1, -1, -1, -2, -3],
                  [-1, 0, -1, 0, 0, -2, -2],
                  [-1, 0, 0, 1, 0, 0, -1],
                  [0, -1, -1, -1, -1, -4, -5]],
                 [[0, 1, 0, 1, 0, -2, -2],
                  [0, -1, 0, -1, -2, -3, -4],
                  [0, -1, -1, -2, -2, -4, -6],
                  [-1, -2, -2, -3, -4, -5, -8]]]

    func runTimedCode() {
        let timerTick = Int(-(self.timer.userInfo as! Date).timeIntervalSinceNow) - 1
        
        var index = 0
        for k in 0..<Global.SENSORS.sensors.count {
            if let standart = standartMeasureObject {
                if timerTick <= 4 {
                    index = 0
                }
                else if timerTick <= 6 {
                    index = 1
                }
                else if timerTick <= 8 {
                    index = 2
                }
                else if timerTick <= 10 {
                    index = 3
                }
                else if timerTick <= 20 {
                    index = 4
                }
                else if timerTick <= 40 {
                    index = 5
                }
                else {
                    index = 6
                }
            
                Global.SENSORS[k]?.AddSensorData(time: Date(), freq: Double(freqs[standart.id - 1][k][index]))//(sensor?.mainfreq ?? 0)  - 25.0 + randomNum)
            }
            else {
                let randomNum = Double(arc4random_uniform(50))
                
                Global.SENSORS[k]?.AddSensorData(time: Date(), freq: (Global.SENSORS[k]?.mainfreq ?? 0)  - 25.0 + randomNum)
            }
        }
        
        if timerTick == Global.measureLength {
            timer.invalidate()
            ativityIndicator.stopAnimating()
            
            saveButtonOutlet.isEnabled = true
            saveButtonOutlet.setTitleColor(.white, for: .normal)
            
            for sens in Global.SENSORS.sensors {
                currentMeasure.AddSensorData(sensor: sens!)
            }
            
            currentMeasure.useTimeMask = true
            if newMeasure == nil {
                currentMeasure.SetTimeMask(mrows: standartMeasureObject!.getMaskValues())
            }
            else {
                currentMeasure.SetTimeMask(mrows: newMeasure!.getMaskValues())
            }
            currentMeasure.CalculateMeasureStatistic(calcSensorStatistic: true)
            currentSquare.text = String(format: "%g", currentMeasure.CalculateSquare())
            
            UIView.animate(withDuration: 0.3, animations: {
                self.progressLabel.alpha = 0
                self.completedLabel.alpha = 0
                self.measureButtonOutlet.alpha = 1
            })
            
            return
        }
        
        progressView.animate(toAngle: 360 * Double(timerTick) / Double(Global.measureLength), duration: 1, completion: nil)
        progressLabel.text = "\(Int(Double(timerTick) / Double(Global.measureLength) * 100))%"
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        timer.invalidate()
        Global.SENSORS.Items.map { $0?.EndMeasure() }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if let newMeasure = newMeasure {
            try! uiRealm.write {
                for sens in Global.SENSORS.Items {
                    if let sensor = sens {
                        let newFreqData = FreqDataObject()
                        newFreqData.id = FreqDataObject.incrementID!
                        newFreqData.measure = newMeasure
                        newFreqData.freqValue = sensor.StartFrequency
                        newFreqData.timeValue = -1
                        newFreqData.sensorId = sensor.ID
                        newMeasure.freqData.append(newFreqData)
                        uiRealm.add(newFreqData)
                    
                        for k in 0..<sensor.FreqMeasure.count {
                            let freqData = FreqDataObject()
                            freqData.id = FreqDataObject.incrementID!
                            freqData.measure = newMeasure
                            freqData.freqValue = sensor.FreqMeasure[k]
                            freqData.timeValue = sensor.TimeMeasure[k]
                            freqData.sensorId = sensor.ID
                            
                            newMeasure.freqData.append(freqData)
                            uiRealm.add(freqData)
                        }
                    }
                    
                    uiRealm.add(newMeasure, update: true)
                }
            }
        
            timer.invalidate()
            Global.SENSORS.Items.map { $0?.EndMeasure() }
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMeasureSegue" {
            let vc = segue.destination as! MeasureController
            vc.currentMeasure = self.currentMeasure
            vc.standartMeasure = self.standartMeasure
            
            let measureSquare: Double = Double(self.currentSquare.text!)!
            let standartSquare: Double = Double(self.standartSquare.text!)!
            
            vc.result = (measureSquare - 3 * 0.5) / (standartSquare + 3 * 0.5)
        }
    }
}
