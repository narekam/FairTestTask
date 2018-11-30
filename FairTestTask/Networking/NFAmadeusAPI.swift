//
//  NFAmadeusAPI.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 11/9/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import Foundation
import CoreLocation
import Moya

enum AmadeusAPI {
    case getCars(pickupDate: Date, dropoffDate: Date, location: CLLocationCoordinate2D)
}

extension AmadeusAPI: TargetType {
    static let apiKey = "mCcvx9xkuENtZuuoHgoabtkGNIGCMKVF"
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var baseURL: URL {
        guard let url = URL.init(string: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle") else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getCars(_, _, _):
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getCars(let pickupDate, let dropoffDate, let location):
            return .requestParameters(parameters: ["apikey": AmadeusAPI.apiKey, "latitude": location.latitude, "longitude": location.longitude, "radius": 15, "pick_up": AmadeusAPI.dateFormatter.string(from: pickupDate), "drop_off": AmadeusAPI.dateFormatter.string(from: dropoffDate)], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}
