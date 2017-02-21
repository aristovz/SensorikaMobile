//
//  TreeNodeTableViewCell.swift
//  TreeTableVIewWithSwift
//
//  Created by 二六三 on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import UIKit

class TreeNodeCell: UITableViewCell {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var nodeName: UILabel!
    @IBOutlet weak var nodeIMG: UIImageView!
    
    override func awakeFromNib() {
        self.viewWithTag(1)?.addDashedLine()
    }
}
