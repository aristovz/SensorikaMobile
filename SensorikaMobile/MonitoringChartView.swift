//
//  MonitoringChartView.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 17.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import Charts

class MonitoringChartView: LineChartView {
    
    func setChart() {
        //self.backgroundColor = .clear
        
        self.noDataText = ""
        self.chartDescription?.text = ""
        self.legend.enabled = false
        self.leftAxis.enabled = false
        self.rightAxis.enabled = true
        //self.drawMarkers = true
        
        self.rightAxis.drawGridLinesEnabled = false
        self.rightAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
        self.rightAxis.labelTextColor = UIColor.white
        
//        self.xAxis.labelCount = 5
//        self.xAxis.labelPosition = .bottomInside
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.drawAxisLineEnabled = false
        self.xAxis.drawLabelsEnabled = false
//        self.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
//        self.xAxis.labelTextColor = UIColor.white
//        //self.xAxis.yOffset = -5
//        self.xAxis.granularity = 1
        
        self.scaleYEnabled = false
        self.scaleXEnabled = false
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
    }
    
    class func setChartDataSet(dataSet: LineChartDataSet, color: UIColor = .white) {
        // Create bar chart data set containing salesEntries
        dataSet.colors = [color]
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        
        //chartDataSet.cubicIntensity = 0.7
        dataSet.mode = .horizontalBezier
        
        let gradientColors = [color.cgColor, UIColor.clear.cgColor] // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0] // Positioning of the gradient
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations) // Gradient Object
        dataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        dataSet.drawFilledEnabled = true // Draw the Gradient
    }

}
