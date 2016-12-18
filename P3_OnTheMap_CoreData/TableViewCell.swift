//
//  TableViewCell.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 12/11/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: change from highlight cell to select cell

import UIKit

class TableViewCell: UITableViewCell {
    
    //Fields
    var mediaURL: String?
    
    //IBOutlets
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

