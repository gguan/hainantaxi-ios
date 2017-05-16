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
    
    
    public func mapToResult(error: String) -> Observable<HTResult<Element>> {
        return self.map({ element -> HTResult<Element> in
                return HTResult<Element>.success(value: element)
            })
            .catchError({ e -> Observable<HTResult<Element>> in
                let res = HTResult<Element>.error(error: e)
                return Observable<HTResult<Element>>.just(res)
            })
    }
    
    
    public func mapToType<T>(success: T, error: T) -> Observable<HTResult<T>> {
        return self.map({ _ -> HTResult<T> in
                return HTResult<T>.success(value: success)
            })
            .catchError({ e -> Observable<HTResult<T>> in
                let res = HTResult<T>.error(error: e)
                return Observable<HTResult<T>>.just(res)
            })
    }
    
   
}

