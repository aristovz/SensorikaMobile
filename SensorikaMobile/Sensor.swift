//
//  Sensor.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 13.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

enum Stability: Int {
    case Stable = 0
    case NotStable  = 1
    case OutOfRange = 2
    case IsChecking = 3
    case NotDefined = 4
    case IsMeasuring = 5
}

class Sensor {
    private var sid: String = ""
    private var name: String = ""
    private var abbreviation: String = ""
    private var descript: String = ""
    private var settings: String = ""
    private var id: Int = -1
    
    private var color = UIColor.black
    //номер ячейки сенсора в выбранном профиле
    private var position: Int = -1
    //базовая частота сенсора по паспорту
    var mainfreq: Double = -1
    //частота, с которой фактически началось измерение
    var startMeasureFreq: Double = -1
    //флаг, показывающий, определена ли стартовая частота сенсора для измерения
    var baseFreqSet = false
    
    //допустимое по паспорту отклонение от базовой частоты (амплитуда)
    var amp: Double = 0
    //сенсор активен, если он задействован в профиле измерения
    var bActive = true
    
    var delegate: SensorDelegate? = nil
    
    //string[] stabText = new string[6] { Global.GetString("SensorStable"), Global.GetString("SensorNotStable"), Global.GetString("FrequencyOutOfPassRange"), Global.GetString("NoData"), Global.GetString("CheckingSensorStability"), "" };
    
    //поверхность элемента управления для вывода графика
    //Control drawBox;
    
    //буффер для хранения считываемых данных (объекты double время, частота)
    var bufferTimeMonitoring = Array<Double>()
    var bufferTimeMeasure = Array<Double>()
    
    var bufferFreqMonitoring = Array<Double>()
    var bufferFreqMeasure = Array<Double>()
    
    //размер буфера данных для холостого режима считывания (измерение не начато)
    var bufferSize = 21
    //индекс последнего добавленного отсчета в буфере
    var bufferIndex = -1
    
    //индексы значений минимальной и максимальной частоты сенсора в холостом режиме
    var indexMinMoni: Int = -1
    var indexMaxMoni: Int = -1
    
    //индексы значений минимальной и максимальной частоты сенсора в режиме измерения
    //int indexMinMeas, indexMaxMeas;
    
    //индекс максимального отклонения от базовой частоты в режиме измерения
    var indexExtremum = 0
    
    //холостой режим: время первого отсчета, время последнего добавленного отсчета в буфере
    private var startTime = Date()
    private var lastTime = Date()
    
    //режим измерения: время первого отсчета, время последнего добавленного отсчета в буфере
    var startMeasureTime = Date()
    var lastMeasureTime = Date()
    
    //время (сек.), в течение которого отсчеты сенсора непрерывно стабильны
    var stableTime: Double = 0.0
    // период непрерывной стабильности (сек.), с которого можно начинать измерение
    var stabilityPeriod = 20.0
    
    //флаг начала измерения
    var measureStarted = false
    
    var Color: UIColor {
        get { return color }
        set { color = newValue }
    }
    
    var Position: Int {
        get { return position }
        set { position = newValue }
    }
    
    var IndexExtremum: Int {
        get { return indexExtremum }
    }
    
    var Amplitude: Double {
        get { return amp }
        set { amp = newValue }
    }
    
    var BaseFrequency: Double {
        get { return mainfreq }
        set { mainfreq = newValue }
    }
    
    var Description: String {
        get { return descript }
    }
    
    var Name: String {
        get { return name }
        set { name = newValue }
    }
    
    var Abbreviation: String {
        get { return abbreviation }
        set { abbreviation = newValue }
    }
    
    var SID: String {
        get { return "[" + sid + "]"; }
    }
    
    var Sid: String {
        get { return sid }
        set { sid = newValue }
    }
    
    var ID: Int {
        get { return id }
        set { id = newValue }
    }
    
    var description: String
    {
        return self.Name + " " + self.SID
    }
    
    var BufferSize: Int {
        get { return bufferSize }
    }
    
    var IsActive: Bool {
        get { return bActive }
        set { bActive = newValue }
    }
    
    var BaseFrequencyMax: Double {
        get { return mainfreq + amp }
    }
    
    var BaseFrequencyMin: Double {
        get { return mainfreq - amp }
    }
    
    var StartFrequency: Double {
        get {
            if (bufferFreqMeasure.count == 0) { return 0 }
            return startMeasureFreq
        }
        set { startMeasureFreq = newValue }
    }
    
