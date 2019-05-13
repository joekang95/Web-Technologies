//
//  SimilarItem.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/19.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import Foundation
import SwiftyJSON

class SimilarItem {
    var imageURL: String
    var itemID: String
    var itemURL: String
    var price: Double
    var shipping: Double
    var title: String
    var days: Int
    
    init(data: JSON){
        imageURL = data["imageURL"].stringValue
        title = data["title"].stringValue
        shipping = data["shipping"].doubleValue
        days = data["time"].intValue
        price = data["price"].doubleValue
        itemURL = data["url"].stringValue
        itemID = data["itemId"].stringValue
    }
    
}
