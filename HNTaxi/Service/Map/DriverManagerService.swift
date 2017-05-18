//
//  DriverManagerService.swift
//  HNTaxi
//
//  Created by Tbxark on 17/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import CocoaMQTT
import CoreLocation

class DriverManagerService {
    
    static let shared = DriverManagerService()
    
    fileprivate let deiver = Variable<[Coordinate2D]>([])
    fileprivate let disposeQueue = DisposeQueue()
    
    private init() {
    }
        
    func updateSelectLocation(_ point: Coordinate2D) {
        MQTTService.publish(topic: MQTTTopic.myLocation, message: point.zipString)
    }
}

