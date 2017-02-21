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
    
    @IBOutlet weak var ativityIndicator: UIActivityIndicatorView!
    
    var timer: Timer!
    var timerTick = 0
    
    var standartMeasure: MeasureObject? = nil
    let currentMeasure = Measure(number_of_used_sensors: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashLine.addDashedLine()
        
        measureButtonOutlet.layer.cornerRadius = measureButtonOutlet.frame.height / 2
        
        measureButtonOutlet.layer.borderWidth = 3
        measureButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        if let measure = standartMeasure {
            standartSquare.text = String(format: "%g", measure.square)
            standartNameLabel.text = "Стандарт: \(measure.name)"
        }
        
        Global.SENSORS.Items.map { $0?.StartMeasure() }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        ativityIndicator.startAnimating()
    }
    
    let freqs = [
        [9981034.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981034.0,9981033.0,9981034.0,9981034.0,9981033.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981034.0,9981033.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981034.0,9981034.0,9981034.0,9981034.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981033.0,9981034.0,9981033.0,9981033.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981034.0,9981033.0,9981034.0,9981034.0,9981034.0,9981033.0,9981033.0,9981034.0,9981034.0,9981034.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981033.0,9981034.0],
        [9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984472.0,9984473.0,9984473.0,9984473.0,9984472.0,9984472.0,9984473.0,9984473.0,9984472.0,9984472.0,9984472.0,9984473.0,9984473.0,9984472.0,9984472.0,9984472.0,9984473.0,9984473.0,9984472.0,9984472.0,9984473.0,9984473.0,9984473.0,9984473.0,9984472.0,9984473.0,9984472.0,9984473.0,9984473.0,9984472.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0,9984473.0],
        [9988596.0,9988596.0,9988597.0,9988596.0,9988597.0,9988596.0,9988597.0,9988597.0,9988596.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988597.0,9988598.0,9988597.0,9988597.0,9988598.0,9988597.0,9988597.0,9988598.0,9988597.0,9988598.0,9988597.0,9988598.0,9988597.0,9988598.0,9988597.0,9988598.0,9988598.0,9988597.0,9988598.0,9988598.0,9988597.0,9988598.0,9988598.0,9988598.0,9988597.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0,9988598.0],
        [9983284.0,9983285.0,9983284.0,9983285.0,9983284.0,9983285.0,9983285.0,9983284.0,9983285.0,9983285.0,9983284.0,9983284.0,9983285.0,9983285.0,9983284.0,9983284.0,9983284.0,9983284.0,9983285.0,9983285.0,9983285.0,9983285.0,9983284.0,9983284.0,9983284.0,9983284.0,9983284.0,9983284.0,9983284.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983284.0,9983285.0,9983285.0,9983284.0,9983284.0,9983284.0,9983284.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0,9983285.0]
    ]
    
//    let times

    func runTimedCode() {
        for k in 0..<Global.SENSORS.sensors.count {
            let randomNum = Double(arc4random_uniform(50))
            Global.SENSORS[k]?.AddSensorData(time: Date(), freq: freqs[k][timerTick])//(sensor?.mainfreq ?? 0)  - 25.0 + randomNum)
        }
        
        progressView.animate(toAngle: 360 * Double(timerTick) / Double(Global.measureLength), duration: 1, completion: nil)
        progressLabel.text = "\(Int(Double(timerTick) / Double(Global.measureLength) * 100))%"
        
        if timerTick == Global.measureLength {
            timer.invalidate()
            ativityIndicator.stopAnimating()
            
            for sens in Global.SENSORS.sensors {
                currentMeasure.AddSensorData(sensor: sens!)
            }
            for i in 0..<Global.SENSORS.sensors.count {
                currentMeasure.freqMeasure![i].removeFirst()
                currentMeasure.timeMeasure![i].removeFirst()
            }
            
            currentMeasure.useTimeMask = true
            currentMeasure.SetTimeMask(mrows: standartMeasure!.getMaskValues())
            currentMeasure.CalculateMeasureStatistic(calcSensorStatistic: true)
            currentSquare.text = String(format: "%g", currentMeasure.CalculateSquare())
            
            UIView.animate(withDuration: 0.3, animations: {
                self.progressLabel.alpha = 0
                self.completedLabel.alpha = 0
                self.measureButtonOutlet.alpha = 1
            })
        }
        timerTick += 1
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        timer.invalidate()
        Global.SENSORS.Items.map { $0?.EndMeasure() }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMeasureSegue" {
            let vc = segue.destination as! MeasureController
            vc.currentMeasure = self.currentMeasure
        }
    }
}
