//
//  HTRequestEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation


public struct MQTTTokenContainer: Mappable {
    public private(set) var token: String?
    public private(set) var json: Mappable?
    
    
    public init(token: String?, json: Mappable?) {
        self.token = token
        self.json = json
    }
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        token <- map["token"]
        json <- map["json"]
    }
    

}


public struct MQTTDriverLocation: Mappable {
    public private(set) var id: String?
    public private(set) var timestamp: Date?
    public private(set) var locations: CLLocationCoordinate2D?
    
    public init?(id: String?,location: CLLocationCoordinate2D?) {
        guard let i = id else { return nil }
        self.id = i
        self.timestamp = Date()
        self.locations = location
    }
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        timestamp <- (map["timestamp"], Transform.date)
        locations <- (map["position"], Transform.standardCoordinate)
    }
}




public struct HTReuqestOrder: Mappable {
    public private(set) var startLocation: CLLocationCoordinate2D?
    public private(set) var endLocation: CLLocationCoordinate2D?
    
    public init?(map: Map) {
    }
    
    init(startLocation: CLLocationCoordinate2D?,
         endLocation:  CLLocationCoordinate2D? ) {
        self.startLocation = startLocation
        self.endLocation = endLocation
    }

    public mutating func mapping(map: Map) {
    }

}

