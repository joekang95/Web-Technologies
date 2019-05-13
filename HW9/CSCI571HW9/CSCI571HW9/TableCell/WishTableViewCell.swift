//
//  WishTableViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/21.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit

class WishTableViewCell: UITableViewCell {

    @IBOutlet weak var wish_image: UIImageView!
    @IBOutlet weak var wish_title: UILabel!
    @IBOutlet weak var wish_price: UILabel!
    @IBOutlet weak var wish_shipping: UILabel!
    @IBOutlet weak var wish_zip: UILabel!
    @IBOutlet weak var wish_condition: UILabel!
    var wish_id: String!
    let wishList = UserDefaults.standard
    
    func setItems(item: Item){
        wish_title.text = item.title
        wish_price.text = "$\(round(100 * item.price) / 100)"
        wish_shipping.text = item.shippingCost
        wish_zip.text = item.zip
        wish_image.loadImage(imageURL: item.galleryURL)
        wish_condition.text = item.condition
        wish_id = item.itemID
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
