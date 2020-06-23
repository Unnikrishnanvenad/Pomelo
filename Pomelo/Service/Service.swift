//
//  Service.swift
//  Pomelo
//
//  Created by Unnikrishnan Parameswaran on 23/06/20.
//  Copyright © 2020 Unnikrishnan Parameswaran. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import SwiftyJSON

class Service: NSObject {
    static let sharedService = Service()
    
    func fetchLocations(completion: @escaping ([[String:Any]], _ Succeeded: Bool) -> ()) {
        let urlString = "https://api-staging.pmlo.co/v3/pickup-locations/"
        AF.request(urlString, method:.get, parameters: nil,encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON {
            response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    completion(self.parseJSON(reports: JSON(response.data ?? Data())), true)
                    break
                case .failure(let error):
                    print(error)
                    completion([], false)
                }
            }
        }
    }
    func parseJSON(reports:JSON)-> [[String:Any]]{
        var jsonDict = [[String:Any]]()
        var tempArray = [String:Any]()
        var active = Bool()
        var address1 = ""
        var city = ""
        var alias = ""
        var longitude = Double()
        var latitude = Double()
        for (key,subJson):(String, JSON) in reports {
            if key == "pickup"{
                for element in subJson{
                    let data : JSON = element.1
                    tempArray = [:]
                    active = data["active"].boolValue
                    address1 = data["address1"].stringValue
                    city =   data["city"].stringValue
                    alias =   data["alias"].stringValue
                    latitude =   data["latitude"].doubleValue
                    longitude =   data["longitude"].doubleValue
                    tempArray["active"] = active
                    tempArray["address1"] = address1
                    tempArray["city"] = city
                    tempArray["alias"] = alias
                    tempArray["latitude"] = latitude
                    tempArray["longitude"] = longitude
                    if active == true{
                    jsonDict.append(tempArray)
                    }
                }
            }
        }
        return jsonDict
    }
}
