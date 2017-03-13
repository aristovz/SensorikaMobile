//
//  PatternsController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 16.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift

class PatternsController: UIViewController, IndicatorInfoProvider, TreeTableViewDelegate, UITextFieldDelegate {
    
    var itemInfo: IndicatorInfo = "Шаблоны"
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var addItemView: UIView!
    @IBOutlet weak var treeTableView: TreeTableView!
    
    @IBOutlet weak var namePatternField: UITextField!
    
    var effect:UIVisualEffect!
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualEffectView.alpha = 0
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        addItemView.layer.cornerRadius = 5
        startButtonOutlet.layer.cornerRadius = startButtonOutlet.frame.height / 2
        
        startButtonOutlet.layer.borderWidth = 1
        startButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
        
        treeTableView.treeTableDelegate = self
        
        let button = UIButton(frame: CGRect(x: self.view.frame.width - 65, y: self.view.frame.height - 200, width: 50, height: 50))
        button.layer.cornerRadius = 25
        button.backgroundColor = UIColor.buttonBorder
        button.titleLabel?.textColor = .white
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        
        button.addTarget(self, action: #selector(addPattern), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let measures = Array(uiRealm.objects(MeasureObject.self))
        var groups: Array<AnyObject> = Array(uiRealm.objects(Group.self))
        
        measures.forEach { groups.append($0) }
        
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(groups, defaultExpandLevel: 0)
        
        treeTableView.loadData(nodes)
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
    
    func addPattern() {
        animateIn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.addItemView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.addItemView.transform = CGAffineTransform(translationX: 0, y: -80)
        }, completion: nil)
    }

    
    func treeTableView(_ treeTabelView: TreeTableView, didSelectItem item: TreeNode) {
        if let measure = uiRealm.object(ofType: MeasureObject.self, forPrimaryKey: item.id) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "addPatternsController") as! AddPatternsController
            vc.currentMeasureObject = measure
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        guard namePatternField.text != "" else {
            namePatternField.shake()
            return
        }
        
        let vc = Global.appDelegate.mainStoryBoard.instantiateViewController(withIdentifier: "activeMeasureNavController") as! UINavigationController
        
        let newMeasure = MeasureObject(value: ["id" : MeasureObject.incrementID!, "name" : namePatternField.text!, "mask" : Global.standartMask])
        (vc.viewControllers[0] as! ActiveMeasureController).newMeasure = newMeasure
        
        let mask = newMeasure.getMaskValues()
        if mask.count != 0 {
            Global.measureLength = Int(mask.last!)
        }
        
        namePatternField.text = ""
        animateOut()
        present(vc, animated: true, completion: nil)
    }
    
}
