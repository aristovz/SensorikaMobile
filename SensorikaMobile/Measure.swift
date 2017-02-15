//
//  Measure.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 13.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import RealmSwift

class Measure
{
    //массив всех доступных сенсоров
    var sensors: SensorsArray?
    
    var name: String?
    var fullName: String?
    
    var measureID = -1
    var maskID = -1
    var isMeasured = true
    var length: Double?
    var startDateTime: NSDate?
    
    //массивы отсчетов сенсоров (частота)
    var freqMeasure: Array<Array<Double>>?
    //массив времени отсчетов сенсоров
    var timeMeasure: Array<Array<Double>>?
    //cтартовая частота сенсора (принимается в качестве базовой для данного измерения)
    var startFreq: Array<Double>?
    
    //массив значений временной маски
    var _timeMaskValues: Array<Double>?
    
    //массив для хранения индексов экстремумов по каждому сенсору для выбранной временной маски
    var extremumIndex: Array<Int>?
    
    //массивы для хранения индексов мин и макс частоты по каждому сенсору для выбранной временной маски
    var minIndex: Array<Int>?
    var maxIndex: Array<Int>?
    
    //массив идентификаторов сенсоров, использованных в измерении
    var usedSensors: Array<Sensor>?
    //кол-во сенсоров, использованных в измерении
    var usedSensorsNumber: Int?
    //минимальная и максимальная частота для отображаемого на графике участка измерения
    var freqDeltaMin: Double?
    var freqDeltaMax: Double?
    //экстремум, мин и макс дельта F для всего измерения
    var measureExtremum: Double?
    var measureDeltaFMin: Double?
    var measureDeltaFMax: Double?
    
    //флаги для отображения сенсоров
    var _showSensor: [Bool]?
    
    //флаг использования временной маски
    var useTimeMask = false
    //точка отсчета измерения
    var _startTime: Double?
    //количество временных отсчетов (с учетом маски)
    var _timeTicksCount = 0
    
    init(number_of_used_sensors: Int)
    {
        Init(number_of_used_sensors: number_of_used_sensors)
    }
    
    func Init(number_of_used_sensors: Int) -> Void
    {
        _timeMaskValues = Array<Double>()
        
        freqMeasure = Array<Array<Double>>()//|error|(number_of_used_sensors);
        timeMeasure = Array<Array<Double>>()//|error|(number_of_used_sensors);
        startFreq = Array<Double>()//|error|(number_of_used_sensors);
        
        extremumIndex = Array<Int>()//|error|(number_of_used_sensors);
        minIndex = Array<Int>()//|error|(number_of_used_sensors);
        maxIndex = Array<Int>()//|error|(number_of_used_sensors);
        
        usedSensors = Array<Sensor>()//|error|(number_of_used_sensors);
        usedSensorsNumber = number_of_used_sensors
        
        _showSensor = [Bool](repeating: false, count: number_of_used_sensors)//new bool[number_of_used_sensors];
        
        for i in 0..<number_of_used_sensors {
            _showSensor?[i] = true
            extremumIndex?.append(0)
            minIndex?.append(0)
            maxIndex?.append(0)
        }
        
        freqDeltaMax = 0
        freqDeltaMin = freqDeltaMax
        _startTime = 0
    }
    
    func Init() -> Void
    {
        _timeMaskValues = Array<Double>();
        
        freqMeasure = Array<Array<Double>>()
        timeMeasure = Array<Array<Double>>()
        startFreq = Array<Double>()
        
        extremumIndex = Array<Int>()
        minIndex = Array<Int>()
        maxIndex = Array<Int>()
        
        usedSensors = Array<Sensor>()
        //usedSensorsNumber = number_of_used_sensors;
        
        /*
         showSensor = new bool[number_of_used_sensors];
         for (int i = 0; i < number_of_used_sensors; i++)
         {
         showSensor[i] = true;
         ExtremumIndex.Add(0);
         MinIndex.Add(0);
         MaxIndex.Add(0);
         }
         */
        
        freqDeltaMax = 0
        freqDeltaMin = 0
        _startTime = 0
    }
    
    func DeltaFreqByMask(sens_index: Int, mask_index: Int) ->  (Bool, delta_freq: Double)
    {
        var mask_time: Double?
        var delta_freq = 0.0
        
        if (useTimeMask)
        {
            if (mask_index >= _timeMaskValues!.count) { return (false, delta_freq) }
            
            mask_time = _timeMaskValues![mask_index]
            
        } else { mask_time = Double(mask_index) }
        
        let sens_max_time = timeMeasure![sens_index].count - 1
        
        let result = (mask_time! >= 0) && (mask_time! <= Double(sens_max_time))
        
        if result { delta_freq = DeltaF(sensnum: sens_index, index: Int(mask_time!)) }
        
        return (result, delta_freq)
    }
    
    func FindExtremumMinMax(sens_index: Int) -> Void
    {
        var mask_index = 0
        var minf: Double = 0
        var maxf: Double = 0
        var delta_freq: Double?
        
        extremumIndex![sens_index] = 0
        minIndex![sens_index] = extremumIndex![sens_index]
        maxIndex![sens_index] = minIndex![sens_index]
        
        if (DeltaFreqByMask(sens_index: sens_index, mask_index: mask_index).0)
        {
            delta_freq = DeltaFreqByMask(sens_index: sens_index, mask_index: mask_index).delta_freq
            maxf = delta_freq!
            minf = maxf
            while (DeltaFreqByMask(sens_index: sens_index, mask_index: mask_index).0)
            {
                mask_index += 1
                delta_freq = DeltaFreqByMask(sens_index: sens_index, mask_index: mask_index).delta_freq
                let time = Int(_timeMaskValues![mask_index])
                
                if (delta_freq! > maxf) {
                    maxIndex![sens_index] = time
                    maxf = delta_freq!
                }
                else if (delta_freq! < minf) {
                    minIndex![sens_index] = time
                    minf = delta_freq!
                }
            }
            extremumIndex![sens_index] = (abs(minf) > abs(maxf)) ? minIndex![sens_index] : maxIndex![sens_index]
        }
    }
    
