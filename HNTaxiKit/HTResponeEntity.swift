//
//  HTResponeEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation


// MARK: enum



public enum HTRiderStatus: String {
    case origin = "origin"
    case confirmDestination = "confirmdestination"
    case callTaxi = "calltaxi"
    case onTaxi = "ontaxi"
    case finishPay = "finishpay"
}


public enum HTDriverStatus: String {
    case know = ""
    case rest = "rest"
    case work = "work"
    case ordering = "ording"
}

public enum HTOrderStatus {
    // 未开始
    case none
    // 已收到请求
    case received
    // 正在搜索司机
    case searching
    // 接单失败(msg: 失败信息)
    case requestFail(err: Error?)
    // 接单成功(msg: 司机信息)
    case requestSuccess(driverId: String?)
    // 等待车辆到达(location: 司机位置)
    case waitDriver(latlng: CLLocationCoordinate2D?)
    // 已上车
    case boarded
    // 车辆行驶信息(location: 司机位置)
    case driving(latlng: CLLocationCoordinate2D?)
    // 已下车
    case getOff
    // 支付状态(bool: 成功/失败, msg: 信息)
    case pay(status: Bool, err: Error?)
    // 已取消
    case cancle
}






public enum HTCarType: String {
    case common = "common"
}



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




public struct HTRegion: Mappable, Equatable {
    public private(set) var regionId: String?
    public private(set) var distance: Double?
    public private(set) var subRegions: [String]?
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        regionId <- map["regionId"]
        distance <- map["distance"]
        subRegions <- map["subRegions"]
    }
    
    public static func ==(lhs: HTRegion, rhs: HTRegion) -> Bool {
        let a = (lhs.regionId ?? "") == (rhs.regionId ?? "")
        guard a else { return false }
        let l = lhs.subRegions ?? []
        let r = rhs.subRegions ?? []
        let b = l.count == r.count
        guard b else { return false }
        for e in l {
            guard r.contains(e) else { return false }
        }
        return true
    }
}


public struct HTComment: Mappable {
    public init?(map: Map) {
    }
    public mutating func mapping(map: Map) {
    }
}




public struct HTOrder: Mappable {
    public private(set) var id: String?
    public init?(map: Map) {
    }
    public mutating func mapping(map: Map) {
        id <- map["id"]
    }
}


public struct HTAddress: Mappable {
    public init() {
    }
    public init?(map: Map) {
    }
    public mutating func mapping(map: Map) {
    }
}


