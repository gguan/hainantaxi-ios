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


extension HTReuqestOrder {
    static func build(location: OrderSelectLocation, path: HTPath?) -> HTReuqestOrder? {
        guard let from = location.from,
            let to = location.to,
            let distance = path?.distance,
            let duration  = path?.duration else { return nil }
        return HTReuqestOrder(from: from, to: to, distance: distance, duration: duration )
    }
}


class MapRiderViewModel {
    
    private let orderService = OrderRiderService()
    
    // 订单预览变化
    let orderRespone    = Variable<(req: HTReuqestOrder?, res: HTOrderProtocol?)>.init((req: nil, res: nil))
    // 当前位置变化
    let currentPosition = Variable<Coordinate2D?>(nil)
    // 路径会话变化
    let orderLocation   = Variable<OrderSelectLocation>(OrderSelectLocation())
    // 附近司机
    let drivers         = Variable<[DriverLocation]>([])
    
    var orderStatus: Observable<HTOrderStatus> {
        return orderService.orderStatus.asObservable()
    }
    
    // 当前所在区域
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
        }
    }
    

    var didSelectStartAndEndLocation: Bool {
        return orderLocation.value.isVaild
    }
    
    private let disposeQueue = DisposeQueue()
    
    init(dependence HUG: HUDManager) {
        // 当前位置发生变化
        currentPosition
            .asObservable()
            .flatMap {(point: Coordinate2D?) -> Observable<HTRegion?> in
                guard let p = point else {
                    return Observable.just(nil)
                }
                let para = HTRequest.Map.region(lat: p.latitude, lng: p.longitude, zoom: 14)
                let req: Observable<HTRegion> = HTNetworking.modelNetRequest(para)
                return req.map({ Optional($0) }).catchErrorJustReturn(nil)
            }
            .subscribe(onNext: {[weak self] (newRegion: HTRegion?) in
                self?.region = newRegion
            })
            .addDisposableTo(disposeQueue, key: "CurrentPosition")
        
        // 位置变化进行反编码
        currentPosition.asObservable()
            .flatMap { (coor: Coordinate2D?) -> Observable<HTResult<HTLocation>> in
                guard let p = coor else {
                    return Observable.just(HTResult<HTLocation>.error(error: NSError.build(desc: "Latlng not found")))
                }
                return MapSearchManager.searchReGeocode(coordinate: p)
                    .mapToResult(error: "ReGeocode error")
            }
            .subscribe(onNext: {[weak self] (loc: HTResult<HTLocation>) in
                switch loc {
                case .success(let value):
                    self?.orderLocation.value.from = value
                case .error(let error):
                    print(error)
                }
            })
            .addDisposableTo(disposeQueue, key: "ReGeocode")

        
        // 订单位置发生变化
        orderLocation.asObservable()
            .distinctUntilChanged({ (old: OrderSelectLocation, new: OrderSelectLocation) -> Bool in
                func isSame(oldCoor: CLLocationCoordinate2D?, newCoor: CLLocationCoordinate2D?) -> Bool {
                    var same = false
                    if let o = oldCoor, let n = newCoor {
                        same = o.latitude.isEqual(to: n.latitude) && o.longitude.isEqual(to: n.longitude)
                    } else if oldCoor == nil &&  newCoor == nil {
                        same = true
                    }
                    return same
                }
               return isSame(oldCoor: old.from?.coordinate, newCoor: new.from?.coordinate)
                && isSame(oldCoor: old.to?.coordinate, newCoor: new.to?.coordinate)
            })
            .flatMap { (location: OrderSelectLocation) -> Observable<HTReuqestOrder?> in
                guard let f = location.from?.coordinate, let t = location.to?.coordinate else {
                    return Observable.just(nil)
                }
                let req: Observable<HTPath> = MapSearchManager.searchPathInfo(from: f, to: t)
                return req.map({ HTReuqestOrder.build(location: location, path: $0) })
                    .catchErrorJustReturn(nil)
            }
            .distinctUntilChanged({ (old: HTReuqestOrder?, new: HTReuqestOrder?) -> Bool in
                if old == nil && new == nil { return true }
                return false
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (request: HTReuqestOrder?) in
                guard let `self` = self else { return }
                let key = "OrderPreview"
                guard let req = request else {
                    self.disposeQueue.dispose(key)
                    self.orderRespone.value = (nil, nil)
                    return
                }
                HUG.showHUD()
                self.orderService.preorder(request: req)
                    .subscribe(onNext: {[weak self] (pre: HTOrderPreview) in
                        self?.orderRespone.value = (request, pre)
                        HUG.hideHUD()
                    }, onError: {[weak self] error in
                        HUG.showError(error)
                        self?.orderRespone.value = (request, nil)
                    })
                    .addDisposableTo(self.disposeQueue, key: key)
            })
            .addDisposableTo(disposeQueue, key: "OrderLocationChange")
        
        
    }
    

    func setCurrentPosition(coordinate: Coordinate2D?) {
        currentPosition.value = coordinate
    }
    
    func setDestinationPosition(coordinate: HTLocation?) {
        orderLocation.value.to = coordinate
    }
    
    
    func unsubscribeAllRegion() {
        drivers.value = []
        region = nil
    }
    
    
    func commitOrder() -> Observable<HTOrder> {
        guard let req = orderRespone.value.req else {
            return Observable<HTOrder>.error(NSError.build(desc: "Request not found"))
        }
        return orderService.commitOrder(request: req)
            .do(onNext: {[weak self] (order: HTOrder) in
                self?.orderRespone.value.res = order
            })
    }
    
    
    
    
    private func subscribe(region: [String]) {
        if region.isEmpty && drivers.value.isEmpty { return }
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
                for latlng in location {
                    guard let id = latlng.id else { continue }
//                    var tmp = latlng
//                    tmp.locations =  latlng.locations?.convertTo(from: CoordinateType.GPS)
                    if keys.contains(id) {
                        newDriver[id]?.update(location: latlng)
                    } else {
                        newDriver[id] = DriverLocation(latlng)
                    }
                }
                self.drivers.value = Array<DriverLocation>(newDriver.values)
            })
            .addDisposableTo(disposeQueue, key: "DriverChange")
    }
    
    private func unsubscribe(region: [String]) {
        region.forEach { (id: String) in
            _ = MQTTService.unsubscriptTopic(name: MQTTRiderTopic.regionDrivers(regionId: id))
        }
    }
    
}
