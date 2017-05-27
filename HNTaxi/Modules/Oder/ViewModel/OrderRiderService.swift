//
//  OrderRiderService.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import HNTaxiKit
import CoreLocation
import CocoaMQTT
import ObjectMapper

class OrderRiderService {
    let orderStatus = Variable<HTOrderStatus>(HTOrderStatus.none)
    private let disposeQueue = DisposeQueue()
    private var order: HTOrder? {
        didSet {
            let key = "OrderStatus"
            if let id = oldValue?.id {
                _ = MQTTService.unsubscriptTopic(name: MQTTRiderTopic.orderStatus(orderId: id))
                disposeQueue.dispose(key)
            }
            if let id = order?.id {
                MQTTService.subscriptTopic(name: MQTTRiderTopic.orderStatus(orderId: id))
                    .subscribe(onNext: {[weak self] (msg: CocoaMQTTMessage) in
                        print(msg.string ?? "")
                        guard let json = JsonMapper.convertStringToDictionary(text: msg.string),
                        let status = Transform.orderStatus.transformFromJSON(json) else { return }
                        self?.orderStatus.value = status
                    })
                    .addDisposableTo(disposeQueue, key: key)
            } 
        }
    }
    
    init() {
        fetchLatesOrder()
    }
    
    // 订单预览
    func preorder(request: HTReuqestOrder) -> Observable<HTOrderPreview> {
        return HTNetworking.modelNetRequest(HTRequest.Rider.Order.preOrder(req: request))
    }
    
    // 确认订单
    func commitOrder(request: HTReuqestOrder) -> Observable<HTOrder> {
        return HTNetworking.modelNetRequest(HTRequest.Rider.Order.reqOrder(req: request))
            .do(onNext: { (order: HTOrder) in
                self.order = order
            }, onError: { _ in
                self.order = nil
            })
    }
    
    // 当前订单
    func fetchLatesOrder() {
        let lates: Observable<HTOrder> = HTNetworking.modelNetRequest(HTRequest.Rider.Order.latest)
        lates.subscribe(onNext: {[weak self] (order: HTOrder) in
            self?.order = order
        })
        .addDisposableTo(disposeQueue, key: "LastOrder")
    }
    
    // 取消订单
    func cancleOrder() -> Observable<Any> {
        guard let id = order?.id else {
            return Observable<Any>.error(NSError.build(desc: "Id not found"))
        }
        return HTNetworking.netDefaultRequest(HTRequest.Rider.Order.cancle(orderId: id))
    }
    
    // 评价订单
    func commentOrder(comment: HTComment) ->  Observable<Any> {
        return Observable<Any>.never()
    }
    
   
}
