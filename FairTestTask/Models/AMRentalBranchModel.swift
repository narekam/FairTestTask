//
//  AMRentalBranchModel.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 11/1/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import SwiftyJSON
import CoreLocation

struct AMRentalBranch {
    var providerName: String
    var providerLocation: CLLocationCoordinate2D
    var cars: [AMCar] = []
    
    init(jsonObject: JSON) {
        providerName = jsonObject["provider"]["company_name"].stringValue
        providerLocation = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(jsonObject["location"]["latitude"].floatValue), longitude: CLLocationDegrees(jsonObject["location"]["longitude"].floatValue))
        for car in jsonObject["cars"].arrayValue {
            let aCar = AMCar.init(jsonObject: car)
            cars.append(aCar)
        }
    }
}

struct AMCar {
    let acrissCode: String
    let transmission: String
    let fuel: String
    let airConditioning: Bool
    let category: String
    let type: String
    let price: Int
    
    // Additional
    public var carProviderName: String
    public var carProviderLocation: CLLocationCoordinate2D
    public var carDistanceFromCurrentLocation: Double
    
    init(jsonObject: JSON) {
        acrissCode = jsonObject["vehicle_info"]["acriss_code"].stringValue
        transmission = jsonObject["vehicle_info"]["transmission"].stringValue
        fuel = jsonObject["vehicle_info"]["fuel"].stringValue
        airConditioning = jsonObject["vehicle_info"]["air_conditioning"].boolValue
        category = jsonObject["vehicle_info"]["category"].stringValue
        type = jsonObject["vehicle_info"]["type"].stringValue
        price = jsonObject["estimated_total"]["amount"].intValue
        
        carProviderName = ""
        carProviderLocation = CLLocationCoordinate2D.init()
        carDistanceFromCurrentLocation = 0
    }
}
