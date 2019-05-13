//
//  AutoTableViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/20.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit

class AutoTableViewCell: UITableViewCell {

    @IBOutlet weak var zipcode: UILabel!
    
    func setZips(zip: String) {
        zipcode.text = zip
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
