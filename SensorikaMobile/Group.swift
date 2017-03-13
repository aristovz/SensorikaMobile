//
//  Group.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {
    dynamic var id: Int = -1
    dynamic var name: String = ""
    let parentId = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static var negativeIncrementID: Int {
        return (uiRealm.objects(Group.self).max(ofProperty: "id") as Int? ?? 0) - 1
    }
}
