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

//region-14-13493-11824

typealias MQTTMessage = CocoaMQTTMessage
typealias MQTTMsgId = UInt16



protocol MQTTTopicProtocol {
    func toString() -> String
}


enum MQTTCommonTopic: MQTTTopicProtocol {
    case disconnect
    
    func toString() -> String {
        switch self {
        case .disconnect:
            return "disconnect"
        }
    }
}

enum MQTTRiderTopic: MQTTTopicProtocol {
    
    // Subscript: 区域内司机的位置
    case regionDrivers(regionId: String)
    // Subscript: 订单状态
    case orderStatus(orderId: String)

    
    func toString() -> String {
        switch self {
        case .regionDrivers(let regionId):
            return "region/\(regionId)/driver"
        case .orderStatus(let id):
            return "rider/order/\(id)"

        }
    }
}


enum MQTTDriverTopic: MQTTTopicProtocol {
    
    // Publish: 司机位置 message 中带有 id
    case driverLocation
    // Subscript: 订单状态
    case orderStatus(orderId: String)
    // Publish: 司机状态
    case driverStatus
    // Subscript: 等待订单
    case waitOrder(driverId: String)
    
    func toString() -> String {
        switch self {
        case .driverLocation:
            return "location/driver"
        case .orderStatus(let id):
            return "rider/order/\(id)"
        case .driverStatus:
            return "driver/status"
        case .waitOrder(let id):
            return "driver/\(id)/waitorder"
        }
    }
}



class MQTTService: NSObject {
    static let shared = MQTTService()
    var reconnectWhenError = true
    var connectStatus: Observable<CocoaMQTTConnState> {
        return connectStatusVar.asObservable()
    }
    fileprivate let connectStatusVar = Variable<CocoaMQTTConnState>(CocoaMQTTConnState.initial)
    
    fileprivate var mqtt: CocoaMQTT?
    fileprivate var subscriptList = [String: PublishSubject<MQTTMessage>]()
    fileprivate var didSubscript = [String]()
    fileprivate var id: String = "none"
   
    private override init() {}
    func start(id: String) {
        if let m = mqtt {
            if m.connState == .disconnected {
                m.connect()
            }
        } else {
            mqtt = CocoaMQTT(clientID: "iOS-\(id)-\(String.randomString(length: 10))", host: "hn.tbxark.site", port: 1883)
            mqtt?.username = id
            mqtt?.password = ""
            mqtt?.willMessage = CocoaMQTTWill(topic: MQTTCommonTopic.disconnect.toString(), message: "{\"id\":\"\(id)\"}")
            mqtt?.keepAlive = 60
            mqtt?.delegate = self
            mqtt?.autoReconnect = true
            connectStatusVar.value = .connecting
            mqtt?.connect()
        }
    }
    
    func restart() {
        start(id: id)
    }
    
    func reset(id: String) {
        if id == self.id, let m = mqtt {
            if m.connState == .disconnected {
                m.connect()
            }
            return
        }
        stop()
        self.id = id
        didSubscript.removeAll()
        start(id: id)
    }
    
    func stop() {
        mqtt?.disconnect()
        mqtt = nil
    }
    
    static func publish(topic: MQTTTopicProtocol, message: String) -> MQTTMsgId?  {
        return shared.publish(topic: topic.toString(), message: message)
    }
    
    static func subscriptTopic(name: MQTTTopicProtocol) -> Observable<MQTTMessage> {
        return shared.subscriptTopic(name: name.toString())
    }
    
    static func unsubscriptTopic(name: MQTTTopicProtocol) -> MQTTMsgId? {
        return shared.unsubscriptTopic(name: name.toString())
    }
    
    private func subscriptTopic(name: String) -> Observable<MQTTMessage> {
        if let m = mqtt, m.connState == .connected {
            mqtt?.subscribe(name, qos: .qos2)
        }
        let data = subscriptList[name] ?? PublishSubject<MQTTMessage>()
        subscriptList[name] = data
        return data.asObservable()
    }
    
    private func publish(topic: String, message: String) -> MQTTMsgId? {
        return mqtt?.publish(topic, withString: message, qos: CocoaMQTTQOS.qos1)
    }
    
    private func unsubscriptTopic(name: String) -> MQTTMsgId? {
        subscriptList[name]?.onCompleted()
        subscriptList.removeValue(forKey: name)
        return mqtt?.unsubscribe(name)
    }
}


extension MQTTService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        connectStatusVar.value = mqtt.connState
//        print("Connect: \(host) \(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            for topic in subscriptList.keys {
                if !didSubscript.contains(topic) {
                    _ = mqtt.subscribe(topic)
                }
            }
        }
        connectStatusVar.value = mqtt.connState
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
//        print("Pubsh \(message.topic): \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
//        print("Receive \(message.topic): \(message.string ?? "")")
        if message.topic.hasPrefix("region/") && message.topic.hasSuffix("/driver") {
            subscriptList["region/+/driver"]?.on(.next(message))
        }
        subscriptList[message.topic]?.on(.next(message))
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
//        print("Subscribe: \(topic)")
        didSubscript.append(topic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
//        print("Unsubscribe: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
//        print("MQTT: DidPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
//        print("MQTT: DidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
//        print("MQTT: DidDisconnect \(err?.localizedDescription ?? "")")
        didSubscript.removeAll()
        connectStatusVar.value = mqtt.connState
    }
}
