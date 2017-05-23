//
//  CityDataModel.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import Foundation
import ObjectMapper


public protocol ChinaZipable {
    var name: String { get set }
    var zip: String  { get set }
}

public protocol ChinaCityZipable: ChinaZipable {
    var index: String { get }
    var isHot: Bool { get }
}



struct CityDataManager {
    
    static func localAddressList() -> [ProvinceDataModel] {
        guard let path = R.file.addressJson(),
            let data = try? Data(contentsOf: path),
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue),
            let models = Mapper<ProvinceDataModel>().mapArray(JSONString: json as String) else {
                return []
        }
        return models
    }
}


// 省份
public struct ProvinceDataModel: Mappable, ChinaCityZipable {
    public var name: String
    public var zip: String
    public var index: String
    public var isCity: Bool
    public var isHot: Bool
    public var city: [CityDataModel]
    
    public init?(map: Map) {
        guard let n: String = map["n"].value(),
            let z: String = map["z"].value(),
            let i: String = map["i"].value() else {
                return nil
        }
        let c: [CityDataModel] = map["c"].value() ?? []
        name = n
        zip  = z
        index = i
        city = c
        isCity = map["f"].value() ?? false
        isHot  = map["h"].value() ?? false
    }
    
    mutating public func mapping(map: Map) {
        name <- map["n"]
        zip  <- map["z"]
        index <- map["i"]
        isCity <- map["f"]
        isHot <- map["h"]
        city <- map["c"]
        
    }
}


// 城市
public struct CityDataModel: Mappable, ChinaCityZipable {
    public var name: String
    public var zip: String
    public var index: String
    public var isHot: Bool
    public var county: [CountyDataModel]
    
    public init?(map: Map) {
        guard let n: String = map["n"].value(),
            let z: String = map["z"].value(),
            let i: String = map["i"].value() else {
                return nil
        }
        
        let c: [CountyDataModel] = map["county"].value() ?? []
        name = n
        zip  = z
        index = i
        county = c
        isHot  = map["h"].value() ?? false
    }
    
    mutating public func mapping(map: Map) {
        name <- map["n"]
        zip  <- map["z"]
        index <- map["i"]
        isHot <- map["h"]
        county <- map["c"]
    }
}


// 街道
public struct CountyDataModel: Mappable, ChinaZipable {
    public var name: String
    public var zip: String
    
    public init?(map: Map) {
        guard let n: String = map["n"].value(),
            let z: String = map["z"].value()else { return nil }
        name = n
        zip  = z
    }
    
    mutating public func mapping(map: Map) {
        name <- map["n"]
        zip  <- map["z"]
    }
}


extension Collection where Iterator.Element == ProvinceDataModel {
    
    public func toGroup() -> SortDictionary<String, [ChinaCityZipable]> {
        var dict = SortDictionary<String, [ChinaCityZipable]>()
        var array = [ChinaCityZipable]()
        var temp = [Character: [ChinaCityZipable]]()
        for v in self {
            if v.isCity {
                array.append(v)
            } else {
                v.city.forEach({ (model) in
                    array.append(model)
                })
            }
        }
        let hotKey: Character = "*"
        for c in array {
            if let i = c.index.characters.first {
                var list: [ChinaCityZipable] = temp[i] ?? []
                list.append(c)
                temp[i] = list
            }
            if c.isHot {
                var list: [ChinaCityZipable] = temp[hotKey] ?? []
                list.append(c)
                temp[hotKey] = list
            }
            
        }
        for k in temp.keys.sorted() {
            dict["\(k)"] = temp[k]?.sorted(by: { $0.0.index < $0.1.index })
        }
        return dict
    }
}


