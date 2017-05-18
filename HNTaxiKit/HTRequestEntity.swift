//
//  HTRequestEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation


public struct MQTTDriverLocation: Mappable {
    public private(set) var id: String?
    public private(set) var type: String?
    public private(set) var locations: [CLLocationCoordinate2D]?
    
    init?(id: String?, type: String?, location: [CLLocationCoordinate2D]?) {
        guard let i = id, let t = type else { return nil }
        self.id = i
        self.type = t
        self.locations = locations ?? [CLLocationCoordinate2D]()
    }
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        locations <- (map["locations"], Transform.zipCoordinate)
    }
}