    var TimeMeasure: Array<Double> {
        get { return bufferTimeMeasure }
    }
    
    var FreqMeasure: Array<Double> {
        get { return bufferFreqMeasure }
    }
    
    var MeasureStarte: Bool {
        get { return measureStarted }
    }
    
    var StartTime: Date {
        get { return startTime }
        set { startTime = newValue }
    }
    
    var Duration: TimeInterval {
        get { return lastTime.timeIntervalSince(startTime) }
    }
    
    var MeasureDuration: TimeInterval {
        get { return lastMeasureTime.timeIntervalSince(startMeasureTime) }
    }

    //возвращает индекс последнего отсчета в буффере,
    //добавленного c помощью AddNoseData(time, freq)
    var LastAddedBufferIndex: Int {
        get { return bufferIndex }
    }
    
    var StabilityStatus: Stability
    {
        get
        {
            //стабильность в режиме измерения не учитывается
            if measureStarted { return Stability.IsMeasuring }
            
            //буффер пуст, стабильность не определяется
            if bufferFreqMonitoring.count == 0 { return Stability.NotDefined }
            
            //идет набор данных для проверки стабильности
            if self.Duration < stabilityPeriod { return Stability.IsChecking }
            
            //сенсор стабилен
            if stableTime >= stabilityPeriod { return Stability.Stable }
            
            //сенсор не стабилен
            if ((bufferFreqMonitoring[bufferIndex] >= (mainfreq - 2 * amp)) &&
                (bufferFreqMonitoring[bufferIndex] <= (mainfreq + 2 * amp))) { return Stability.NotStable }
            
            //частота сенсора не соответствует паспорту
            return Stability.OutOfRange;
        }
    }
    
    func getStabilityColor() -> UIColor {
        let status = self.StabilityStatus
        
        if (status == .IsChecking ||
            status == .NotDefined ||
            status == .IsMeasuring) {
            return .lightGray
        }
        if (status == .NotStable) {
            return .yellow
        }
        if (status == .OutOfRange) {
            return .red
        }
        else { return .green }
    }
    
    var ExtremumOfFreq: Double {
        get
        {
            if indexExtremum >= bufferFreqMeasure.count { return 0 }
            return startMeasureFreq - bufferFreqMeasure[indexExtremum]
        }
    }
    
    var TimeOfExtremum: Double {
        get
        {
            if indexExtremum >= bufferTimeMeasure.count { return 0 }
            return bufferTimeMeasure[indexExtremum]
        }
    }
    
    init() {
        bufferTimeMonitoring = Array<Double>()// new List<double>(bufferSize);
        bufferFreqMonitoring = Array<Double>()// new List<double>(bufferSize);
        bufferTimeMeasure = Array<Double>()//new List<double>()
        bufferFreqMeasure = Array<Double>()//new List<double>()
        self.EndMeasure();
    }
    
    init(name: String, sid: String, id: Int, mainfreq: Double, amp: Double, abbreviation: String, color: UIColor) {
        InitData(name: name, sid: sid, id: id, mainfreq: mainfreq, amp: amp, abbreviation: abbreviation, color: color)
    }
    
    private func InitData(name: String, sid: String, id: Int, mainfreq: Double, amp: Double, abbreviation: String, color: UIColor) {
        self.name = name
        self.sid = sid
        self.id = id
        self.mainfreq = mainfreq
        self.amp = amp
        self.color = color
        self.abbreviation = abbreviation
        bufferTimeMonitoring = Array<Double>()// new List<double>(bufferSize);
        bufferFreqMonitoring = Array<Double>()// new List<double>(bufferSize);
        bufferTimeMeasure = Array<Double>()//new List<double>()
        bufferFreqMeasure = Array<Double>()//new List<double>()
        self.EndMeasure()
    }
    
    func StartMeasure() {
        if !measureStarted {
            ClearMeasureData()
            measureStarted = true
        }
    }
    
    func EndMeasure() {
        measureStarted = false
        startMeasureTime = Date()
        lastMeasureTime = Date()
        baseFreqSet = false
    }
    
    func ClearBufferData() {
        bufferTimeMonitoring.removeAll()
        bufferFreqMonitoring.removeAll()
        bufferIndex = -1
    }
    
    func ClearMeasureData() {
        bufferTimeMeasure.removeAll()
        bufferFreqMeasure.removeAll()
        baseFreqSet = false
    }
    
