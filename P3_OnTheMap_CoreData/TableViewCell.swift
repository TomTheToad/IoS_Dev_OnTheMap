//
//  TableViewCell.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 12/11/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/*

Custom cell for TableView to allow for hidden mediaURL
 
*/

import UIKit

class TableViewCell: UITableViewCell {
    
    //Fields
    var mediaURL: String?
    
    //IBOutlets
    // @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