    func CalculateSensorsStatistic()
    {
        for i in 0..<usedSensors!.count { FindExtremumMinMax(sens_index: i) }
    }
    
    func CalculateMeasureStatistic(calcSensorStatistic: Bool)
    {
        if calcSensorStatistic { CalculateSensorsStatistic() }
        
        for i in 0..<usedSensors!.count {
            if _showSensor![i] {
                measureDeltaFMin = DeltaF(sensnum: i, index: minIndex![i])
                measureDeltaFMax = DeltaF(sensnum: i, index: maxIndex![i])
                measureExtremum = Swift.abs(DeltaF(sensnum: i, index: extremumIndex![i]))
                break
            }
        }
        
        for i in 0..<usedSensors!.count {
            if _showSensor![i] {
                measureDeltaFMin = Swift.min(measureDeltaFMin!, DeltaF(sensnum: i, index: minIndex![i]))
                measureDeltaFMax = Swift.max(measureDeltaFMax!, DeltaF(sensnum: i, index: maxIndex![i]))
                measureExtremum = Swift.max(measureExtremum!,  abs(DeltaF(sensnum: i, index: extremumIndex![i])))
            }
        }
    }
    
    func CalculateKinektickSquare(sensorIndex: Int, duration: Double) -> Double {
        var square: Double = 0
        var freq1: Double = 0
        var freq2: Double = 0
        
        for k in 0..<_timeMaskValues!.count {
            if (_timeMaskValues![k] > duration) { break }
            
            freq1 = DeltaFreqByMask(sens_index: sensorIndex, mask_index: k - 1).delta_freq
            freq2 = DeltaFreqByMask(sens_index: sensorIndex, mask_index: k).delta_freq
            
            square += (freq1 + freq2) * (_timeMaskValues![k] - _timeMaskValues![k - 1])/2
        }
        
        return square
    }
    
    func AddSensorData(sensor: Sensor)
    {
        usedSensors?.append(sensor)
        freqMeasure?.append(Array<Double>(sensor.FreqMeasure))
        timeMeasure?.append(Array<Double>(sensor.TimeMeasure))
        startFreq?.append(sensor.StartFrequency)
    }
    
    func AddSensorData(sensor: Sensor, startFrequency: Double, timeValues: Array<Double>, freqValues: Array<Double>)
    {
        usedSensors?.append(sensor)
        freqMeasure?.append(freqValues)
        timeMeasure?.append(timeValues)
        startFreq?.append(startFrequency)
    }
    
    func DeltaF(sensnum: Int, index: Int) -> Double
    {
        return startFreq![sensnum] - freqMeasure![sensnum][index]
    }
    
    func SetTimeMask(mrows: Array<Double>)/*|error|DataRowCollection*/
    {
        _timeMaskValues?.removeAll()
        for /*sniffdbDataSet.MaskDataRow*/ mrow in mrows {
            _timeMaskValues?.append(mrow)//.TimeValue);
        }
        
        //подсчет кол-ва временных значений маски, которые соответствуют измерению
        _timeTicksCount = 0;
        while DeltaFreqByMask(sens_index: 0, mask_index: _timeTicksCount).0 { _timeTicksCount += 1 }
        
        CalculateMeasureStatistic(calcSensorStatistic: true)
    }
    
    var graphFreqDeltaMin: Double { get { return freqDeltaMin! } }
    
    var graphFreqDeltaMax: Double { get { return freqDeltaMax! } }
    
    var timeMaskValues: Array<Double> { get { return _timeMaskValues! } }
    
    var activeSensors: Array<Sensor> {
        get {
            var _activeSensors = Array<Sensor>()
            for i in 0..<usedSensors!.count {
                if _showSensor![i] { _activeSensors.append(usedSensors![i]) }
            }
            return _activeSensors
        }
    }
    
    var startFrequency: Array<Double> { get { return startFreq! } }
    
    var startTime: Double { get { return _startTime! } }
    
    var sensorsNumber: Int
        {
        get {
            var n = 0
            for i in 0..<usedSensorsNumber! { if _showSensor![i] { n += 1 } }
            
            return n
        }
    }
    
    //количество временных отсчетов в маске
    var timeTicksCount: Int {
        get {
            if (useTimeMask == true){ return _timeTicksCount }
            else {return timeMaskValues.count }
        }
    }
    
    var showSensor: [Bool] {
        get { return _showSensor! }
    }
}

struct MeasureStruct
{
    var sensors: Array<Sensor?>?
    var measureName: String?
    var startTime: NSDate?
    var ismeasured: Bool?
    var measureLength: Double?
    var maskID: Int?
    
    init(sens: Array<Sensor?>?, measName: String, stTime: NSDate, ismeasd: Bool, measLength: Double, mskID: Int)
    {
        sensors = sens;
        measureName = measName;
        startTime = stTime;
        ismeasured = ismeasd;
        measureLength = measLength;
        maskID = mskID;
    }
}
