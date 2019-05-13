//
//  ShippingTableViewCell.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/18.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit

class ShippingTableViewCell: UITableViewCell {

    @IBOutlet weak var table_value: UILabel!
    @IBOutlet weak var table_name: UILabel!
    @IBOutlet weak var star_image: UIImageView!
    var url: String!
    let color_map = [
        "Yellow" : UIColor.yellow,
        "Blue" : UIColor.blue,
        "Turquoise" : UIColor(red: 64 / 255, green: 224 / 255, blue: 208 / 255, alpha: 1),
        "Purple" : UIColor.purple,
        "Red" : UIColor.red,
        "Green" : UIColor.green,
        "YellowShooting" : UIColor.yellow,
        "TurquoiseShooting" : UIColor(red: 64 / 255, green: 224 / 255, blue: 208 / 255, alpha: 1),
        "PurpleShooting" : UIColor.purple,
        "RedShooting" : UIColor.red,
        "GreenShooting" : UIColor.green,
        "SilverShooting" : UIColor(red: 192 / 255, green: 192 / 255, blue: 192 / 255, alpha: 1)
    ]
    
    func setPair(pair: [String: Any]) {
        for (name, value) in pair {
            self.table_name.text = name
            if (name == "Store Name") {
                let values = value as! NSArray
                let text = (values[0] as! String).unescape()
                self.table_value.text = text
                if values.count > 1 {
                    self.url = values[1] as? String
                    let tap = UITapGestureRecognizer(target: self, action: #selector(openURL))
                    table_value.isUserInteractionEnabled = true
                    table_value.addGestureRecognizer(tap)
                    table_value.textColor = UIColor(red: 0, green: 0, blue: 200 / 255, alpha: 1)
                    table_value.attributedText = NSAttributedString(string: text, attributes:
                        [.underlineStyle: NSUnderlineStyle.single.rawValue])
                }
            }
            else if (name == "Feedback Star") {
                self.table_value.isHidden = true
                let feedback = value as! String
                self.star_image.image = (feedback.contains("Shooting")) ? UIImage(named: "starBorder") : UIImage(named: "star")
                self.star_image.setImageColor(color: color_map[feedback] ?? UIColor.black)
            }
            else {
                self.table_value.text = value as? String
            }
        }
    }
    
    
    @objc func openURL() {
        if let openURL = URL(string: url.urlEncode()) {
            UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
