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
    
    var chart: MeasureChartView? = nil
    var maxRadarChart: TimeMeasureChart? = nil

    //var chart: MeasureChartView? = nil
    
    var currentMeasure: Measure? = nil
    
    let chartViews = [UIView]()
    let labels = ["Временная диаграмма", "Диграмма максимумов"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * 2, height: 350)
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
        
        saveToCameraOutlet.layer.borderWidth = 1
        saveToCameraOutlet.layer.borderColor = UIColor.buttonBorder.cgColor

        pageControl.numberOfPages = 2
        
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .white
        
        loadCharts()
    }
    
    func loadCharts() {
        if let measure = self.currentMeasure {
            chart = MeasureChartView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.frame.height))
            
            chart?.setChart()
            setTimeChartData(measure: measure)
            
            self.scrollView.addSubview(chart!)
            
            maxRadarChart = TimeMeasureChart(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.frame.height))
            
            maxRadarChart?.setChart()
            setMaxRadarChartData(measure: measure)
            
            maxRadarChart!.frame.origin.x = self.view.bounds.size.width
            self.scrollView.addSubview(maxRadarChart!)
        }
    }
    
    func setMaxRadarChartData(measure: Measure) {
        var dataEntries: [RadarChartDataEntry] = []
   
        for i in 0..<measure.usedSensorsNumber! {
            let dataEntry = RadarChartDataEntry(value: Swift.abs(measure.DeltaF(sensnum: i, index: measure.extremumIndex![i])))
            dataEntries.append(dataEntry)
        }
        
        let dataSet = RadarChartDataSet(values: dataEntries, label: "")
        TimeMeasureChart.setChartDataSet(dataSet: dataSet, setColor: UIColor(hexString: "09E489"), fillColor: UIColor(hexString: "09E489"))
        
        let radarChartData = RadarChartData(dataSets: [dataSet])
        maxRadarChart?.data = radarChartData
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
        if pageControl.currentPage == 0 && chart != nil {
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
