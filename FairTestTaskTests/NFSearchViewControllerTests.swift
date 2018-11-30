//
//  NFSearchViewControllerTests.swift
//  FairTestTaskTests
//
//  Created by Narek Fidanyan on 11/25/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import XCTest
import CoreLocation
@testable import FairTestTask

class NFSearchViewControllerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchParamsValidation() {
        let searchVC = NFSearchViewController.init()
        
        var location1: CLLocation?
        location1 = nil
        let pickup1 = "11/7/18"
        let dropoff1 = "11/19/18"
        XCTAssertFalse(searchVC.validateSearchParams(location: location1, pickupDate: pickup1, dropoffDate: dropoff1))
        
        let location2 = CLLocation.init(latitude: 12, longitude: 142)
        let pickup2 = "11/7/18"
        let dropoff2 = "12/21/18"
        XCTAssertTrue(searchVC.validateSearchParams(location: location2, pickupDate: pickup2, dropoffDate: dropoff2))
    }

}
