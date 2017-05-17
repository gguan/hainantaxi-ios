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
    
    fileprivate var mqtt: CocoaMQTT?
    fileprivate let deiver = Variable<[Coordinate2D]>([])
    fileprivate let disposeQueue = DisposeQueue()
    
    private init() {}
    
    func start() {
        mqtt = CocoaMQTT(clientID: "iOS", host: "45.63.126.236", port: 1883)
        mqtt?.username = ""
        mqtt?.password = ""
        mqtt?.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        mqtt?.connect()
        disposeQueue.dispose()
        
    }
    
    func stop() {
        disposeQueue.dispose()
        mqtt?.disconnect()
        mqtt = nil
    }
    
    
    func updateSelectLocation(_ point: Coordinate2D) {
        mqtt?.publish("location", withString: "{\(point.latitude),\(point.longitude)}", qos: CocoaMQTTQOS.qos1)
    }
}


extension DriverManagerService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connect: \(host) \(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            mqtt.subscribe("location")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Pubsh \(message.topic): \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("Receive \(message.topic): \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("Subscribe: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT: DidPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT: DidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        mqtt.connect()
        print("MQTT: DidDisconnect \(err?.localizedDescription ?? "")")
    }
    
}
