//
//  MapRiderViewModel.swift
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

class MapRiderViewModel {
    
    let currentPosition =  Variable<Coordinate2D?>(nil)
    let orderLocation = Variable<OrderSelectLocation>(OrderSelectLocation())
    let travelPath = Variable<HTPath?>(nil)
    let drivers = Variable<[DriverLocation]>([])

    private var region: HTRegion? {
        didSet {
            let oldId = Set(oldValue?.subRegions ?? [String]())
            let newId = Set(region?.subRegions ?? [String]())
            let sameId = oldId.intersection(newId)
            let un = Array(oldId.subtracting(sameId))
            if !un.isEmpty {
                drivers.value = []
            }
            unsubscribe(region: un)
            subscribe(region: Array(newId))
//            subscribe(region: ["+"])
        }
    }
    

    var didSelectStartAndEndLocation: Bool {
        return orderLocation.value.isVaild
    }
    
    private let disposeQueue = DisposeQueue()
    
    init() {
        currentPosition
            .asObservable()
            .flatMap {[weak self] (point: Coordinate2D?) -> Observable<HTRegion?> in
                guard let p = point else {
                    return Observable.just(nil)
                }
                self?.orderLocation.value.from = point
                let para = HTRequest.Map.region(lat: p.latitude, lng: p.longitude, zoom: 14)
                let req: Observable<HTRegion> = HTNetworking.modelNetRequest(para)
                return req.map({ Optional($0) }).catchErrorJustReturn(nil)
            }
            .subscribe(onNext: {[weak self] (newRegion: HTRegion?) in
                self?.region = newRegion
            })
            .addDisposableTo(disposeQueue, key: "CurrentPosition")
        
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
    
    func subscribe(region: [String]) {
        var observers = [Observable<MQTTMessage>]()
        for i in region {
            let sig = MQTTService.subscriptTopic(name: MQTTRiderTopic.regionDrivers(regionId: i))
            observers.append(sig)
        }
        let mapper = Mapper<MQTTDriverLocation>()
      
        Observable.merge(observers).flatMap { (msg: CocoaMQTTMessage) -> Observable<MQTTDriverLocation?> in
                guard let json = msg.string else { return Observable.just(nil) }
                let model = mapper.map(JSONString: json)
                return Observable.just(model)
            }
            .buffer(timeSpan: 0.5, count: 3, scheduler: SerialDispatchQueueScheduler(qos: DispatchQoS.default))
            .subscribe(onNext: {[weak self] (loc: [MQTTDriverLocation?]) in
                guard let `self` = self else { return }
                let location = loc.flatMap({ (ele: MQTTDriverLocation?) -> MQTTDriverLocation? in
                    guard ele?.id != nil else { return nil }
                    return ele
                })
                var newDriver = [String: DriverLocation]()
                for dl in self.drivers.value.filter({ $0.isVaild }) {
                    guard let id = dl.data.id else { continue }
                    newDriver[id] = dl
                }
                let keys = newDriver.keys
                for xy in location {
                    guard let id = xy.id else { continue }
                    if keys.contains(id) {
                        newDriver[id]?.update(location: xy)
                    } else {
                        newDriver[id] = DriverLocation(xy)
                    }
                }
                self.drivers.value = Array<DriverLocation>(newDriver.values)
            })
            .addDisposableTo(disposeQueue, key: "DriverChange")
    }
    
    func unsubscribe(region: [String]) {
        region.forEach { (id: String) in
            _ = MQTTService.unsubscriptTopic(name: MQTTRiderTopic.regionDrivers(regionId: id))
        }
    }
    
}
