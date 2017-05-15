//
//  HNTAuthManager.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import NetworkService
import CacheService
import ObjectMapper

public class HNTAuthManager {
    static public let `default` = HNTAuthManager()
    static var token: String? {
        return HNTAuthManager.default.auth?.accessToken
    }
    private let keychainCache = KeychainCache(name: "com.play.hntaxi.auth")
    private let userdefaultCache = UserDefaultsCache(name: "com.play.hntaxi.auth")
    private var auth: HNTAuthRespone? {
        didSet {
            authChangeSubject.on(.next(auth?.accessToken != nil))
        }
    }
    private let authChangeSubject = PublishSubject<Bool>()
    
    
    
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
    
    
    public func readCache() -> Bool {
        guard let s: String = keychainCache?.syncReadCache(forKey: "auth")?.stringValue() ?? userdefaultCache?.syncReadCache(forKey: "auth") as? String else { return false}
        guard let model = Mapper<HNTAuthRespone>().map(JSONString: s) else { return false }
        guard let date = model.expires, date.timeIntervalSinceNow > 600 else { return  false}
        auth = model
        return true
    }
    
    public func mobile(country: String, phone: String, code: String) -> Observable<Void> {
        let signal: Observable<HNTAuthRespone> =  HNTNetworking.modelNetRequest(HNTRequest.Admin.mobileLogin(country: country, phone: phone, code: code))
        return signal.do(onNext: { respone in
            guard let json = respone.toJSONString() else { return }
            self.keychainCache?.asnycCache(value: CacheableValue.string(value: json), forKey: "auth", complete: nil)
            self.userdefaultCache?.asnycCache(value: json, forKey: "auth", complete: nil)
        })
            .map({ _ in return () })
        
    }
    
    public func oAuth(type: Any) -> Observable<Void>  {
        return Observable<Void>.never()
    }
}



