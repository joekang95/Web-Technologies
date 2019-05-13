//
//  ResultTableViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/16.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import Toast_Swift

class ResultTableViewController: UITableViewController {

    var detailData: JSON = []
    var shippingCost: String = ""
    var data: JSON = []
    var items: [Item] = []
    var selectedItem: Item?
    var itemID: String = ""
    var name: String = ""
    var errorMessage: Bool = false
    
    var tabController: UITabBarController!
    let wishList = UserDefaults.standard
    var wishItems: [String: Any] = [:]
    
    @IBOutlet weak var result_table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (data[0]["message"].exists()) { errorMessage = true }
        else { items = loadItems(); }
        if (items.count == 0 || errorMessage) {
            result_table.rowHeight = 50
            let alert = UIAlertController(title: "No Results!", message: "Failed to fetch search results", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertOKAction) in self.navigationController?.popViewController(animated: true)}))
            present(alert, animated: true)
        }
        // Dragged table delegate and datasource at Storyboard
        // Else need:
        // result_table.delegate = self
        // result_table.dataSource = self
        
        // Clear UserDefaults
        // wishList.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        // wishList.synchronize()
        wishItems = wishList.object(forKey: "wish") as? [String : Any] ?? [:]
    }
    
    func loadItems() -> [Item] {
        var list: [Item] = []
        let jsonObject = data
        for (_, item) in jsonObject{
            let temp = Item(data: item)
            list.append(temp)
        }
        return list
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultTableViewCell
        let item = items[indexPath.row]
        cell.delegate = self // Important! for using protocol ResultCellDelegate
        
        if (!errorMessage) { cell.setItems(item: item) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Fetching Product Details...")
        self.selectedItem = items[indexPath.row]
        self.itemID = items[indexPath.row].itemID
        
        let url = "http://hi9mi9tsu9.us-east-2.elasticbeanstalk.com/searchDetail?id=\(self.itemID)"
        Alamofire.request(url).responseJSON{ response in
            switch response.result {
                case .success(_):
                    self.detailData = JSON(response.result.value!)
                    if (self.detailData["message"].exists()) {
                        let alert = UIAlertController(title: "No Detail!", message: "Failed to fetch product detail", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else {
                        self.shippingCost = self.selectedItem!.shippingCost
                        self.name = self.selectedItem!.title
                        self.performSegue(withIdentifier: "Detail", sender: self)
                    }
                    SwiftSpinner.hide()
                case .failure(_):
                    print("Error: \(String(describing: response.error))")
                    SwiftSpinner.hide()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        tabController = segue.destination as? UITabBarController
        
        let fb_img = UIImage(named: "facebook")
        let fb_button = UIBarButtonItem(image: fb_img, style: .plain, target: self, action: #selector(FacebookShare))
        
        var wish_img = UIImage(named: "wishListEmpty")
        let item = selectedItem!
        if(wishItems[item.itemID] != nil) {
            wish_img = UIImage(named: "wishListFilled")
        }
        let wish_button = UIBarButtonItem(image: wish_img, style: .plain, target: self, action: #selector(checkWish))
        tabController.navigationItem.rightBarButtonItems = [wish_button, fb_button]
        
        let detail = tabController.viewControllers![0] as! DetailViewController
        detail.data = self.detailData
        
        let shipping = tabController.viewControllers![1] as! ShippingViewController
        shipping.data = self.detailData
        shipping.shippingCost = self.shippingCost
        
        let photos = tabController.viewControllers![2] as! PhotosViewController
        photos.name = self.name
        
        let similar = tabController.viewControllers![3] as! SimilarViewController
        similar.itemID = self.itemID
    }
    
    @objc func FacebookShare() {
        let item = selectedItem!
        let url = "https://www.facebook.com/dialog/share?app_id=XXXXXX&display=popup&href=\(item.itemURL) &hashtag=XXXXXX&quote=Buy \(item.title) at $\(round(100 * item.price) / 100) from link below"
        if let openURL = URL(string: url.urlEncode()) {
            UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func checkWish() {
        let item = selectedItem!
        modifyWish(item: item)
        let fb_img = UIImage(named: "facebook")
        let fb_button = UIBarButtonItem(image: fb_img, style: .plain, target: self, action: #selector(FacebookShare))
        
        var wish_img = UIImage(named: "wishListEmpty")
        if(wishItems[item.itemID] != nil) {
            wish_img = UIImage(named: "wishListFilled")
        }
        let wish_button = UIBarButtonItem(image: wish_img, style: .plain, target: self, action: #selector(checkWish))
        tabController.navigationItem.rightBarButtonItems = [wish_button, fb_button]
        self.result_table.reloadData()
    }
}

extension ResultTableViewController: ResultCellDelegate {
    func updateWish(cell: UITableViewCell) {
        let index = self.result_table.indexPath(for: cell)!.row
        modifyWish(item: items[index])
        result_table.reloadData()
    }
    
    func modifyWish(item: Item) {
        var text = ""
        if(wishItems[item.itemID] == nil) {
            wishItems[item.itemID] = item.encode()
            wishList.set(wishItems, forKey: "wish")
            text = "\(item.title) was added to the wishList"
        }
        else {
            wishItems.removeValue(forKey: item.itemID)
            wishList.set(wishItems, forKey: "wish")
            text = "\(item.title) was removed from the wishList"
        }
        
        let myView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 400.0))
        var style = ToastStyle()
        style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.navigationController?.view.makeToast(text, duration: 1.5, position: .bottom, style: style)
        self.navigationController?.view.showToast(myView)
    }
}
