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


enum UserRole: String {
    case driver = "driver"
    case rider = "rider"
    var isDriver: Bool {
        return self == .driver
    }
    
    var isRider: Bool {
        return self == .rider
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


public class LocationCoordinate2DTransform: TransformType {
    public typealias Object = CLLocationCoordinate2D
    public typealias JSON = [String: Double]
    
    init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        let map = JsonMapper(value)
        let lat = map["lat"].doubleValue
        let log = map["log"].doubleValue
        guard let y = lat, let x = log else { return nil }
        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        guard let v = value else { return nil }
        return ["lat": v.latitude, "log": v.longitude]
    }
}


public class StandardCoordinateTransform: TransformType {
    public typealias Object = CLLocationCoordinate2D
    public typealias JSON = [Double]
    init() {}
    public func transformFromJSON(_ value: Any?) -> Object? {
        guard let v = value, let latlng = v as? JSON, latlng.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
    }
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value.map({ [$0.latitude, $0.longitude] })
    }
}


public class StandardCoordinateArrayTransform: TransformType {
    public typealias Object = [CLLocationCoordinate2D]
    public typealias JSON = [[Double]]
    init() {}
    public func transformFromJSON(_ value: Any?) -> Object? {
        guard let v = value, let array = v as? JSON else { return nil }
        return array.flatMap({ (latlng: [Double]) -> CLLocationCoordinate2D? in
            guard latlng.count == 2 else { return  nil }
            return CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
        })
    }
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.map({ (p: CLLocationCoordinate2D) -> [Double] in
            return [p.latitude, p.longitude]
        })
    }
}

/*
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
 */

public class HTOrderStatusTransform: TransformType {
    public typealias Object = HTOrderStatus
    public typealias JSON = [String: String]

    init()  {}
    public func transformFromJSON(_ value: Any?) -> HTOrderStatus? {
        let map = JsonMapper(value)
        guard let status = map["status"].stringValue else { return HTOrderStatus.none }
        switch status {
            case "received": return HTOrderStatus.received
            case "searching" : return HTOrderStatus.searching
            case "requestFail": return HTOrderStatus.requestFail(err: nil)
            case "requestSuccess": return HTOrderStatus.requestSuccess(driverId: nil)
            case "waitDriver": return HTOrderStatus.waitDriver(latlng: nil)
            case "boarded": return HTOrderStatus.boarded
            case "driving": return HTOrderStatus.driving(latlng: nil)
            case "getOff": return HTOrderStatus.getOff
            case "pay": return HTOrderStatus.pay(status: true, err: nil)
            case "cancle": return HTOrderStatus.cancle
            default: return HTOrderStatus.none
        }
    }
    
    public func transformToJSON(_ value: HTOrderStatus?) -> [String : String]? {
        var json = [String : String]()
        guard let v = value else { return json }
        switch v {
        case .received:
            json["status"] = "received"
        case .searching:
            json["status"] = "searching"
        case .requestFail(let err):
            json["status"] = "requestFail"
        case .requestSuccess(let driverId):
            json["status"] = "requestSuccess"
        case .waitDriver(let latlng):
            json["status"] = "waitDriver"
        case .boarded:
            json["status"] = "boarded"
        case .driving(let latlng):
            json["status"] = "driving"
        case .getOff:
            json["status"] = "getOff"
        case .pay(let status, let err):
            json["status"] = "pay"
        case .cancle:
            json["status"] = "cancle"
        default:
            return json
        }
        return json
    }

}


public struct Transform {
    static let date = HTDateTransform()
    public static let url = URLTransform()
    public static let coordinate = LocationCoordinate2DTransform()
    public static let standardCoordinate = StandardCoordinateTransform()
    public static let standardCoordinateArray = StandardCoordinateArrayTransform()
    public static let carType = EnumTransform<HTCarType>()
    public static let orderStatus = HTOrderStatusTransform()
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
