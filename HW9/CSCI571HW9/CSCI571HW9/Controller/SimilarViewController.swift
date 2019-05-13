//
//  SimilarViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/19.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner

class SimilarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var sort_control: UISegmentedControl!
    @IBOutlet weak var order_control: UISegmentedControl!
    @IBOutlet weak var collection_table: UICollectionView!
    var similarData: JSON = []
    var itemID: String = ""
    var ready: Bool = false
    var sort: Bool = false
    var ascend: Bool = true
    var type: Int = 0
    var items: [SimilarItem] = []
    var sorted: [SimilarItem] = []
    var sortedItems: [[SimilarItem]] = []
    var revesedItems: [[SimilarItem]] = []

    @IBOutlet weak var text_view: UIView!
    @IBOutlet weak var error_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Similar Items...")
        collection_table.delegate = self
        collection_table.dataSource = self
        fetchSimilarData()
        
        sort_control.addTarget(self, action: #selector(typeSelected), for: .valueChanged)
        order_control.addTarget(self, action: #selector(orderSelected), for: .valueChanged)
        order_control.isEnabled = false
        order_control.tintColor = UIColor.lightGray
        
        error_view.alpha = 0
        error_view.isHidden = true
        collection_table.isHidden = false
    }
    
    func fetchSimilarData() {
        let url = "http://hi9mi9tsu9.us-east-2.elasticbeanstalk.com/searchSimilar?id=" + itemID
        Alamofire.request(url).responseJSON{ response in
            switch response.result {
                case .success(_):
                    self.similarData = JSON(response.result.value!)
                    self.ready = true
                    if (self.similarData.count == 0) {
                        self.error_view.alpha = 1
                        self.error_view.isHidden = false
                        self.collection_table.isHidden = true
                        
                        let message = UILabel()
                        message.text = "No Similar Item Found"
                        message.font = UIFont.boldSystemFont(ofSize: 18.0)
                        message.frame = CGRect(x: 0, y: self.collection_table.frame.height / 2 - 60, width: self.error_view.frame.width, height: 30)
                        message.backgroundColor = UIColor.white
                        message.textAlignment = .center
                        self.error_view.addSubview(message)
                    }
                    else {
                        self.items = self.loadItems()
                        self.collection_table.reloadData()
                    }
                    SwiftSpinner.hide()
                case .failure(_):
                    print("Error: \(String(describing: response.error))")
                    SwiftSpinner.hide()
                }
        }
    }
    
    func loadItems() -> [SimilarItem] {
        var list: [SimilarItem] = []
        for (_, item) in similarData {
            let temp = SimilarItem(data: item)
            list.append(temp)
        }
        sortedItems.append(list.sorted(by: { $0.title < $1.title }))
        sortedItems.append(list.sorted(by: { $0.price < $1.price }))
        sortedItems.append(list.sorted(by: { $0.days < $1.days }))
        sortedItems.append(list.sorted(by: { $0.shipping < $1.shipping }))
        revesedItems.append(list.sorted(by: { $0.title > $1.title }))
        revesedItems.append(list.sorted(by: { $0.price > $1.price }))
        revesedItems.append(list.sorted(by: { $0.days > $1.days }))
        revesedItems.append(list.sorted(by: { $0.shipping > $1.shipping }))
        return list
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarCell", for: indexPath) as! SimilarCollectionViewCell
        let index = indexPath.item
        if (sort) { cell.setCollection(item: sorted[index]) }
        else if (ready) { cell.setCollection(item: items[index]) }

        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHight = collectionView.bounds.height
        return CGSize(width: (collectionViewWidth - 5) / 2, height: collectionViewHight / 1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let url = items[index].itemURL
        if let openURL = URL(string: url.urlEncode()) {
            UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func typeSelected(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        sort = true
        type = index
        order_control.isEnabled = true
        order_control.tintColor =  UIColor(red: 21 / 255, green: 126 / 255, blue: 251 / 255, alpha: 1.0)
        switch index {
            case 1 :
                //sorted = (ascend) ? items.sorted(by: { $0.title < $1.title }) : items.sorted(by: { $0.title > $1.title })
                sorted = (ascend) ? sortedItems[0] : revesedItems[0]
            case 2 :
                //sorted = (ascend) ? items.sorted(by: { $0.price < $1.price }) : items.sorted(by: { $0.price > $1.price })
                sorted = (ascend) ? sortedItems[1] : revesedItems[1]
            case 3 :
                //sorted = (ascend) ? items.sorted(by: { $0.days < $1.days }) : items.sorted(by: { $0.days > $1.days })
                sorted = (ascend) ? sortedItems[2] : revesedItems[2]
            case 4 :
                //sorted = (ascend) ? items.sorted(by: { $0.shipping < $1.shipping }) : items.sorted(by: { $0.shipping > $1.shipping })
                sorted = (ascend) ? sortedItems[3] : revesedItems[3]
            default:
                ascend = true
                sorted = items
                order_control.selectedSegmentIndex = 0
                order_control.isEnabled = false
                order_control.tintColor = UIColor.lightGray
        }
        collection_table.reloadData()
    }
    
    @objc func orderSelected(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        ascend = (index == 0) ? true : false
        switch type {
            case 1 :
                //sorted = (ascend) ? items.sorted(by: { $0.title < $1.title }) : items.sorted(by: { $0.title > $1.title })
                sorted = (ascend) ? sortedItems[0] : revesedItems[0]
            case 2 :
                //sorted = (ascend) ? items.sorted(by: { $0.price < $1.price }) : items.sorted(by: { $0.price > $1.price })
                sorted = (ascend) ? sortedItems[1] : revesedItems[1]
            case 3 :
                //sorted = (ascend) ? items.sorted(by: { $0.days < $1.days }) : items.sorted(by: { $0.days > $1.days })
                sorted = (ascend) ? sortedItems[2] : revesedItems[2]
            case 4 :
                //sorted = (ascend) ? items.sorted(by: { $0.shipping < $1.shipping }) : items.sorted(by: { $0.shipping > $1.shipping })
                sorted = (ascend) ? sortedItems[3] : revesedItems[3]
            default:
                sorted = items
        }
        collection_table.reloadData()
    }
}
