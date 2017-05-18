//
//  DriverLocation.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import HNTaxiKit

class DriverLocation {
    public private(set) var data: MQTTDriverLocation
    public private(set) var lastUpdateTime: Date
    public var isExpire: Bool {
        return lastUpdateTime.timeIntervalSinceNow < 60
    }
    init(_ location: MQTTDriverLocation) {
        data = location
        lastUpdateTime = Date()
    }
    
    func update(location: MQTTDriverLocation) {
        data = location
        lastUpdateTime = Date()
    }
}


struct OrderSelectLocation {
    var from: Coordinate2D?
    var to: Coordinate2D?
    var isVaild: Bool {
        return from != nil && to != nil
    }
    init(from: Coordinate2D? = nil , to: Coordinate2D? = nil) {
        self.from = from
        self.to = to
    }
}
