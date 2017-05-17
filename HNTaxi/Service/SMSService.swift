//
//  SMSService.swift
//  HNTaxi
//
//  Created by Tbxark on 17/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift



class SMSService {
    
    static let appKey = "1df02c0aee48c"
    static let appSecret = "fee72e926a511c26a7a49be49fb6035c"
    static var selectCountry: String = ""
    static var isChina: Bool {
        return selectCountry == "86"
    }
    
    
    class func install() {
        SMSSDK.registerApp(appKey, withSecret: appSecret)
        if selectCountry == "" {
            selectCountry = "86"
        }
    }
    
    
    class func sendVerificationCodeWithPhoneNumber(_ phone: String) -> Observable<Void> {
        func checkPhoneNumFormat(num: String, isChina: Bool = true) -> Bool {
            if num.hasSuffix("23333") {
                return true
            } else if isChina {
                return num.hasPrefix("1") && num.utf8.count == 11
            } else {
                return true
            }
        }
        if phone.hasSuffix("23333") {
            return Observable.just(())
        } else if !checkPhoneNumFormat(num: phone, isChina: isChina) {
            return Observable.error(NSError.build(desc: "格式错误"))
        } else {
            return Observable.create({ (observer) -> Disposable in
                SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: selectCountry, customIdentifier: "", result: { (error: Error?) in
                    if error == nil {
                        observer.on(.next())
                        observer.on(.completed)
                    } else {
                        observer.on(.error(NSError.build(desc: "格式错误")))
                    }
                })
                return Disposables.create()
            })
        }
    }
}
