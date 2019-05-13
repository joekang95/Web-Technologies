//
//  PhotosViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/23.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class PhotosViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var photos_scroll: UIScrollView!
    var name: String = ""
    var imageURLs: [String] = ["https://www.batteriesinaflash.com/images/photolithium/EVERGREEN-CR123-2pk.jpg",
                               "https://ssli.ebayimg.com/images/g/CnMAAOxyUrZSxIzW/s-l1600.jpg",
                               "https://cdn.shopify.com/s/files/1/0906/6148/products/panasonic_cr123_12_1400x.png?v=1498330290",
                               "https://cdn.shopify.com/s/files/1/0906/6148/products/panasonic_cr123_24_1400x.png?v=1498330205",
                               "https://cdn.shopify.com/s/files/1/0906/6148/products/panasonic_cr123_4_1400x.png?v=1498330318",
                               "https://www.batteriesinaflash.com/images/photolithium/EL123AP-2_4.jpg",
                               "http://www.mdbattery.com/media/catalog/product/cache/1/image/b3a8e609207b98f816d2e823965d62b1/E/B/EB-1020-CR123-SM-KH_EL123A-2011-GM_3.jpg",
                               "https://www.batteriesinaflash.com/images/LifePO4/LFP123A-CHARGER.jpg"]
    //var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Google Images...")
        
        photos_scroll.delegate = self
        fetchGoogleImage()
        //imageURLs.removeAll()
        //setImages()
    }
    
    func fetchGoogleImage() {
        let url = "http://hi9mi9tsu9.us-east-2.elasticbeanstalk.com/searchPhotos?name=\(name)"
        imageURLs.removeAll()
        Alamofire.request(url.urlEncode()).responseJSON{ response in
            switch response.result {
            case .success(_):
                let data = JSON(response.result.value!)
                self.imageURLs.removeAll()
                for (_, url) in data {
                    self.imageURLs.append(url.stringValue)
                }
                self.setImages()
            case .failure(_):
                print("Error: \(String(describing: response.error))")
                SwiftSpinner.hide()
            }
        }
    }
    
    func setImages() {
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        var y: CGFloat = 0
        for i in 0..<imageURLs.count {
            Alamofire.request(imageURLs[i]).response { response in
                if let data = response.data {
                    let image = UIImage(data: data)
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    
                    frame.origin.y = y
                    
                    let ratio = (image?.size.width)! / (image?.size.height)!
                    let height = self.photos_scroll.frame.width / ratio
                    y = y + height
                    y.round(.up)
                    frame.size = CGSize(width: self.photos_scroll.frame.size.width, height: height)
                    
                    imageView.frame = frame
                    self.photos_scroll.addSubview(imageView)
                    self.photos_scroll.contentSize = CGSize(width: self.photos_scroll.frame.size.width, height: y)
                    if(i == self.imageURLs.count - 1){
                        SwiftSpinner.hide()
                    }
                }
                else {
                    print("Error: \(String(describing: response.error))")
                }
            }
        }
        if(imageURLs.count == 0) {
            let title = UILabel()
            title.text = "No Photos Found"
            title.textAlignment = .center
            title.font = UIFont.boldSystemFont(ofSize: 18.0)
            title.frame = CGRect(x: 0, y: photos_scroll.frame.height / 2, width: photos_scroll.frame.width, height: 30)
            title.backgroundColor = UIColor.white
            photos_scroll.addSubview(title)
            SwiftSpinner.hide()
        }
    }
}
