//
//  HNTResponeEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation

public func  HNTBuildError(code: Int, reson: String) -> Error {
    return NSError(domain: "com.play.wenovel", code: code, userInfo: [NSLocalizedDescriptionKey: reson])
}


public let IDNOTFOUND = "IDNOTFOUND"
extension String {
    public var isValidId: Bool {
        return self != "" && self != IDNOTFOUND
    }
}


class HNTDateTransform: TransformType {
    
    typealias Object = Date
    typealias JSON = Double
    
    init() {}
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt/1000))
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        if let date = value {
            return Double(date.timeIntervalSince1970) * 1000
        }
        return nil
    }
}


class LocationCoordinate2DTransform: TransformType {
    typealias Object = CLLocationCoordinate2D
    typealias JSON = [String: Double]
    
    init() {}
    
    func transformFromJSON(_ value: Any?) -> Object? {
        let map = JsonMapper(value)
        let lat = map["lat"].doubleValue
        let log = map["log"].doubleValue
        guard let y = lat, let x = log else { return nil }
        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        guard let v = value else { return nil }
        return ["lat": v.latitude, "log": v.longitude]
    }
}

public struct Transform {
    static let date = HNTDateTransform()
    static let url = URLTransform()
    static let coordinate = LocationCoordinate2DTransform()
}


public enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
    public var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

public protocol BaseModel: Equatable {
    var id: String? { get }
}


public func == <T: BaseModel>(lhs: T, rhs: T) -> Bool {
    guard  let l = lhs.id, let r = rhs.id else { return false }
    return l == r
}


// MARK: Respone
public struct HNTAuthRespone: Mappable {
    public private(set) var expires: Date?
    public private(set) var accessToken: String?
    public init?(map: Map) {
    }
    public mutating func mapping(map: Map) {
        expires <- (map["expires"], Transform.date)
        accessToken <- map["accessToken"]
    }
}



public struct HNTLocation: Mappable {
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


public struct HNPath: Mappable {
    public private(set) var distance: Int?
    public private(set) var duration: Int?
    public private(set) var tolls: Double?
    public init?(map: Map) {
    }
    public init(distance: Int?, duration: Int?, tolls: Double?) {
        self.distance = distance
        self.duration = duration
        self.tolls = tolls
    }
    public mutating func mapping(map: Map) {
        distance <- map["distance"]
        duration <- map["duration"]
        tolls <- map["tolls"]
    }
}

