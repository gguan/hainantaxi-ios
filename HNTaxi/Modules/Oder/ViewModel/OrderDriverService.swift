//
//  OrderDriverViewModel.swift
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

class OrderDriverService {
    let order  = Variable<HTOrder?>(nil)
    let status = Variable<HTDriverStatus>(HTDriverStatus.know)
    private let disposeBag = DisposeBag()
    
    init() {
        fetchLatesOrder()
    }
    
    func changeIsRest(_ rest: Bool) -> Observable<Any> {
        let status = rest ? HTDriverStatus.rest : HTDriverStatus.work
        return HTNetworking.netDefaultRequest(HTRequest.Driver.Order.changeStatus(status: status))
    }

    func getOrder(id: String) -> Observable<HTOrder> {
        return HTNetworking.modelNetRequest(HTRequest.Driver.Order.getOrder(orderId: id))
    }
    
    
    func fetchLatesOrder() {
        let lates: Observable<HTOrder> = HTNetworking.modelNetRequest(HTRequest.Rider.Order.latest)
        lates.subscribe(onNext: {[weak self] (order: HTOrder) in
                self?.order.value = order
            }, onError: {[weak self] _ in
                self?.order.value = nil
        })
        .addDisposableTo(disposeBag)
    }
}
