//
//  MonitoringChartView.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 17.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import Charts

class MeasureChartView: LineChartView {
    
    func setChart() {
        //self.backgroundColor = .clear
        
        self.noDataText = ""
        self.chartDescription?.text = ""
        self.legend.enabled = true
        self.leftAxis.enabled = true
        self.rightAxis.enabled = false
        self.backgroundColor = UIColor.background
        
        self.legend.textColor = .white
        self.legend.font = self.legend.font.withSize(15)
        
        self.leftAxis.drawGridLinesEnabled = true
        self.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
        self.leftAxis.labelTextColor = UIColor.white
        
        //        self.xAxis.labelCount = 5
        self.xAxis.labelPosition = .bottom
        self.xAxis.drawGridLinesEnabled = true
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.drawLabelsEnabled = true
        self.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
        self.xAxis.labelTextColor = UIColor.white
        //        //self.xAxis.yOffset = -5
        //        self.xAxis.granularity = 1
        
        self.scaleYEnabled = true
        self.scaleXEnabled = true
        self.pinchZoomEnabled = true
        self.doubleTapToZoomEnabled = false
        
        self.leftAxis.granularityEnabled = true
        self.leftAxis.granularity = 1.0
    }
    
    class func setChartDataSet(dataSet: LineChartDataSet, color: UIColor = .white) {
        // Create bar chart data set containing salesEntries
        dataSet.colors = [color]
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = true
        //dataSet.drawVerticalHighlightIndicatorEnabled = true
        
        //chartDataSet.cubicIntensity = 0.7
        dataSet.mode = .horizontalBezier
    }
    
}
