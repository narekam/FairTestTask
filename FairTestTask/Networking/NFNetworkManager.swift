//
//  NFNetworkManager.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 10/29/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import UIKit
import CoreLocation
import Moya
import SwiftyJSON

protocol Networkable {
    associatedtype T: TargetType
    var provider: MoyaProvider<T> { get }
}

struct NetworkManager: Networkable {
    let provider = MoyaProvider<AmadeusAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func getCars(pickupDate: Date, dropoffDate: Date, location: CLLocationCoordinate2D, completion: @escaping ([AMRentalBranch])->()) {
        provider.request(AmadeusAPI.getCars(pickupDate: pickupDate, dropoffDate: dropoffDate, location: location)) { result in
            switch result {
            case let .success(response):
                let data = response.data
                var branches: [AMRentalBranch] = []
                
                if let json = try? JSON(data: data) {
                    for branchJSON in json["results"].arrayValue {
                        let aBranch = AMRentalBranch.init(jsonObject: branchJSON)
                        branches.append(aBranch)
                    }
                    
                    print(json)
                    completion(branches)
                }
                
            case let .failure(error):
                print("error: \(error)")
            }
        }
    }
}



