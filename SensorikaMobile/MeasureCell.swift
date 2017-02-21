//
//  MeasureCell.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 20.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class MeasureCell: UITableViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        self.viewWithTag(1)?.addDashedLine()
    }
    
}
