//
//  MapDriverViewModel.swift
//  HNTaxi
//
//  Created by Tbxark on 19/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import HNTaxiKit
import CoreLocation
import CocoaMQTT
import ObjectMapper
import CacheService



class LocationRecoder {
    static let cache = SQLiteCache(name: "com.hainantexi.cache")
  
    let currentLocation = Variable<Coordinate2D?>(nil)

    private var paths = [String]()
    private let disposeBag = DisposeBag()
    private let id: String
    
    init(id: String) {
        self.id = id
        currentLocation.asObservable()
            .flatMap { (coor: Coordinate2D?) -> Observable<String> in
                guard let c = coor else {
                    return Observable.never()
                }
                return Observable.just(c.zipString)
            }
            .buffer(timeSpan: 30, count: 100, scheduler: SerialDispatchQueueScheduler(qos: DispatchQoS.background))
            .subscribe(onNext: {[weak self] (point: [String]) in
                guard let `self` = self, !point.isEmpty else { return }
                let path = point.reduce("", { a, b in "\(a);\(b)"})
                self.paths.append(path)
                let cache = self.paths.reduce("", { a, b in "\(a);\(b)"})
                let flag = LocationRecoder.cache?.syncCache(value: cache as NSString, forKey: id) ?? false
                print("Cache \(flag ? "Success" : "Error") : \(cache)")

            })
            .addDisposableTo(disposeBag)
    }
    
    deinit {
        let cache = paths.reduce("", { a, b in "\(a);\(b)"})
        _ = LocationRecoder.cache?.syncCache(value: cache as NSString, forKey: id)
    }

}


class MapDriverViewModel {
    
    private let disposeBag = DisposeBag()
    let currentPosition =  Variable<Coordinate2D?>(nil)
    
    
    init() {
        currentPosition.asObservable()
            .throttle(1, scheduler: SerialDispatchQueueScheduler(qos: DispatchQoS.default))
            .subscribe(onNext: { (points: Coordinate2D?) in
                guard  let p = points else { return }
                let model = MQTTDriverLocation(id: "test", location: p)
                guard let json = model?.toJSONString() else { return }
                MQTTService.publish(topic: MQTTTopic.driverRegion(regionId: "13-2234-5740"), message: json)
            })
            .addDisposableTo(disposeBag)
        
    }
}
