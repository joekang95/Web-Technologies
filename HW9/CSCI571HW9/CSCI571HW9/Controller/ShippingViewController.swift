//
//  ShippingViewController.swift
//  CSCI571HW9
//
//  Created by Joe Chang on 2019/4/17.
//  Copyright © 2019 Joe Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner

class ShippingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var shipping_table: UITableView!
    var data: JSON = []
    var sellerInfo: [[String : Any]] = []
    var shippingInfo: [[String : Any]] = []
    var returnInfo: [[String : Any]] = []
    var final: [[[String: Any]]] = []
    var header: [String] = []
    var icon: [UIImage] = []
    var shippingCost: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show(duration: 1.0, title: "Fetching Shipping Data")
        shipping_table.delegate = self
        shipping_table.dataSource = self
        shipping_table.tableFooterView = UIView()
        shipping_table.separatorStyle = .none
        loadSellerInfo()
        loadShippingInfo()
        loadReturnInfo()
    }
    
    func loadSellerInfo(){
        //storeName, storeURL, feedbackScore, feedbackPercent, feedbackStar
        if (data["storeURL"].exists()) {
            sellerInfo.append(["Store Name" : [data["storeName"].stringValue, data["storeURL"].stringValue]])
        }
        else if (data["storeName"].exists()) {
            sellerInfo.append(["Store Name" : [data["storeName"].stringValue]])
        }
        if (data["feedbackScore"].exists()) {
            sellerInfo.append(["Feedback Score" : data["feedbackScore"].stringValue])
        }
        if (data["feedbackPercent"].exists()) {
            sellerInfo.append(["Popularity" : data["feedbackPercent"].stringValue])
        }
        if (data["feedbackStar"].exists() && data["feedbackStar"].stringValue != "None") {
            sellerInfo.append(["Feedback Star" : data["feedbackStar"].stringValue])
        }
        if (sellerInfo.count != 0) {
            final.append(sellerInfo)
            header.append("Seller")
            icon.append(UIImage(named: "Seller")!)
        }
    }
    
    func loadShippingInfo(){
        //shippingCost, globalShipping, handlingTime
        shippingInfo.append(["Shipping Cost" : shippingCost])
        
        if (data["globalShipping"].exists()) {
            let global = (data["globalShipping"].stringValue == "true") ? "Yes" : "No"
            shippingInfo.append(["Global Shipping" : global])
        }
        if (data["handlingTime"].exists()) {
            let day = (data["handlingTime"].stringValue == "0" || data["handlingTime"].stringValue == "1") ? "day" : "days"
            shippingInfo.append(["Handling Time" : "\(data["handlingTime"].stringValue) \(day)" ])
        }
        if (shippingInfo.count != 0) {
            final.append(shippingInfo)
            header.append("Shipping Info")
            icon.append(UIImage(named: "Shipping Info")!)
        }
    }
    
    func loadReturnInfo(){
        //returnAccepted, refund, returnsWithin, shippingCostPaidBy
        if (data["returnAccepted"].exists()) {
            returnInfo.append(["Policy" : data["returnAccepted"].stringValue])
        }
        if (data["refund"].exists()) {
            returnInfo.append(["Refund Mode" : data["refund"].stringValue])
        }
        if (data["returnsWithin"].exists()) {
            returnInfo.append(["Return Within" : data["returnsWithin"].stringValue])
        }
        if (data["shippingCostPaidBy"].exists()) {
            returnInfo.append(["Shipping Cost Paid By" : data["shippingCostPaidBy"].stringValue])
        }
        if (returnInfo.count != 0) {
            final.append(returnInfo)
            header.append("Return Policy")
            icon.append(UIImage(named: "Return Policy")!)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return final[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell") as! ShippingTableViewCell
        cell.setPair(pair: final[indexPath.section][indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return final.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let borderTop = UIView(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width - 20, height: 1.0))
        borderTop.backgroundColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1.0)
        view.addSubview(borderTop)
        
        let image = UIImageView(image: icon[section])
        image.frame = CGRect(x: 10, y: 5, width: 30, height: 30)
        view.addSubview(image)
        
        let title = UILabel()
        title.text = header[section]
        title.font = UIFont.boldSystemFont(ofSize: 20.0)
        title.frame = CGRect(x: 60, y: 5, width: 200, height: 30)
        view.addSubview(title)
        
        let borderBottom = UIView(frame: CGRect(x: 10, y: 40, width: tableView.bounds.size.width - 20, height: 1.0))
        borderBottom.backgroundColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1.0)
        view.addSubview(borderBottom)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
