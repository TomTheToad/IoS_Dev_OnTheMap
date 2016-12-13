//
//  TableViewCell.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 12/11/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let app = UIApplication.shared
        if let urlString = mediaURL {
            guard let url = URL(string: urlString) else {
                print("missing url")
                return
            }
            
            app.openURL(url)
        }
    }

}
