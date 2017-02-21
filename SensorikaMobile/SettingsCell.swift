//
//  SettingsCell.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 18.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var freqLabel: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var dashLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = colorView.frame.height / 2
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.white.cgColor
        
        dashLine.addDashedLine(color: UIColor.lightGray.withAlphaComponent(0.5))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
