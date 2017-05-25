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
    public var isVaild: Bool {
        guard let ts = data.timestamp?.timeIntervalSinceNow else { return false }
//        print("TimeIntervalSinceNow \(lastUpdateTime.timeIntervalSinceNow )")
        return ts > -5
    }
    init(_ location: MQTTDriverLocation) {
        data = location
    }
    
    func update(location: MQTTDriverLocation) {
        data = location
    }
}


struct OrderSelectLocation {
    var from: HTLocation?
    var to: HTLocation?
    var isVaild: Bool {
        return from != nil && to != nil
    }
    init(from: HTLocation? = nil , to: HTLocation? = nil) {
        self.from = from
        self.to = to
    }
}
