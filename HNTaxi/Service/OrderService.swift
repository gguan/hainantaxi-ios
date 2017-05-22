//
//  OrderService.swift
//  HNTaxi
//
//  Created by Tbxark on 22/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import HNTaxiKit
import ObjectMapper
import CocoaMQTT



protocol OrderServiceManagerProtocol {
    func fetchCurrentOrder() -> Observable<Any>
}

class OrderService {
    class Rider {
        
        static func request(order: HTReuqestOrder) -> Observable<String> {
            return HTNetworking.netDefaultRequest(HTRequest.Rider.Order.request(order: order))
                .flatMap({ (respone: Any) -> Observable<String> in
                    return MQTTService.subscriptTopic(name: MQTTTopic.riderOrder(order: "test"))
                        .flatMap({ (msg: CocoaMQTTMessage) -> Observable<String> in
                            guard let content = msg.string else {
                                return Observable<String>.never()
                            }
                            return Observable.just(content)
                        })
                })
        }
    }
    
}
