//
//  MeasureController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 21.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit
import Charts

class MeasureController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveToCameraOutlet: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chart: MeasureChartView? = nil
    var maxRadarChart: TimeMeasureChart? = nil
    var timeDetailRadarChart: TimeDetailMeasureChart? = nil

    //var chart: MeasureChartView? = nil
    
    var currentMeasure: Measure? = nil
    var standartMeasure: Measure? = nil
    
    var result: Double? = nil
    
    let chartViews = [UIView]()
    let labels = ["Диаграмма", "Диграмма максимумов", "Временная диаграмма"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 3
        
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(pageControl.numberOfPages), height: 350)
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
        
        saveToCameraOutlet.layer.borderWidth = 1
        saveToCameraOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .white
        
        if let res = result {
            if res < 1.5 {
                resultLabel.text = "Чистая проба"
            }
            else if res < 3 {
                resultLabel.text = "Незначительное загрязнение"
            }
            else if res < 6 {
                resultLabel.text = "Заметное загрязнение"
            }
            else {
                resultLabel.text = "Значительное загрязнение"
            }
        }
        
        loadCharts()
    }
    
    func loadCharts() {
        if let measure = self.currentMeasure {
            timeDetailRadarChart = TimeDetailMeasureChart(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.frame.height))
            
            timeDetailRadarChart?.setChart()
            setTimeChartData1()
            self.scrollView.addSubview(timeDetailRadarChart!)
            
            maxRadarChart = TimeMeasureChart(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.frame.height))
            
            maxRadarChart?.setChart()
            setMaxRadarChartData()
            maxRadarChart!.frame.origin.x = self.view.bounds.size.width
            self.scrollView.addSubview(maxRadarChart!)
            
            chart = MeasureChartView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.frame.height))
            
            chart?.setChart()
            setTimeChartData(measure: measure)
            chart!.frame.origin.x = self.view.bounds.size.width * 2
            self.scrollView.addSubview(chart!)
        }
    }
    
    func setMaxRadarChartData() {
        if let measure = self.currentMeasure {
            var dataEntries: [RadarChartDataEntry] = []
            var dataSets: [RadarChartDataSet] = []
            
            var values = [String]()
            for i in 0..<measure.usedSensorsNumber! {
                let dataEntry = RadarChartDataEntry(value: Swift.abs(measure.DeltaF(sensnum: i, index: measure.extremumIndex![i])))
                dataEntries.append(dataEntry)
                
                values.append(measure.usedSensors![i].SID)
            }
            
            var dataSet = RadarChartDataSet(values: dataEntries, label: "Текущее")
            TimeMeasureChart.setChartDataSet(dataSet: dataSet, setColor: UIColor(hexString: "09E489"), fillColor: UIColor(hexString: "09E489"))
            dataSets.append(dataSet)
            
            if let standart = self.standartMeasure {
                dataEntries.removeAll()
                for i in 0..<standart.usedSensorsNumber! {
                    let dataEntry = RadarChartDataEntry(value: Swift.abs(standart.DeltaF(sensnum: i, index: standart.extremumIndex![i])))
                    dataEntries.append(dataEntry)
                }
                
                dataSet = RadarChartDataSet(values: dataEntries, label: "Стандарт")
                TimeMeasureChart.setChartDataSet(dataSet: dataSet, setColor: UIColor.red.withAlphaComponent(0.5), fillColor: UIColor.orange.withAlphaComponent(0.5), drawValues: false)
                dataSets.append(dataSet)
            }
            maxRadarChart?.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)

            let radarChartData = RadarChartData(dataSets: dataSets)
            maxRadarChart?.data = radarChartData
        }
    }
    
    func setTimeChartData1() {
        if let measure = self.currentMeasure {
            var dataEntries: [RadarChartDataEntry] = []
            var dataSets: [RadarChartDataSet] = []
            
            var values = [String]()
            for k in 0..<measure.timeMaskValues.count {
                for i in 0..<measure.usedSensorsNumber! {
                    values.append(i == 0 ? "\(measure.timeMaskValues[k])" : "")
                    let number_of_values = measure.freqMeasure![i].count
                    
                    var time1: Double
                    var indexFreq1: Double
                    var freq1: Double
                    
                    if measure.useTimeMask {
                        time1 = measure.timeMaskValues[k];
                        indexFreq1 = time1 - measure.startTime
                        if (indexFreq1 > Double(number_of_values) || indexFreq1 < 0) { break }
                    }
                    else
                    {
                        time1 = measure.startTime + Double(k)
                        indexFreq1 = Double(k)
                    }
                    
                    freq1 = measure.DeltaF(sensnum: i, index: Int(indexFreq1))
                    let dataEntry = RadarChartDataEntry(value: freq1)
                    dataEntries.append(dataEntry)
                }
            }
            
            var dataSet = RadarChartDataSet(values: dataEntries, label: "Текущее")
            TimeDetailMeasureChart.setChartDataSet(dataSet: dataSet, setColor: UIColor(hexString: "09E489"), fillColor: UIColor(hexString: "09E489"))
            dataSets.append(dataSet)
            
            if let standart = self.standartMeasure {
                dataEntries.removeAll()
                for k in 0..<standart.timeMaskValues.count {
                    for i in 0..<standart.usedSensorsNumber! {
                        let number_of_values = standart.freqMeasure![i].count
                        
                        var time1: Double
                        var indexFreq1: Double
                        var freq1: Double
                        
                        if standart.useTimeMask {
                            time1 = standart.timeMaskValues[k];
                            indexFreq1 = time1 - standart.startTime
                            if (indexFreq1 > Double(number_of_values) || indexFreq1 < 0) { break }
                        }
                        else
                        {
                            time1 = standart.startTime + Double(k)
                            indexFreq1 = Double(k)
                        }
                        
                        freq1 = standart.DeltaF(sensnum: i, index: Int(indexFreq1))
                        let dataEntry = RadarChartDataEntry(value: freq1)
                        dataEntries.append(dataEntry)
                    }
                }
                
                dataSet = RadarChartDataSet(values: dataEntries, label: "Стандарт")
                TimeDetailMeasureChart.setChartDataSet(dataSet: dataSet, setColor: UIColor.red.withAlphaComponent(0.5), fillColor: UIColor.orange.withAlphaComponent(0.5))
                dataSets.append(dataSet)
            }
            timeDetailRadarChart?.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)
            
            let radarChartData = RadarChartData(dataSets: dataSets)
            timeDetailRadarChart?.data = radarChartData
        }
    }
    
    func setTimeChartData(measure: Measure) {
        var count = measure.timeMaskValues.count
        
        var dataEntries: [ChartDataEntry] = []
        var dataSets = [LineChartDataSet]()
        
        for i in 0..<measure.usedSensorsNumber! {
            dataEntries.removeAll()
            if !measure.useTimeMask { count = measure.freqMeasure![i].count }
            
            let number_of_values = measure.freqMeasure![i].count
            
            var time1: Double
            var indexFreq1: Double
            var freq1: Double
            
            for k in 0..<count {
                if measure.useTimeMask {
                    time1 = measure.timeMaskValues[k];
                    indexFreq1 = time1 - measure.startTime
                    if (indexFreq1 > Double(number_of_values) || indexFreq1 < 0) { break }
                }
                else
                {
                    time1 = measure.startTime + Double(k)
                    indexFreq1 = Double(k)
                }
                
                freq1 = measure.DeltaF(sensnum: i, index: Int(indexFreq1))
                let dataEntry = ChartDataEntry(x: time1, y: freq1)
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: measure.usedSensors![i].Name)
            MeasureChartView.setChartDataSet(dataSet: lineChartDataSet, color: measure.usedSensors![i].Color)
            //chart?.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
            dataSets.append(lineChartDataSet)
        }
        
        let lineChartData = LineChartData(dataSets: dataSets)
        chart?.data = lineChartData
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        self.titleLabel.text = self.labels[Int(page)]
        pageControl.currentPage = Int(page)
    }
    
    @IBAction func saveToCameraAction(_ sender: UIButton) {
        if pageControl.currentPage == 0 && timeDetailRadarChart != nil {
            UIGraphicsBeginImageContextWithOptions(timeDetailRadarChart!.bounds.size, false, UIScreen.main.scale)
            timeDetailRadarChart!.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
        else if pageControl.currentPage == 1 && chart != nil {
            UIGraphicsBeginImageContextWithOptions(chart!.bounds.size, false, UIScreen.main.scale)
            chart!.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
        else if maxRadarChart != nil {
            UIGraphicsBeginImageContextWithOptions(maxRadarChart!.bounds.size, false, UIScreen.main.scale)
            maxRadarChart!.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
}
