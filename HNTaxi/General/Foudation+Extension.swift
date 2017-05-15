//
//  Foudation+Extension.swift
//  wenovel
//
//  Created by Tbxark on 08/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import RxSwift
import HNTaxiKit

extension Error {
    public var localizedDescription: String? {
        return (self as NSError).userInfo[NSLocalizedDescriptionKey] as? String
    }
}


extension NSError {
    public static func build(code: Int = -1, desc: String) -> NSError {
        return NSError.init(domain: "com.play.wenovel", code: code, userInfo: [NSLocalizedDescriptionKey: desc])
    }

}




extension Observable {
    
    
    public func mapToValue<R>(_ value: R) -> Observable<R> {
        return self.map({ _ in
            return value
        })
    }
    
    public func mapToValue<R>(_ value: R, valueOnError eValue: R) -> Observable<R> {
        return self.map({ _ in
            return value
        }).catchErrorJustReturn(eValue)
    }
    
    
    public func mapToResult(error: String) -> Observable<HNTResult<Element>> {
        return self.map({ element -> HNTResult<Element> in
                return HNTResult<Element>.success(value: element)
            })
            .catchError({ e -> Observable<HNTResult<Element>> in
                let res = HNTResult<Element>.error(error: e)
                return Observable<HNTResult<Element>>.just(res)
            })
    }
    
    
    public func mapToType<T>(success: T, error: T) -> Observable<HNTResult<T>> {
        return self.map({ _ -> HNTResult<T> in
                return HNTResult<T>.success(value: success)
            })
            .catchError({ e -> Observable<HNTResult<T>> in
                let res = HNTResult<T>.error(error: e)
                return Observable<HNTResult<T>>.just(res)
            })
    }
    
   
}

