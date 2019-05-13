//
//  DetailViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/17.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var page_scroll: UIPageControl!
    @IBOutlet weak var image_scroll: UIScrollView!
    @IBOutlet weak var detail_scroll: UIScrollView!
    
    @IBOutlet weak var detail_title: UILabel!
    @IBOutlet weak var detail_price: UILabel!
    @IBOutlet weak var detail_table: UITableView!
    
    var images: [UIImage] = []
    var data: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        page_scroll.numberOfPages = data["picture"].count
        var counter = 0
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        for (_, item) in data["picture"] {
            frame.origin.x = image_scroll.frame.size.width * CGFloat(counter)
            frame.size = image_scroll.frame.size
            
            let imageView = UIImageView(frame: frame)
            imageView.loadImage(imageURL: item.stringValue)
            imageView.contentMode = .scaleAspectFit
            image_scroll.addSubview(imageView)
            counter += 1
        }
        image_scroll.contentSize = CGSize(width: (image_scroll.frame.size.width * CGFloat(data["picture"].count)), height: image_scroll.frame.size.height)
        image_scroll.delegate = self
        
        detail_title.text = data["title"].stringValue
        detail_price.text = "$" + data["price"].stringValue
        detail_table.delegate = self
        detail_table.dataSource = self
        detail_table.tableFooterView = UIView()
        
        if(data["specifics"].count == 0) {
            //description_label.text = "No Description Available"
            detail_scroll.showsVerticalScrollIndicator = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data["specifics"].count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! DetailTableViewCell
        let pair = data["specifics"][indexPath.row]
        cell.setPair(name: pair["Name"].stringValue, value: pair["Value"][0].stringValue)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        page_scroll.currentPage = Int(pageNumber)
    }
    
}
