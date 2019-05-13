//
//  DetailTableViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/17.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    
    func setPair(name: String, value: String){
        self.name.text = name
        self.value.text = value
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
