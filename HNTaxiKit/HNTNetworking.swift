//
//  NetWorking.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import NetworkService
import ObjectMapper
import RxSwift



public enum HNTResult<T> {
    case success(value: T)
    case error(error: Error)
    public func isSuccess() -> Bool {
        switch self {
        case .success(_): return true
        default: return false
        }
    }
}

public struct HNTHTTPResponseModel: HTTPResponseModel {
    public var code: Int?
    public var message: String?
    public var data: Any?
    public var isSuccess: Bool { return true }
    
    public init?(map: Map) {}
    public mutating func mapping(map: Map) {
        code <- map["error.code"]
        message <- map["error.message"]
        data <- map["data"]
    }
}


public typealias HNTRequestType = RequestParameters
public struct HNTRequest {
    
    public enum Admin: RequestParameters {
        
        /// 刷新 Token
        case refreshToken
        /// 七牛 Token
        case uploadToken
        /// 手机登录
        case mobileLogin(country: String, phone: String, code: String)
        /// 第三方登录
        case oauthLogin(type: String, uuid: String, token: String)
        
        public func toRequestEntity() -> RequestEntity {
            switch self {
            case .refreshToken:
                return RequestEntity(POST: "auth/refreshToken")
            case .uploadToken:
                return RequestEntity(GET: "auth/uploadToken")
            case .mobileLogin(let country, let phone, let code):
                return RequestEntity(POST: "authenticate/mobile")
                    .addDictBody(["country": country,
                                  "phone": phone,
                                  "code": code])
            case .oauthLogin(let type, let uuid, let token):
                return RequestEntity(POST: "authenticate/\(type)")
                    .addDictBody(["uid": uuid,
                                  "accessToken": token])
            }
        }
    }
    
   
}


public typealias HNTNetRequestErrorHandle = (URLRequest, Error) -> Void
public final class HNTNetworking: RequestManager {
    public static let `default` = HNTNetworking()
    
    fileprivate let client: NetworkClient<HNTHTTPResponseModel>
    public var noAuthErrorHandle: HNTNetRequestErrorHandle?
    public var commonErrorHandle: HNTNetRequestErrorHandle?
    
    private init() {
        let config = NetworkClientConfig(name: "WeNovelNetWorking", schema: "http", host: "52.197.229.254", port: 4400)
        client = NetworkClient<HNTHTTPResponseModel>(config: config)
        _ = client.setRequestManager(self)
        
    }
    
    public func configure(request: URLRequest) -> URLRequest {
        var req = request
        req.setValue(HNTAuthManager.token, forHTTPHeaderField: "X-Auth-Token")
        return req
    }
    
    public func errorHandle(request: URLRequest, error: Error?) {
        guard let e = error as NSError? else { return }
        switch e.code {
        case 401:
            noAuthErrorHandle?(request, e)
        default:
            commonErrorHandle?(request, e)
        }
    }
}


public extension HNTNetworking {
    public static func modelNetRequest<T:Mappable>(_ type: RequestParameters, key: String? = nil) -> Observable<T> {
        return HNTNetworking.default.client.modelNetRequest(type, key: key)
    }
    
    public static func modelArrayNetRequest<T:Mappable>(_ type: RequestParameters, key: String? = nil) -> Observable<[T]> {
        return HNTNetworking.default.client.modelArrayNetRequest(type, key: key)
    }
    
    public static func netRequest<T>(_ type: RequestParameters, transform: @escaping ((Any) -> (T?))) -> Observable<(T)> {
        return HNTNetworking.default.client.netRequest(type, transform: transform)
    }
    
    public static func netDefaultRequest(_ type: RequestParameters) -> Observable<Any> {
        return HNTNetworking.default.client.netDefaultRequest(type)
    }
}

