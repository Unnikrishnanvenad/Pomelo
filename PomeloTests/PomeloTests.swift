//
//  PomeloTests.swift
//  PomeloTests
//
//  Created by Unnikrishnan Parameswaran on 22/06/20.
//  Copyright © 2020 Unnikrishnan Parameswaran. All rights reserved.
//

import XCTest
@testable import Pomelo

class PomeloTests: XCTestCase {
    
    func testCourseViewModel() {
        let location = Location(address1: "Test", city: "Test", active: false, latitude: 1.0, longitude: 1.2, alias: "City", distance: 0.0)
        let location2 = Location(address1: "Test", city: "Test", active: false, latitude: 1.0, longitude: 1.2, alias: "City", distance: 0.0)
        XCTAssertEqual(location?.address1, location2?.address1)
        XCTAssertEqual(location?.city,location2?.city)
    }
    
    func testCourseViewModelLessonsOverThreshold() {
        let location = Location(address1: "Test", city: "Test", active: false, latitude: 1.0, longitude: 1.2, alias: "City", distance: 0.0)
        let location2 = Location(address1: "Test", city: "Test", active: false, latitude: 1.0, longitude: 1, alias: "City", distance: 0.0)
        XCTAssertEqual(location?.alias, location2?.alias)
        XCTAssertEqual(location?.city,location2?.city)
    }
}
