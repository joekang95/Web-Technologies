//
//  Extension.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/18.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import Foundation
import UIKit


extension String {
    func urlEncode() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    func urlDecode() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func unescape() -> String {
        var unescaped = self
        let characters = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'"
        ];
        for (key, value) in characters {
            unescaped = unescaped.replacingOccurrences(of: key, with: value, options: .literal, range: nil)
        }
        return unescaped
    }
    
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let template = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = template
        self.tintColor = color
    }
    
    func loadImage(imageURL: String) {
        if(imageURL != "N/A") {
            let url = URL(string: imageURL)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        else {
            self.image = UIImage()
        }
    }
}
