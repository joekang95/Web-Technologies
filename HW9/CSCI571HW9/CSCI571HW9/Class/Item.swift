//
//  Item.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/16.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Item {
    var galleryURL: String
    var itemID: String
    var itemURL: String
    var price: Double
    var shippingCost: String
    var title: String
    var zip: String
    var condition: String
    
    let map = [
        "1000" : "NEW",
        "2000" : "REFURBISHED",
        "2500" : "REFURBISHED",
        "3000" : "USED",
        "4000" : "USED",
        "5000" : "USED",
        "6000" : "USED"
    ]
    
    init(data: JSON) {
        galleryURL = data["galleryURL"].stringValue
        title = data["title"].stringValue
        price = data["price"].doubleValue
        shippingCost = data["shippingCost"].stringValue
        zip = data["zip"].stringValue
        itemID = data["itemId"].stringValue
        itemURL = data["itemURL"].stringValue
        condition = map[data["condition"].stringValue] ?? "NA"
    }
    
    init(data: [String : Any]) {
        galleryURL = data["galleryURL"] as! String
        title = data["title"] as! String
        price = data["price"] as! Double
        shippingCost = data["shippingCost"] as! String
        zip = data["zip"] as! String
        itemID = data["itemID"] as! String
        itemURL = data["itemURL"] as! String
        condition = data["condition"] as! String
    }
    
    func encode() -> Any{
        var data: [String : Any] = [:]
        data["galleryURL"] = galleryURL
        data["title"] = title
        data["price"] = price
        data["shippingCost"] = shippingCost
        data["zip"] = zip
        data["itemID"] = itemID
        data["itemURL"] = itemURL
        data["condition"] = condition
        //print(data)
        return data
    }
}
