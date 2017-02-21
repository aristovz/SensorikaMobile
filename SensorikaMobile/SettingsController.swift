//
//  SettingsController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 17.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SettingsController: UITableViewController, IndicatorInfoProvider {
    var itemInfo = IndicatorInfo(title: "Настройки")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "SettingsCell", bundle: nil) , forCellReuseIdentifier: "settingsCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Global.SENSORS.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell

        if let currentSensor = Global.SENSORS[indexPath.row] {
            cell.nameLabel.text = "\(currentSensor.Name) \(currentSensor.SID)"
            cell.freqLabel.text = "\(currentSensor.BaseFrequency) ± \(currentSensor.Amplitude)"
            cell.colorView.backgroundColor = currentSensor.Color
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "settingsDetailController") as! SettingsDetailController
        vc.currentSensor = Global.SENSORS[indexPath.row]
        
        present(vc, animated: true, completion: nil)
        //show(vc, sender: tableView)
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
