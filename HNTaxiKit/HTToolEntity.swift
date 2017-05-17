//
//  HTToolEntity.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import ObjectMapper
import CoreLocation

public func  HTBuildError(code: Int, reson: String) -> Error {
    return NSError(domain: "com.play.wenovel", code: code, userInfo: [NSLocalizedDescriptionKey: reson])
}


public let IDNOTFOUND = "IDNOTFOUND"
extension String {
    public var isValidId: Bool {
        return self != "" && self != IDNOTFOUND
    }
}


class HTDateTransform: TransformType {
    
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
    static let date = HTDateTransform()
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
