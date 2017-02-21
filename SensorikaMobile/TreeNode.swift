//
//  TreeNode.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

open class TreeNode {
    static let NODE_TYPE_G: Int = 0
    static let NODE_TYPE_N: Int = 1
    
    var type: Int?
    var desc: String?
    var id: Int?
    var parentId: Int?
    var name: String?
    var level: Int?
    var isExpand: Bool = false
    var icon: UIImage?
    var children: [TreeNode] = []
    var parent: TreeNode?
    
    init (desc: String?, id:Int? , parentId: Int? , name: String?) {
        self.desc = desc
        self.id = id
        self.parentId = parentId
        self.name = name
    }
    
    func isRoot() -> Bool{
        return parent == nil
    }

    func isParentExpand() -> Bool {
        return parent?.isExpand ?? false
    }
    
    func isEmpty() -> Bool {
        return children.count == 0
    }
    
    func getLevel() -> Int {
        return parent == nil ? 0 : parent!.getLevel() + 1
    }
    
    func setExpand(_ isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            children.map { $0.setExpand(isExpand) }
        }
    }
    
    func setIcon(_ icon: UIImage) {
        self.icon = icon
    }
}