    internal func AddSensorData(time: Date, freq: Double)
    {
        if !IsActive { return }

        if !measureStarted {
            AddSensorDataMonitoring(time: time, freq: freq)
            self.delegate?.sensor(self, didAddData: freq, time: time)
        }
        else { AddSensorDataMeasure(time: time, freq: freq) }
    }
    
    func AddSensorDataMonitoring(time: Date, freq: Double) {
        if !IsActive { return }
        
        //размеры массивов Time и Frequency совпадают
        let size = bufferFreqMonitoring.count
        
        //если буфер пуст, запоминаем время первого отсчета (совпадает с последним)
        //cбрасываем индексы буффера и минимума / максимума
        if (size == 0)
        {
            startTime = time
            lastTime = time
            stableTime = 0
            bufferIndex = -1
            indexMinMoni = 0
            indexMaxMoni = 0
        }
    
        //время с момента первого отсчета
        let duration = time.timeIntervalSince(startTime)
        
        //первоначальное заполнение буффера
        if (size < bufferSize)
        {
            bufferTimeMonitoring.append(duration)
            bufferFreqMonitoring.append(freq)
            bufferIndex += 1
            if bufferIndex > 0 {
                //Запоминаем индекс максимальной частоты
                if freq > bufferFreqMonitoring[indexMaxMoni] { indexMaxMoni = bufferIndex }
                //Запоминаем индекс минимальной частоты
                if freq < bufferFreqMonitoring[indexMinMoni] { indexMinMoni = bufferIndex }
            }
        }
        //заполнение буффера в цикле
        else
        {
            bufferIndex += 1
            
            if bufferIndex >= bufferSize { bufferIndex = 0 }
            
            bufferTimeMonitoring[bufferIndex] = duration
            bufferFreqMonitoring[bufferIndex] = freq
        
            //поиск минимума
            //цикл дошел до предыдущего минимума
            if bufferIndex == indexMinMoni {
                indexMinMoni = 0
                //ищем новый индекс минимальной частоты
                for i in 0..<bufferFreqMonitoring.count {
                    if bufferFreqMonitoring[i] < bufferFreqMonitoring[indexMinMoni] { indexMinMoni = i }
                }
            }
            else if freq <= bufferFreqMonitoring[indexMinMoni] { indexMinMoni = bufferIndex }
        
            //поиск максимума
            //цикл дошел до предыдущего максимума
            if bufferIndex == indexMaxMoni {
                indexMaxMoni = 0
                //ищем новый индекс максимальной частоты
                for i in 0..<bufferFreqMonitoring.count {
                    if bufferFreqMonitoring[i] > bufferFreqMonitoring[indexMaxMoni] { indexMaxMoni = i }
                }
            }
            else if freq >= bufferFreqMonitoring[indexMaxMoni] { indexMaxMoni = bufferIndex }
        }
        
        //измеряем время стабильности
        if self.CheckFreqStability(freq: freq) == Stability.Stable {
            stableTime += time.timeIntervalSince(lastTime) }
        else {
            stableTime = 0
        }
        
        //запоминаем время последнего добавленного отсчета
        lastTime = time
    }
    
    func AddSensorDataMeasure(time: Date, freq: Double) {
        if !IsActive { return }
        
        //запоминаем первую частоту в качестве базовой
        if !baseFreqSet {
            baseFreqSet = true
            startMeasureFreq = freq
            return
        }
        
        //размеры массивов Time и Frequency совпадают
        let size = self.bufferFreqMeasure.count
        
        //если буфер пуст, cбрасываем индексы буффера и запоминаем время первого отсчета
        if size == 0 {
            startMeasureTime = time
            lastMeasureTime = time
            indexExtremum = 0
            //indexMinMeas = 0
            //indexMaxMeas = 0
        }
        
        //время с момента первого отсчета
        let duration = time.timeIntervalSince(startMeasureTime)
        
        //в режиме измерения данные добавляются до конца измерения
        self.bufferTimeMeasure.append(duration)
        self.bufferFreqMeasure.append(freq)
        
        //запоминаем индекс точки экстремума
        if self.bufferTimeMeasure.count > 1 {
            let i = self.bufferTimeMeasure.count - 1
            let prevExtr = abs(startMeasureFreq - self.bufferFreqMeasure[indexExtremum])
            let Extr = abs(startMeasureFreq - freq)
            
            if Extr > prevExtr { indexExtremum = i }
        }
        
        //запоминаем время последнего добавленного отсчета
        lastMeasureTime = time
    }
    
