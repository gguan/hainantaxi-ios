//
//  AddressViewModel.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import RxSwift
import RxCocoa
import HNTaxiKit
import CoreLocation
import CocoaMQTT
import ObjectMapper

class AddressViewModel {

    
    func setAddress(type: String, address: HTAddress) -> Observable<HTAddress> {
        return HTNetworking.modelNetRequest(HTRequest.Rider.User.setAddress(type: type, address: address))
    }
}
