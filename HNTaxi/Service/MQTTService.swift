//
//  MQTTService.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import CocoaMQTT



typealias MQTTMessage = CocoaMQTTMessage

enum MQTTTopic {
    case myLocation
    case driverLocation(regionId: String)
    func toString() -> String {
        switch self {
        case .myLocation:
            return "location"
        case .driverLocation(let regionId):
            return "drivers/location/\(regionId)"
        }
    }
}

class MQTTService: NSObject {
    static let shared = MQTTService()
    fileprivate var mqtt: CocoaMQTT?
    var reconnectWhenError = true
    fileprivate var subscriptList = [String: [PublishSubject<MQTTMessage>]]()
    fileprivate var didSubscript = [String]()
    fileprivate var id: String = "iOS-\(String.randomString(length: 10))"
    private override init() {}
    func start() {
        if let m = mqtt {
            if m.connState == .disconnected {
                m.connect()
            }
        } else {
            mqtt = CocoaMQTT(clientID: id, host: "45.63.126.236", port: 1883)
            mqtt?.username = ""
            mqtt?.password = ""
            mqtt?.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqtt?.keepAlive = 60
            mqtt?.delegate = self
            mqtt?.connect()
        }
    }
    
    func reset(id: String) {
        stop()
        self.id = id
        didSubscript.removeAll()
        start()
    }
    
    func stop() {
        mqtt?.disconnect()
        mqtt = nil
    }
    
    static func publish(topic: MQTTTopic, message: String)  {
        shared.publish(topic: topic.toString(), message: message)
    }
    
    static func subscriptTopic(name: MQTTTopic) -> Observable<MQTTMessage> {
        return shared.subscriptTopic(name: name.toString())
    }
    
    static func unsubscriptTopic(name: MQTTTopic) {
        shared.unsubscriptTopic(name: name.toString())
    }
    
    private func subscriptTopic(name: String) -> Observable<MQTTMessage> {
        if let m = mqtt, m.connState == .connected {
            mqtt?.subscribe(name)
        }
        let signal = PublishSubject<MQTTMessage>()
        var data = subscriptList[name] ?? [PublishSubject<MQTTMessage>]()
        data.append(signal)
        subscriptList[name] = data
        return signal.asObservable()
    }
    
    private func publish(topic: String, message: String) {
        mqtt?.publish(topic, withString: message, qos: CocoaMQTTQOS.qos1)
    }
    
    private func unsubscriptTopic(name: String) {
        _ = mqtt?.unsubscribe(name)
        subscriptList.removeValue(forKey: name)
    }
}


extension MQTTService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connect: \(host) \(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            for topic in subscriptList.keys {
                if !didSubscript.contains(topic) {
                    _ = mqtt.subscribe(topic)
                }
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
//        print("Pubsh \(message.topic): \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("Receive \(message.topic): \(message.string ?? "")")
        subscriptList[message.topic]?.forEach({ (subject: PublishSubject<MQTTMessage>) in
            subject.on(.next(message))
        })
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("Subscribe: \(topic)")
        didSubscript.append(topic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
//        print("MQTT: DidPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
//        print("MQTT: DidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if reconnectWhenError {
            mqtt.connect()
        }
        didSubscript.removeAll()
        print("MQTT: DidDisconnect \(err?.localizedDescription ?? "")")
    }
}