    internal func CheckFreqStability(freq: Double) -> Stability {
        if ((freq >= self.BaseFrequencyMin) && (freq <= self.BaseFrequencyMax)) { return Stability.Stable }
        
        if ((freq >= self.BaseFrequencyMin - amp) && (freq <= self.BaseFrequencyMax + amp)) { return Stability.NotStable }
        
        return Stability.OutOfRange
    }
    
    func DeltaF(index: Int) -> Double { return self.StartFrequency - self.FreqMeasure[index] }
    
    //возвращает индекс отсчета, который отстоит от fromIndex на offset позиций
    //функция необходима, т. к. буфер в холостом режиме заполняется циклически
    //в качестве ошибки возвращает отриц. значение
    internal func GetIndexWithOffset(fromIndex: Int, offset: Int) -> Int {
        if ((fromIndex < 0) || (fromIndex >= bufferTimeMonitoring.count)) { return -1 }
        
        if (abs(offset) >= bufferTimeMonitoring.count) { return -1 }
        
        var index = fromIndex + offset
        
        if index < 0 { index += bufferTimeMonitoring.count }
        else if index >= bufferTimeMonitoring.count { index -= bufferTimeMonitoring.count }
        
        if offset < 0 {
            if (bufferTimeMonitoring[index] > bufferTimeMonitoring[fromIndex]) { return -1 }
        }
        else if offset > 0 {
            if (bufferTimeMonitoring[index] < bufferTimeMonitoring[fromIndex]) { return -1 }
        }
        
        return index
    }
}

class SensorObject: Object {
    dynamic var sid: String = ""
    dynamic var name: String = ""
    dynamic var abbreviation: String = ""
    //dynamic var descript: String = ""
    dynamic var id: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var color: String = "000000"
    
    dynamic var mainfreq: Double = -1
    dynamic var amp: Double = 0
}

class SensorsArray
{
    var sensors: Array<Sensor?>
    
    init() {
        sensors = Array<Sensor?>()
    }
    
    subscript(index: Int) -> Sensor? {
        get { return sensors[index] }
        set {
            if ((index < 0) || (index >= sensors.count)) { return }
            sensors[index] = newValue
        }
    }
    
    var count: Int {
        get { return sensors.count }
    }
    
    var Items: Array<Sensor?> {
        get { return sensors }
    }
    
    func LoadSensor(id: Int) {
        if let sens = uiRealm.object(ofType: SensorObject.self, forPrimaryKey: id) {
            for k in 0..<Global.SENSORS.count {
                if Global.SENSORS[k]?.ID == id {
                    Global.SENSORS[k] = Sensor(name: sens.name, sid: sens.sid, id: sens.id, mainfreq: sens.mainfreq, amp: sens.amp, abbreviation: sens.abbreviation, color: UIColor(hexString: sens.color))
                }
            }
        }
    }
    
    func LoadSensor()
    {
        let sensors = uiRealm.objects(SensorObject.self)
        if sensors.count != 4 {
            try! uiRealm.write {
                for sensor in sensors {
                    uiRealm.delete(sensor)
                }
                
                let colors = ["4EDDE8", "941EBD", "EB008A", "006FE5"]
                for k in 0..<4 {
                    let freq: Double = 100.0 * Double(k + 1)
                    let sens = SensorObject(value: ["id" : k, "name" : "Сенсор \(k + 1)", "sid" : "SID00\(k + 1)", "abbreviation" : "сенс\(k + 1)", "mainfreq" : freq, "amp" : 24, "color" : colors[k]])
                    uiRealm.add(sens)
                }
                LoadSensor()
            }
        }
        else {
            Global.SENSORS.sensors.removeAll()
            for sens in sensors {
                let sensor = Sensor(name: sens.name, sid: sens.sid, id: sens.id, mainfreq: sens.mainfreq, amp: sens.amp, abbreviation: sens.abbreviation, color: UIColor(hexString: sens.color))
                self.sensors.append(sensor)
            }
        }
    
    }
    
    func GetByID(id: Int) -> Sensor? {
        for sensor in self.sensors {
            if sensor != nil && sensor!.ID == id {
                return sensor
            }
        }
        
        return nil
    }
    
    func GetBySID(sid: String) -> Sensor? {
        for sensor in self.sensors {
            if sensor != nil && sensor!.Sid == sid {
                return sensor
            }
        }
        
        return nil
    }
}

protocol SensorDelegate {
    func sensor(_ sensor: Sensor, didAddData data: Double, time: Date)
}
