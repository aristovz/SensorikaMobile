 //
//  ViewController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 26.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PagesViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor.background
        settings.style.buttonBarItemBackgroundColor = UIColor.background
        settings.style.selectedBarBackgroundColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = UIFont(name: "HelveticaNeue-Regular", size:14) ?? UIFont.systemFont(ofSize: 14)
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
            newCell?.label.textColor = .white
        }
        super.viewDidLoad()
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "mainController") as! MainController
        
        let child_2 = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "patternsController") as! PatternsController
        
        let child_3 = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "settingsController") as! SettingsController
        
        return [child_1, child_2, child_3]
    }

}

