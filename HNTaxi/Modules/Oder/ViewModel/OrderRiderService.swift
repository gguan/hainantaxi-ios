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
    let order = Variable<(isPreOrder: Bool, data: HTOrder?)>.init((isPreOrder: false, data: nil))
    let orderStatus = Variable<HTOrderStatus>(HTOrderStatus.none)
    private let disposeBag = DisposeBag()
    
    init() {
        fetchLatesOrder()
    }
    
    func preorder(isPreOrder: Bool = false,
                  from: CLLocationCoordinate2D,
                  to: CLLocationCoordinate2D,
                  type: HTCarType = HTCarType.common) -> Observable<HTOrder> {
        
        let data = HTReuqestOrder(from: from, to: to, carType: type)
        let req = isPreOrder ? HTRequest.Rider.Order.preOrder(req: data) : HTRequest.Rider.Order.reqOrder(req: data)
        return HTNetworking.modelNetRequest(req)
            .do(onNext: {[weak self] (order: HTOrder) in
                    self?.changeOrderResult(isPreOrder: isPreOrder, data: order)
                }, onError: {[weak self] _ in
                    self?.fetchLatesOrder()
                    self?.changeOrderResult(isPreOrder: isPreOrder, data: nil)
                })
    }
    
    func fetchLatesOrder() {
        let lates: Observable<HTOrder> = HTNetworking.modelNetRequest(HTRequest.Rider.Order.latest)
        lates.subscribe(onNext: {[weak self] (order: HTOrder) in
            self?.order.value = (false, order)
        })
        .addDisposableTo(disposeBag)
    }
    
    func cancleOrder() -> Observable<Any> {
        guard let id = order.value.data?.id else {
            return Observable<Any>.error(NSError.build(desc: "Id not found"))
        }
        return HTNetworking.netDefaultRequest(HTRequest.Rider.Order.cancle(orderId: id))
    }
    
    
    func commentOrder(comment: HTComment) ->  Observable<Any> {
        return Observable<Any>.never()
    }
    
    
    private func changeOrderResult(isPreOrder: Bool, data: HTOrder?) {
        if let id = order.value.data?.id {
            _ = MQTTService.unsubscriptTopic(name: MQTTRiderTopic.orderStatus(orderId: id))
        }
        if let id = data?.id {
            MQTTService.subscriptTopic(name: MQTTRiderTopic.orderStatus(orderId: id))
                .map({ (msg: CocoaMQTTMessage) -> HTOrderStatus in
                    let json = JsonMapper.convertStringToDictionary(text: msg.string)
                    return Transform.orderStatus.transformFromJSON(json) ?? HTOrderStatus.none
                })
                .do(onNext: { (status: HTOrderStatus) in
                    print("Status : \(status)")
                })
                .bind(to: orderStatus)
                .addDisposableTo(disposeBag)
        }
    }
}
