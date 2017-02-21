//
//  MonitoringChartView.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 17.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import Charts

class TimeMeasureChart: RadarChartView {
    func setChart() {
        //self.backgroundColor = .clear
        self.noDataText = ""
        self.chartDescription?.text = ""
        self.legend.enabled = false
        self.backgroundColor = UIColor.background
        
        self.xAxis.drawGridLinesEnabled = true
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.drawLabelsEnabled = false
        
        self.yAxis.drawAxisLineEnabled = false
        self.yAxis.drawGridLinesEnabled = false
        self.yAxis.drawZeroLineEnabled = true
        self.yAxis.drawLabelsEnabled = false
        self.yAxis.axisMinimum = 0
    }
    
    class func setChartDataSet(dataSet: RadarChartDataSet, setColor: UIColor = .white, fillColor: UIColor = .blue) {
        // Create bar chart data set containing salesEntries
        dataSet.setColor(setColor)
        dataSet.fillColor = fillColor
        dataSet.fillAlpha = 0.7
        dataSet.drawFilledEnabled = true
        
        dataSet.drawValuesEnabled = true
        dataSet.valueColors = [UIColor.white]
    }
}
