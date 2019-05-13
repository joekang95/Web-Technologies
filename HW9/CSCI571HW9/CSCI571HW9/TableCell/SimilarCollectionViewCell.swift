//
//  SimilarCollectionViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/19.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit

class SimilarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var similar_image: UIImageView!
    @IBOutlet weak var similar_title: UILabel!
    @IBOutlet weak var similar_shipping: UILabel!
    @IBOutlet weak var similar_days: UILabel!
    @IBOutlet weak var similar_price: UILabel!
    
    var imageCache: [String: UIImage] = [:]
    
    func setCollection(item: SimilarItem) {
        
        if (imageCache[item.imageURL] != nil) { 
            self.similar_image.image = imageCache[item.imageURL]
        }
        else {
            let url = URL(string: item.imageURL)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.similar_image.image = UIImage(data: data!)
                    self.imageCache[item.imageURL] = UIImage(data: data!)
                }
            }
        }
        similar_title.text = item.title
        similar_shipping.text = "$\(item.shipping)"
        if (item.days < 2) { similar_days.text = "\(item.days) Day Left" }
        else { similar_days.text = "\(item.days) Days Left" }
        
        if (floor(item.price) == item.price) { similar_price.text = "$\(item.price)0" }
        else { similar_price.text = "$\(item.price)"}
    }
}
