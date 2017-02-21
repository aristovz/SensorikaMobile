//
//  MainController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 16.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import RealmSwift
import DropDown

class MainController: UIViewController, IndicatorInfoProvider, SensorDelegate {

    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet var addItemView: UIView!
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var standartButtonOutlet: UIButton!
    
    var effect:UIVisualEffect!
   
    var itemInfo: IndicatorInfo = "Измерение"
    
    var chart: MonitoringChartView? = nil
    var sensorMonitors = [SensorMonitorView]()
    
    let dropDown = DropDown()
    
    var measures = Array<MeasureObject>()
    var _selectedMeasure: MeasureObject? = nil
    
    var selectedMeasure: MeasureObject? {
        get { return _selectedMeasure }
        set {
            _selectedMeasure = newValue
            if let measure = newValue {
                standartButtonOutlet.setTitle(measure.name, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualEffectView.alpha = 0
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        addItemView.layer.cornerRadius = 5
        startButtonOutlet.layer.cornerRadius = startButtonOutlet.frame.height / 2
        standartButtonOutlet.layer.cornerRadius = 5
        
        addButtonOutlet.layer.borderWidth = 1
        addButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        startButtonOutlet.layer.borderWidth = 1
        startButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        DropDown.startListeningToKeyboard()
        
        dropDown.anchorView = standartButtonOutlet
        
        dropDown.selectionAction = { (index: Int, item: String) in
            self.selectedMeasure = self.measures[index]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.chart?.frame = self.chartView.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.measures = Array(uiRealm.objects(MeasureObject.self))
        
        if self.measures.count != 0 {
            dropDown.dataSource = measures.map { $0.name }
            selectedMeasure = measures[0]
        }
        
        chart = MonitoringChartView(frame: chartView.frame)
        chart?.tag = 5
        chartView.addSubview(chart!)
        chart?.setChart()
        start()
        
        for sensor in Global.SENSORS.sensors {
            sensor?.delegate = self
            
            let sensorMonitor = self.view.viewWithTag(sensor!.ID + 1) as! SensorMonitorView
            sensorMonitor.nameLabel.text = sensor!.Name
            sensorMonitor.colorView.backgroundColor = sensor!.Color
            sensorMonitor.layer.borderWidth = 2
            sensorMonitors.append(sensorMonitor)
        
            let ll = ChartLimitLine(limit: sensor!.BaseFrequency, label: "\(sensor!.BaseFrequency)")
            ll.lineColor = sensor!.Color
            ll.valueTextColor = UIColor.white.withAlphaComponent(0.5)
            ll.lineWidth = 1
            ll.lineDashPhase = 30
            ll.lineDashLengths = [3]
            chart!.leftAxis.addLimitLine(ll)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        animateOut()
        
        for subview in self.chartView.subviews {
            if subview.tag == 5 {
                subview.removeFromSuperview()
                chart = nil
            }
        }
        
        for sensor in Global.SENSORS.sensors {
            sensor?.ClearBufferData()
        }
        
        sensorMonitors.removeAll()
        self.timer?.invalidate()
        timer = nil
    }

    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        var dataSets = [LineChartDataSet]()
        for sensor in Global.SENSORS.sensors {
            if let sens = sensor {
                let lineChartDataSet = LineChartDataSet(values: dataEntries, label: sens.Name)
                MonitoringChartView.setChartDataSet(dataSet: lineChartDataSet, color: sens.Color)
                dataSets.append(lineChartDataSet)
            }
        }

        let lineChartData = LineChartData(dataSets: dataSets)
        chart?.data = lineChartData
        chart?.setVisibleXRange(minXRange: 0.0, maxXRange: 5.0)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func sensor(_ sensor: Sensor, didAddData data: Double, time: Date) {
        sensorMonitors[sensor.ID].freqLabel.text = "\(data)"
        
        sensorMonitors[sensor.ID].layer.borderColor = sensor.getStabilityColor().cgColor
        
        if self.chart?.data == nil {
            setChart(dataPoints: [""], values: [data])
        }
        
        let xIndex = self.chart!.data!.dataSets[sensor.ID].entryCount
        let entry = ChartDataEntry(x: Double(xIndex), y: data)
        self.chart!.data?.addEntry(entry, dataSetIndex: sensor.ID)
        
        if sensor.ID == Global.SENSORS.count - 1 {
            self.chart!.notifyDataSetChanged()
            self.chart!.setVisibleXRange(minXRange: 0.0, maxXRange: 5.0)
            self.chart!.moveViewToAnimated(xValue: Double(xIndex), yValue: 0, axis: .left, duration: TimeInterval(4), easingOption: .linear)
        }
    }
    
    func animateIn() {
        addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addItemView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.visualEffectView.alpha = 1
            self.addItemView.alpha = 1
            self.addItemView.transform = CGAffineTransform.identity
        }
        
    }
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addItemView.alpha = 0
            
            self.visualEffectView.alpha = 0
            self.visualEffectView.effect = nil
            
        })
    }
    
    ////////////////////
    private var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(handleMyFunction), userInfo: nil, repeats: true)
    }
    
    func stop() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    func handleMyFunction() {
        for sensor in Global.SENSORS.sensors {
            let randomNum = Double(arc4random_uniform(50))
            sensor?.AddSensorData(time: Date(), freq: (sensor?.mainfreq ?? 0.0) - 25.0 + randomNum)
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        animateIn()
    }
    
    @IBAction func cancelButtonActrion(_ sender: UIButton) {
        animateOut()
    }
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        animateOut()

        if let measure = self.selectedMeasure {
            let vc = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "activeMeasureNavController") as! UINavigationController
            
            (vc.viewControllers[0] as! ActiveMeasureController).standartMeasure = measure
            let mask = measure.getMaskValues()
            if mask.count != 0 {
                Global.measureLength = Int(measure.getMaskValues().last!)
            }
            
            stop()
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func standartButtonAction(_ sender: UIButton) {
        dropDown.show()
    }
    
}
