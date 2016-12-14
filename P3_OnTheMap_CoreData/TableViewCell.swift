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

    // todo: move this? automatically opens a safari window when map selected
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        let app = UIApplication.shared
//        
//        if let urlString = mediaURL {
//            if let url = URL(string: urlString) {
//                app.openURL(url)
//            } else {
//                print("Invalid URL")
//            }
//        } else {
//            print("No URL given")
//        }
//        if let urlString = mediaURL {
//            guard let url = URL(string: urlString) else {
//                print("missing url")
//                return
//            }
//            
//            app.openURL(url)
//        } else {
//            print("no student url found")
//            
//        }
//    }
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(<#T##highlighted: Bool##Bool#>, animated: <#T##Bool#>)
//        }
}

