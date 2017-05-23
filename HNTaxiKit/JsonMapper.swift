//
//  JsonMapper.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

public struct JsonMapper {
    
    private var originData: Any?
    
    public var boolValue: Bool? {
        return originData as? Bool ?? numValue?.boolValue
    }
    
    public var stringValue: String? {
        return originData as? String
    }
    
    public var numValue: NSNumber? {
        return originData as? NSNumber
    }
    
    public var CGFloatValue: CGFloat? {
        return originData as? CGFloat
    }
    
    
    public init(_ data: Any?) {
        self.originData = data
    }
    
    
    public func value<T>() -> T? {
        return originData as? T
    }
    
    public subscript(key: String) -> JsonMapper {
        return JsonMapper((originData as? [String: Any])?[key])
    }
    
    public subscript(index: Int) -> JsonMapper {
        guard let array = originData as? [Any],
            index < array.count else {
                return JsonMapper(nil)
        }
        return JsonMapper(array[index])
    }
    
    public static func convertStringToDictionary(text: String?) -> Any? {
        guard let str = text else { return nil }
        guard let data = str.data(using: String.Encoding.utf8) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        return json
    }
    
}


extension JsonMapper {
    
    public var int8Value: Int8? {
        return numValue?.int8Value
    }
    
    public var uint8Value: UInt8? {
        return numValue?.uint8Value
    }
    
    public var int16Value: Int16? {
        return numValue?.int16Value
    }
    
    public var uint16Value: UInt16? {
        return numValue?.uint16Value
    }
    
    public var int32Value: Int32? {
        return numValue?.int32Value
    }
    
    public var uint32Value: UInt32? {
        return numValue?.uint32Value
    }
    
    
    public var int64Value: Int64? {
        return numValue?.int64Value
    }
    
    public var uint64Value: UInt64? {
        return numValue?.uint64Value
    }
    
    public var floatValue: Float? {
        return numValue?.floatValue
    }
    
    public var doubleValue: Double? {
        return numValue?.doubleValue
    }
    
    @available(OSX 10.5, *)
    public var intValue: Int? {
        return numValue?.intValue
    }
    
    @available(OSX 10.5, *)
    public var uintValue: UInt? {
        return numValue?.uintValue
    }
    
}
