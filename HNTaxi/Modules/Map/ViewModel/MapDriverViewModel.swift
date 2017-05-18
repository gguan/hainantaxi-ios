//
//  MapDriverViewModel.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import HNTaxiKit
import CoreLocation
import CocoaMQTT
import ObjectMapper

class MapDriverViewModel {
    
    let currentPosition =  Variable<Coordinate2D?>(nil)
    let orderLocation = Variable<OrderSelectLocation>(OrderSelectLocation())
    let travelPath = Variable<HTPath?>(nil)
    
    private let region = Variable<HTRegion?>(nil)
    

    var didSelectStartAndEndLocation: Bool {
        return orderLocation.value.isVaild
    }
    
    private var lastRegions = [String]()
    private var drivers = Variable<[DriverLocation]>([])
    private let disposeQueue = DisposeQueue()
    
    init() {
        currentPosition
            .asObservable()
            .flatMap {[weak self] (point: Coordinate2D?) -> Observable<HTRegion?> in
                guard let p = point else {
                    return Observable.just(nil)
                }
                self?.orderLocation.value.from = point
                let req: Observable<HTRegion> = HTNetworking.modelNetRequest(HTRequest.Common.region(lat: p.latitude, lng: p.longitude, zoom: 14))
                return req.map({ Optional($0) }).catchErrorJustReturn(nil)
            }
            .do(onNext: { (region: HTRegion?) in
                print("\(region?.toJSONString() ?? "")")
            }, onError: { (error: Error) in
                print("Error \(error)")
            }, onCompleted: { 
                print("Complete")
            }, onDispose: { 
                print("Dispose")
            })
            .bind(to: region)
            .addDisposableTo(disposeQueue, key: "CurrentPosition")
        
        region.asObservable().distinctUntilChanged { (a: HTRegion?, b: HTRegion?) -> Bool in
                guard let l = a, let r = b else {
                    return true
                }
                return l != r
            }
            .subscribe(onNext: {[weak self] (r: HTRegion?) in
                self?.subscribe(region: r)
            })
            .addDisposableTo(disposeQueue, key: "Region")
        
        orderLocation.asObservable().flatMap { (location: OrderSelectLocation) -> Observable<HTPath?> in
                guard let f = location.from, let t = location.to else {
                    return Observable.just(nil)
                }
                let req: Observable<HTPath> = MapSearchManager.searchPathInfo(from: f, to: t)
                return req.map({ Optional($0)}).catchErrorJustReturn(nil)
            }
            .bind(to: travelPath)
            .addDisposableTo(disposeQueue, key: "orderLocation")
    
    }
    
    func subscribe(region: HTRegion?) {
        lastRegions.forEach { (id: String) in
            MQTTService.unsubscriptTopic(name: MQTTTopic.driverLocation(regionId: id))
        }
        lastRegions.removeAll()
        guard let id = region?.subRegions else { return }
        print("Region: \(id)")
        var observers = [Observable<MQTTMessage>]()
        lastRegions = id
        for i in id {
            observers.append(MQTTService.subscriptTopic(name: MQTTTopic.driverLocation(regionId: i)))
        }
        Observable.merge(observers).flatMap { (msg: CocoaMQTTMessage) -> Observable<MQTTDriverLocation?> in
                guard let json = msg.string else { return Observable.just(nil) }
                return Observable.just(Mapper<MQTTDriverLocation>().map(JSONObject: json))
            }
            .subscribe(onNext: {[weak self] (loc: MQTTDriverLocation?) in
                guard let `self` = self, let location = loc, let id = location.id else { return }
                var newDriver = self.drivers.value.filter({ $0.isExpire })
                var isContain = false
                for d in newDriver {
                    guard let i = d.data.id else { continue }
                    if i == id {
                        d.update(location: location)
                        isContain = true
                        break
                    }
                }
                if !isContain {
                    newDriver.append(DriverLocation(location))
                }
                self.drivers.value = newDriver
            })
            .addDisposableTo(disposeQueue, key: "DriverChange")
    }
    
}
