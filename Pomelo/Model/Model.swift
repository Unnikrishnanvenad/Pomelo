//
//  Model.swift
//  Pomelo
//
//  Created by Unnikrishnan Parameswaran on 22/06/20.
//  Copyright © 2020 Unnikrishnan Parameswaran. All rights reserved.
//

import Foundation

class Location: NSObject {
    var active : Bool?
    var address1: String?
    var city: String?
    var latitude:Double?
    var longitude:Double?
    var alias: String?
    var distance:Double?
    
    
    init?( address1: String, city: String,active: Bool,latitude:Double,longitude:Double,alias:String,distance:Double)
    {
        self.address1 = address1
        self.city = city
        self.active = active
        self.latitude = latitude
        self.longitude = longitude
        self.alias = alias
        self.distance = distance
    }
    convenience init?(dictionary : [String:Any]) {
        guard let address1 : String = dictionary["address1"] as? String, let city : String = dictionary["city"] as? String ,let active : Bool = dictionary["active"] as? Bool,let latitude : Double = dictionary["latitude"] as? Double,let longitude : Double = dictionary["longitude"] as? Double,let alias : String = dictionary["alias"] as? String,let distance : Double = dictionary["distance"] as? Double
            else { return nil }
        self.init( address1: address1, city: city,active: active,latitude: latitude,longitude: longitude,alias: alias,distance:distance)
    }
    
    
    var propertyList : [String:Any] {
        return ["address1": address1!, "city": city!,"active": active!,"latitude":latitude!,"longitude":longitude!,"alias": alias!,"distance":distance!]
    }
    
}
