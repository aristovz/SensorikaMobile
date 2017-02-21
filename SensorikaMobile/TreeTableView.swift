//
//  TreeTableView.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

protocol TreeTableViewDelegate {
    func treeTableView(_ treeTabelView: TreeTableView, didSelectItem item: TreeNode)
}

class TreeTableView: UITableView {
    
    var mAllNodes: [TreeNode]?
    var mNodes: [TreeNode]?
    
    let GROUP_CELL_ID: String = "nodecell"
    let MEASURE_CELL_ID: String = "measureCell"
    
    var treeTableDelegate: TreeTableViewDelegate? = nil
    
    func loadData(_ data: [TreeNode]) {
        mAllNodes = data
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
        
        self.delegate = self
        self.dataSource = self
        
        self.register(UINib(nibName: "TreeNodeCell", bundle: nil), forCellReuseIdentifier: GROUP_CELL_ID)
        self.register(UINib(nibName: "MeasureCell", bundle: nil), forCellReuseIdentifier: MEASURE_CELL_ID)
        self.reloadData()
    }
    
    func expandOrCollapse(_ count: inout Int, node: TreeNode) {
        if node.isExpand {
            closedChildNode(&count,node: node)
        } else {
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    func closedChildNode(_ count:inout Int, node: TreeNode) {
        guard node.id! < 0 else { return }
        
        if node.isExpand {
            node.isExpand = false
            for item in node.children {
                count += 1
                closedChildNode(&count, node: item)
            }
        } 
    }
}

extension TreeTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node: TreeNode = mNodes![indexPath.row]
        
        if node.type == TreeNode.NODE_TYPE_G {
            let cell = tableView.dequeueReusableCell(withIdentifier: GROUP_CELL_ID) as! TreeNodeCell
            cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
            
            cell.nodeName.text = node.name
            cell.nodeIMG.image = node.icon!
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MEASURE_CELL_ID) as! MeasureCell
            cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
            
            cell.nameLabel.text = node.name
            cell.descriptionLabel.text = node.desc
         
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNodes == nil ? 0 : mNodes!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.deselectRow(at: indexPath, animated: true)
        
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.id! < 0 {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
            
            var indexPathArray :[IndexPath] = []
            var tempIndexPath: IndexPath?
            for i in startPosition..<endPosition {
                tempIndexPath = IndexPath(row: i, section: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            if parentNode.isExpand {
                self.insertRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            } else {
                self.deleteRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            }
            
            self.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        else {
            self.treeTableDelegate?.treeTableView(self, didSelectItem: parentNode)
        }
    }
}
