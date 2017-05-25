//
//  HTAuthManager.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import NetworkService
import CacheService
import ObjectMapper

public class HTAuthManager {
    static public let `default` = HTAuthManager()
    static var token: String? {
        return HTAuthManager.default.auth?.accessToken
    }
    private let keychainCache = KeychainCache(name: "com.play.hntaxi.auth")
    private let userdefaultCache = UserDefaultsCache(name: "com.play.hntaxi.auth")
    private var auth: HTAuthRespone? {
        didSet {
            authChangeSubject.on(.next(auth?.accessToken != nil))
        }
    }
    private let authChangeSubject = PublishSubject<Bool>()
    
    
    public var userId: String? {
        return auth?.id
    }
    public var isAuth: Bool {
        return auth?.accessToken != nil
    }
    public var authChangeObservable: Observable<Bool> {
        return authChangeSubject.asObservable()
    }
    private init() {}
    
    public func logout() {
        auth = nil
        let k = keychainCache?.syncCache(value: CacheableValue.string(value: ""), forKey: "auth") ?? false
        let u = userdefaultCache?.syncCache(value: "", forKey: "auth") ?? false
        print("KeyChain Cache Result: \(k), UserDefault Cache Result: \(u)")
    }
    
    
    public func readCache() -> HTAuthRespone? {
        guard let s: String = keychainCache?.syncReadCache(forKey: "auth")?.stringValue() ?? userdefaultCache?.syncReadCache(forKey: "auth") as? String else { return nil}
        guard let model = Mapper<HTAuthRespone>().map(JSONString: s) else { return nil }
        guard let date = model.expires, date.timeIntervalSinceNow > 600 else { return  nil}
        auth = model
        return model
    }
    
    public func mobile(country: String, phone: String, code: String) -> Observable<Void> {
        let signal: Observable<HTAuthRespone> =  HTNetworking.modelNetRequest(HTRequest.Admin.mobileLogin(country: country, phone: phone, code: code))
        return signal.do(onNext: { respone in
            guard let json = respone.toJSONString() else { return }
            let k = self.keychainCache?.syncCache(value: CacheableValue.string(value: json), forKey: "auth") ?? false
            let u = self.userdefaultCache?.syncCache(value: json, forKey: "auth") ?? false
            print("KeyChain Cache Result: \(k), UserDefault Cache Result: \(u)")
            self.auth = respone
            })
            .map({ _ in return () })
        
    }
    
    public func oAuth(type: Any) -> Observable<Void>  {
        return Observable<Void>.never()
    }
}



