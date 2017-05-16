//
//  HTResponeEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation


// MARK: Respone
public struct HTAuthRespone: Mappable {
    public private(set) var expires: Date?
    public private(set) var accessToken: String?
    public init?(map: Map) {
    }
    public mutating func mapping(map: Map) {
        expires <- (map["expires"], Transform.date)
        accessToken <- map["accessToken"]
    }
}



public struct HTLocation: Mappable {
    public private(set) var coordinate: CLLocationCoordinate2D?
    public private(set) var name: String?
    public private(set) var cityCode: String?
    public private(set) var address: String?
    
    public init?(map: Map) {
    }
    
    public init(coordinate: CLLocationCoordinate2D?, name: String?, cityCode: String?, address: String?) {
        self.coordinate = coordinate
        self.name = name
        self.cityCode = cityCode
        self.address = address
    }
    public mutating func mapping(map: Map) {
        coordinate <- (map["coordinate"], Transform.coordinate)
        name <- map["name"]
        cityCode <- map["cityCode"]
        address <- map["address"]
    }
}


public struct HTPath: Mappable {
    public private(set) var distance: Int?
    public private(set) var duration: Int?
    public private(set) var tolls: Double?
    public private(set) var lineCoordinates: [CLLocationCoordinate2D]?
    public init?(map: Map) {
        lineCoordinates = [CLLocationCoordinate2D]()
    }
    public init(distance: Int?, duration: Int?, tolls: Double?, lineCoordinates:[CLLocationCoordinate2D]?) {
        self.distance = distance
        self.duration = duration
        self.tolls = tolls
        self.lineCoordinates = lineCoordinates 
    }
    public mutating func mapping(map: Map) {
        distance <- map["distance"]
        duration <- map["duration"]
        tolls <- map["tolls"]
        lineCoordinates <- map["lineCoordinates"]
    }
}


public enum HTDriverState: String {
    case offLine = "offLine"
    case wait = "wait"
    case inOrder = "inOrder"
}


public enum HTPathConsumerState: String {
    case origin = "origin"
    case confirmDestination = "confirmdestination"
    case callTaxi = "calltaxi"
    case onTaxi = "ontaxi"
    case finishPay = "finishpay"
}

