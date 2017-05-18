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



public enum HTResult<T> {
    case success(value: T)
    case error(error: Error)
    public func isSuccess() -> Bool {
        switch self {
        case .success(_): return true
        default: return false
        }
    }
}

public struct HTHTTPResponseModel: HTTPResponseModel {
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


public typealias HTRequestType = RequestParameters
public struct HTRequest {
    
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
                    .addDictBody(["zone": country,
                                  "mobile": phone,
                                  "code": code])
            case .oauthLogin(let type, let uuid, let token):
                return RequestEntity(POST: "authenticate/\(type)")
                    .addDictBody(["uid": uuid,
                                  "accessToken": token])
            }
        }
    }
    
    
    public enum Common: RequestParameters {
        case region(lat: Double, lng: Double, zoom: Int)
        public func toRequestEntity() -> RequestEntity {
            switch self {
            case .region(let lat, let lng, let zoom):
                return RequestEntity(GET: "region")
                    .addQuerys(["lat": String(format: "%.6f", lat),
                                "lng": String(format: "%.6f", lng),
                                "zoomDepth": zoom])
            }
        }
    }
    
   
}


public typealias HTNetRequestErrorHandle = (URLRequest, Error) -> Void
public final class HTNetworking: RequestManager {
    public static let `default` = HTNetworking()
    
    fileprivate let client: NetworkClient<HTHTTPResponseModel>
    public var noAuthErrorHandle: HTNetRequestErrorHandle?
    public var commonErrorHandle: HTNetRequestErrorHandle?
    
    private init() {
        let config = NetworkClientConfig(name: "WeNovelNetWorking", schema: "http", host: "106.14.202.84", port: 4400)
        client = NetworkClient<HTHTTPResponseModel>(config: config)
        _ = client.setRequestManager(self)
        
    }
    
    public func configure(request: URLRequest) -> URLRequest {
        var req = request
        req.setValue(HTAuthManager.token, forHTTPHeaderField: "X-Auth-Token")
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


public extension HTNetworking {
    public static func modelNetRequest<T:Mappable>(_ type: RequestParameters, key: String? = nil) -> Observable<T> {
        return HTNetworking.default.client.modelNetRequest(type, key: key)
    }
    
    public static func modelArrayNetRequest<T:Mappable>(_ type: RequestParameters, key: String? = nil) -> Observable<[T]> {
        return HTNetworking.default.client.modelArrayNetRequest(type, key: key)
    }
    
    public static func netRequest<T>(_ type: RequestParameters, transform: @escaping ((Any) -> (T?))) -> Observable<(T)> {
        return HTNetworking.default.client.netRequest(type, transform: transform)
    }
    
    public static func netDefaultRequest(_ type: RequestParameters) -> Observable<Any> {
        return HTNetworking.default.client.netDefaultRequest(type)
    }
}

