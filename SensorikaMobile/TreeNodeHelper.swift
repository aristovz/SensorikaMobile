//
//  TreeNodeHelper.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation

class TreeNodeHelper {
    
    static let sharedInstance: TreeNodeHelper = TreeNodeHelper()
    
    func getSortedNodes(_ groups: Array<AnyObject>, defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        
        let nodes = convetData2Node(groups)
        let rootNodes = getRootNodes(nodes)
        
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    func filterVisibleNode(_ nodes: [TreeNode]) -> [TreeNode] {
        var result: [TreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(item)
                result.append(item)
            }
        }
        return result
    }
    
    func convetData2Node(_ groups: Array<AnyObject>) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        
        for item in groups {
            if let group = item as? Group {
                node = TreeNode(desc: "", id: group.id, parentId: group.parentId.value, name: group.name)
                nodes.append(node)
            }
            else if let measure = item as? MeasureObject {
                node = TreeNode(desc: "", id: measure.id, parentId: measure.groupId.value, name: measure.name) //desc: "Площадь: \(measure.square)"
                nodes.append(node)
            }
        }
        
        for node in nodes {
            node.children = nodes.filter({ $0.parentId == node.id })
            node.children.forEach { $0.parent = node }
        }
        
        for item in nodes {
            setNodeIcon(item)
        }
        
        return nodes
    }
    
    func getRootNodes(_ nodes: [TreeNode]) -> [TreeNode] {
        return nodes.filter { $0.isRoot() }
    }
    
    func addNode(_ nodes: inout [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        
        guard !node.isEmpty() else { return }
        
        for i in 0 ..< node.children.count {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    func setNodeIcon(_ node: TreeNode) {
        if node.id! < 0 {
            node.type = TreeNode.NODE_TYPE_G
            node.setIcon(node.isExpand ? #imageLiteral(resourceName: "tree_ex") : #imageLiteral(resourceName: "tree_ec"))
        } else {
            node.type = TreeNode.NODE_TYPE_N
        }
    }
    
    
}
