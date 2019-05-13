//
//  ResultTableViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/16.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import Toast_Swift

protocol ResultCellDelegate {
    func updateWish(cell: UITableViewCell)
}

class ResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var product_image: UIImageView!
    @IBOutlet weak var product_title: UILabel!
    @IBOutlet weak var product_price: UILabel!
    @IBOutlet weak var product_shipping: UILabel!
    @IBOutlet weak var product_condition: UILabel!
    @IBOutlet weak var product_zipcode: UILabel!
    @IBOutlet weak var product_wish: UIButton!
    var product_id: String!
    let wishList = UserDefaults.standard
    
    func setItems(item: Item){
        product_title.text = item.title
        product_price.text = "$\(round(100 * item.price) / 100)"
        product_shipping.text = item.shippingCost
        product_zipcode.text = item.zip
        product_image.loadImage(imageURL: item.galleryURL)
        product_condition.text = item.condition
        product_id = item.itemID
        checkWish(button: product_wish)
    }
    
    var delegate: ResultCellDelegate?
    @IBAction func wishPressed(_ sender: UIButton) {
        delegate?.updateWish(cell: self)
        checkWish(button: sender)
    }
    
    func checkWish(button: UIButton) {
        let wishItems = wishList.object(forKey: "wish") as? [String : Any]
        if(wishItems != nil) {
            if(wishItems![product_id] != nil) {
                button.setBackgroundImage(UIImage(named: "wishListFilled"), for: .normal)
            }
            else {
                button.setBackgroundImage(UIImage(named: "wishListEmpty"), for: .normal)
            }
        }
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
