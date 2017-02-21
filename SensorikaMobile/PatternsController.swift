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

class PatternsController: UIViewController, IndicatorInfoProvider, TreeTableViewDelegate {
    
    var itemInfo: IndicatorInfo = "Шаблоны"
    
    @IBOutlet weak var treeTableView: TreeTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func addPattern() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addPatternsController") as! AddPatternsController
        
        present(vc, animated: true, completion: nil)
    }
    
    func treeTableView(_ treeTabelView: TreeTableView, didSelectItem item: TreeNode) {
        if let measure = uiRealm.object(ofType: MeasureObject.self, forPrimaryKey: item.id) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "addPatternsController") as! AddPatternsController
            vc.currentMeasure = measure
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
