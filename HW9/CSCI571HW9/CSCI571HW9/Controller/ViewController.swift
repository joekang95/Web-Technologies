//
//  ViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/8.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import McPicker
import Toast_Swift
import SwiftSpinner
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var category: McTextField!
    
    @IBOutlet weak var condition_new: UIButton!
    @IBOutlet weak var condition_used: UIButton!
    @IBOutlet weak var condition_unspecified: UIButton!
    var condition_pressed: [Bool] = [false, false, false]
    
    @IBOutlet weak var shipping_pickup: UIButton!
    @IBOutlet weak var shipping_free: UIButton!
    var shipping_pressed: [Bool] = [false, false]
    
    @IBOutlet weak var distance: UITextField!

    @IBOutlet weak var enable_location: UISwitch!
    @IBOutlet weak var zipcode: UITextField!
    
    @IBOutlet weak var autoscroll: UIScrollView!
    @IBOutlet weak var autocomplete: UITableView!
    var zips: [String] = []
    
    @IBOutlet weak var search_button: UIButton!
    var formValid = false
    var resultData: JSON = []
    @IBOutlet weak var clear_button: UIButton!
    
    @IBOutlet weak var view_control: UISegmentedControl!
    @IBOutlet weak var wish_table: UITableView!
    @IBOutlet weak var search_table: UIStackView!
    
    let wishList = UserDefaults.standard
    var wishItems: [String: Any] = [:]
    var wishIDs: [String] = []
    
    var indexedItems: [Item] = []
    var selectedItem: Item?
    var itemID: String = ""
    var detailData: JSON = []
    var shippingCost: String = ""
    var name: String = ""
    var tabController: UITabBarController!
    
    let categoryID = [
        "All" : "all",
        "Art" : "550",
        "Baby" : "2984",
        "Books" : "267",
        "Clothing, Shoes & Accessories" : "11450",
        "Computers/Tablets & Networking" : "58058",
        "Health & Beauty" : "26395",
        "Music" : "11233",
        "Video Games & Consoles" : "1249"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Product Search"
        zipcode.isHidden = true
        
        let categories: [[String]] = [
            ["All", "Art", "Baby", "Books", "Clothing, Shoes & Accessories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles"]
        ]
        
        let mcInputView = McPicker(data: categories)
        category.inputViewMcPicker = mcInputView
        category.doneHandler = { [weak category] (selections) in
            category?.text = selections[0]!
        }
        category.selectionChangedHandler = { [weak category] (selections, componentThatChanged) in
            category?.text = selections[componentThatChanged]!
        }
        category.textFieldWillBeginEditingHandler = { [weak category] (selections) in
            if (category?.text == "") {
                category?.text = selections[0]
            }
        }
        autocomplete.delegate = self
        autocomplete.dataSource = self
        autocomplete.tableFooterView = UIView()
        
        autoscroll.isHidden = true
        autoscroll.layer.cornerRadius = 5.0
        autoscroll.layer.borderColor = UIColor.black.cgColor
        autoscroll.layer.borderWidth = 2.0
        
        zipcode.addTarget(self, action: #selector(autoSearch), for: .allEditingEvents)
        
        wishItems = wishList.object(forKey: "wish") as? [String : Any] ?? [:]
        view_control.addTarget(self, action: #selector(viewSelected), for: .valueChanged)
        
        for (id, _) in wishItems {
            wishIDs.append(id)
        }
        
        sortItems()
        wish_table.delegate = self
        wish_table.dataSource = self
        wish_table.tableFooterView = UIView()
        wish_table.alpha = 0
        wish_table.isHidden = true
    }
    
    func sortItems() {
        indexedItems.removeAll()
        for (_, value) in wishItems {
            let item = value as! [String : Any]
            indexedItems.append(Item(data: item))
        }
        indexedItems.sort(by: { $0.title < $1.title})
    }
    
    @objc func viewSelected(segment: UISegmentedControl) {
        if(segment.selectedSegmentIndex == 0) {
            search_table.isHidden = false
            wish_table.alpha = 0
            wish_table.isHidden = true
        }
        else {
            search_table.isHidden = true
            wish_table.alpha = 1
            wish_table.isHidden = false
            wishItems = wishList.object(forKey: "wish") as? [String : Any] ?? [:]
            sortItems()
            wish_table.reloadData()
        }
    }
    
    @objc func autoSearch() {
        autoscroll.isHidden = (zipcode.text?.count == 0) ? true : false
        if(!autoscroll.isHidden) {
            zips.removeAll()
            let auto = zipcode.text!
            let url = "http://hi9mi9tsu9.us-east-2.elasticbeanstalk.com/location?zip=\(auto)"
            Alamofire.request(url, method: .post).responseJSON{ response in
                switch response.result {
                case .success(_):
                    let data = JSON(response.result.value!)
                    for (_, item) in data {
                        self.zips.append(item.stringValue)
                    }
                    self.autocomplete.reloadData()
                case .failure(_):
                    print("Error: \(String(describing: response.error))")
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        autoscroll.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == autocomplete) ? zips.count : wishItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == autocomplete) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCell") as! AutoTableViewCell
            cell.setZips(zip: zips[indexPath.row])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WishCell") as! WishTableViewCell
            cell.setItems(item: indexedItems[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == autocomplete) {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.selectionStyle = .none
            zipcode.text = zips[indexPath.row]
            zips.removeAll()
            autoscroll.isHidden = true
        }
        else {
            SwiftSpinner.show("Fetching Product Details...")
            self.selectedItem = indexedItems[indexPath.row]
            self.itemID = indexedItems[indexPath.row].itemID
            
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
                        self.performSegue(withIdentifier: "WishDetail", sender: self)
                    }
                    SwiftSpinner.hide()
                case .failure(_):
                    print("Error: \(String(describing: response.error))")
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if(tableView == wish_table) {
            let left = UILabel()
            let right = UILabel()
            if(indexedItems.count == 0){
                left.text = "No Items in WishList"
                left.textAlignment = .center
            }
            else{
                left.text = "WishList Total(\(indexedItems.count) items):"
                var total = 0.0
                for item in indexedItems {
                    total += item.price
                }
                right.text = "$\(round(100 * total) / 100)"
                right.font = UIFont.boldSystemFont(ofSize: 18.0)
                right.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 10, height: 30)
                right.textAlignment = .right
            }
            left.font = UIFont.boldSystemFont(ofSize: 18.0)
            left.frame = CGRect(x: 10, y: 0, width: tableView.frame.width, height: 30)
            left.backgroundColor = UIColor.white
            
            let background = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
            background.backgroundColor = UIColor.white
            view.addSubview(background)
            view.addSubview(left)
            view.addSubview(right)
            return view
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (tableView == wish_table) ? 30 : CGFloat.leastNonzeroMagnitude // or 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if(tableView == autocomplete) {
            return []
        }
        else {
            let deleteWish = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                let item = self.indexedItems[editActionsForRowAt.row]
                self.modifyWish(item: item)
                self.sortItems()
                self.wish_table.reloadData()
            }
            deleteWish.backgroundColor = UIColor(red: 234 / 255, green: 78 / 255, blue: 67 / 255, alpha: 1.0)
            
            return [deleteWish]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (tableView == autocomplete) ? false : true
    }
    
    @IBAction func locationSwitch(_ sender: UISwitch) {
        zipcode.isHidden = (sender.isOn) ? false : true
        autoscroll.isHidden = (sender.isOn) ? true : true
        if (!sender.isOn) { zipcode.text = "" }
    }
    
    @IBAction func checkbox(_ sender: UIButton) {
        var ispressed = false
        if (sender == condition_new) {
            condition_pressed[0] = !condition_pressed[0]
            ispressed = condition_pressed[0]
        }
        else if (sender == condition_used) {
            condition_pressed[1] = !condition_pressed[1]
            ispressed = condition_pressed[1]
        }
        else if (sender == condition_unspecified) {
            condition_pressed[2] = !condition_pressed[2]
            ispressed = condition_pressed[2]
        }
        
        if (sender == shipping_pickup) {
            shipping_pressed[0] = !shipping_pressed[0]
            ispressed = shipping_pressed[0]
        }
        else if (sender == shipping_free) {
            shipping_pressed[1] = !shipping_pressed[1]
            ispressed = shipping_pressed[1]
        }
        
        if (ispressed) {
            sender.setBackgroundImage(UIImage(named: "checked"), for: .normal)
        }
        else {
            sender.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        if (keyword.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            var style = ToastStyle()
            style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            let myView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 400.0))
            self.view.makeToast("Keyword is Mandatory", duration: 3.0, position: .bottom, style: style)
            self.view.showToast(myView)
            formValid = false
        }
        else if (enable_location.isOn && (zipcode.text?.trimmingCharacters(in: .whitespaces).isEmpty)!) {
            var style = ToastStyle()
            style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            let myView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 400.0))
            self.view.makeToast("Zipcode is Mandatory", duration: 3.0, position: .bottom, style: style)
            self.view.showToast(myView)
            formValid = false
        }
        else {
            formValid = true
        }
        
        if (formValid) {
            var distance_input = "10"
            if(distance.text != ""){
                distance_input = distance.text!
            }
            let url = "http://hi9mi9tsu9.us-east-2.elasticbeanstalk.com/searchProducts?"
            let key = "keyword=\(keyword.text!)"
            let selection = categoryID[category.text!]
            let cat = "&category=\(selection!)"
            let con = "&condition={\"New\":\(String(condition_pressed[0])),\"Used\":\(String(condition_pressed[1])),\"Unspecified\":\(String(condition_pressed[2]))"
            let shi = "}&shipping={\"LocalPickupOnly\":\(String(shipping_pressed[0])),\"FreeShippingOnly\":\(String(shipping_pressed[1]))"
            let dis = "}&distance=\(distance_input)"
            
            let geo = "http://ip-api.com/json"
            if(!enable_location.isOn) {
                Alamofire.request(geo).responseJSON{ response in
                    switch response.result{
                    case .success(_):
                        let location = JSON(response.result.value!)["zip"].intValue
                        let zip = "&zip=\(location)"
                        let final = (url+key+cat+con+shi+dis+zip).urlEncode()
                        self.productSearch(url: final)
                    case .failure(_):
                        print("Error: \(String(describing: response.error))")
                    }
                }
            }
            else {
                let location = zipcode.text!
                let zip = "&zip=\(location)"
                let final = (url+key+cat+con+shi+dis+zip).urlEncode()
                productSearch(url: final)
            }
        }
    }
    
    func productSearch(url: String) {
        //print(url)
        SwiftSpinner.show("Searching...")
        Alamofire.request(url).responseJSON{ response in
            switch response.result{
                case .success(_):
                    let data = JSON(response.result.value!)
                    self.resultData = data
                    self.performSegue(withIdentifier: "SearchResult", sender: self)
                    SwiftSpinner.hide()
                case .failure(_):
                    print("Error: \(String(describing: response.error))")
                    SwiftSpinner.hide()
            }
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        keyword.text = ""
        category.text = "All"
        condition_new.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        condition_used.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        condition_unspecified.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        condition_pressed = [false, false, false]
        shipping_free.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        shipping_pickup.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
        shipping_pressed = [false, false]
        distance.text = ""
        zipcode.text = ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if (segue.identifier == "SearchResult") {
            let resultData = segue.destination as! ResultTableViewController
            resultData.data = self.resultData
        }
        else {
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
        sortItems()
        let fb_img = UIImage(named: "facebook")
        let fb_button = UIBarButtonItem(image: fb_img, style: .plain, target: self, action: #selector(FacebookShare))
        
        var wish_img = UIImage(named: "wishListEmpty")
        if(wishItems[item.itemID] != nil) {
            wish_img = UIImage(named: "wishListFilled")
        }
        let wish_button = UIBarButtonItem(image: wish_img, style: .plain, target: self, action: #selector(checkWish))
        tabController.navigationItem.rightBarButtonItems = [wish_button, fb_button]
        self.wish_table.reloadData()
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
