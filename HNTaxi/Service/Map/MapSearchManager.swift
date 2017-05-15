//
//  MapSearchManager.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import Foundation
import RxSwift
import HNTaxiKit
import CoreLocation

typealias MapSearchCompletionBlock = (_ request: AMapSearchObject, _ response: AMapSearchObject?, _ error: NSError?) -> Void;


extension AMapGeoPoint {
    var cooridinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude),
                                      longitude: CLLocationDegrees(longitude))
    }
}

extension CLLocationCoordinate2D {
    var aMapGeoPoint: AMapGeoPoint {
        return AMapGeoPoint.location(withLatitude: CGFloat(latitude),
                                     longitude: CGFloat(longitude))
    }
}

extension AMapPOI {
    var hnLocation: HNTLocation {
        return HNTLocation(coordinate: location.cooridinate, name: name, cityCode: citycode, address: address)
    }
}

class MapSearchManager: NSObject,  AMapSearchDelegate {
    private let search = AMapSearchAPI()!
    private var mapTable = NSMapTable<AnyObject, AnyObject>(keyOptions: [.strongMemory], valueOptions: [.copyIn])
    
    public static let shared = MapSearchManager()
    private override init(){
        super.init()
        search.delegate = self
    }
    
    
    static func searchPOIKeywords(city: String, keywords: String ) -> Observable<[HNTLocation]> {
        guard !city.isEmpty && !keywords.isEmpty else {
            return Observable<[HNTLocation]>.just([])
        }
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.keywords = keywords
        request.city = city
        return Observable.create({ anyObserver -> Disposable in
            MapSearchManager.shared.searchForRequest(request: request, completionBlock: {
                (req: AMapSearchObject, res: AMapSearchObject?, error: NSError?) in
                if let e = error {
                    anyObserver.on(.error(e))
                } else if let aResponse = res as? AMapPOISearchResponse {
                    let locations = aResponse.pois?.map({ (poi: AMapPOI) -> HNTLocation in
                        return poi.hnLocation
                    })
                    anyObserver.on(.next(locations ?? []))
                    anyObserver.on(.completed)
                } else {
                    anyObserver.on(.error(NSError.build(desc: "Respone not found")))
                }
            })
            return Disposables.create()
        })
    }
    
    
    static func searchReGeocode(coordinate: CLLocationCoordinate2D) -> Observable<HNTLocation> {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = coordinate.aMapGeoPoint
        regeo.requireExtension = true
        return Observable.create({ anyObserver -> Disposable in
            MapSearchManager.shared.searchForRequest(request: regeo, completionBlock: {
                (req: AMapSearchObject, res: AMapSearchObject?, error: NSError?) in
                if let e = error {
                    anyObserver.on(.error(e))
                } else if let aResponse = res as? AMapReGeocodeSearchResponse {
                    if let poi = aResponse.regeocode?.pois?.first {
                        anyObserver.on(.next(poi.hnLocation))
                    } else {
                        let coordinate = aResponse.regeocode?.addressComponent?.streetNumber?.location?.cooridinate
                        var name = (aResponse.regeocode?.addressComponent?.township ?? "")
                        name += (aResponse.regeocode?.addressComponent?.neighborhood ?? "")
                        name += (aResponse.regeocode?.addressComponent?.streetNumber?.street ?? "" )
                        name += (aResponse.regeocode?.addressComponent?.streetNumber?.number ?? "")
                        name += (aResponse.regeocode?.addressComponent?.building ?? "")
                        let address = aResponse.regeocode?.addressComponent?.citycode
                        let cityCode = aResponse.regeocode?.addressComponent?.citycode
                        let location =  HNTLocation(coordinate: coordinate, name: name, cityCode: cityCode, address: address)
                        anyObserver.on(.next(location))
                    }
                    anyObserver.on(.completed)
                } else {
                    anyObserver.on(.error(NSError.build(desc: "Respone not found")))
                }
            })
            return Disposables.create()
        })
    }
    
    static func searchPathInfo(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Observable<HNPath> {
        let navi = AMapDrivingRouteSearchRequest()
        navi.requireExtension = true
        navi.origin = from.aMapGeoPoint
        navi.destination = to.aMapGeoPoint
        return Observable.create({ anyObserver -> Disposable in
            MapSearchManager.shared.searchForRequest(request: navi, completionBlock: {
                (req: AMapSearchObject, res: AMapSearchObject?, error: NSError?) in
                if let e = error {
                    anyObserver.on(.error(e))
                } else if let aResponse = (res as? AMapRouteSearchResponse)?.route?.paths?.first {
                    let path = HNPath(distance: aResponse.distance, duration: aResponse.duration, tolls: Double(aResponse.tolls))
                    anyObserver.on(.next(path))
                    anyObserver.on(.completed)
                } else {
                    anyObserver.on(.error(NSError.build(desc: "Respone not found")))
                }
            })
            return Disposables.create()
        })
    }
    
    
    func searchForRequest(request: AMapSearchObject, completionBlock: MapSearchCompletionBlock) {
        if let req = request as? AMapPOIKeywordsSearchRequest {
            search.aMapPOIKeywordsSearch(req)
        }
        else if let req = request as? AMapDrivingRouteSearchRequest {
            search.aMapDrivingRouteSearch(req)
        }
        else if let req = request as? AMapInputTipsSearchRequest {
            search.aMapInputTipsSearch(req)
        }
        else if let req = request as? AMapGeocodeSearchRequest {
            search.aMapGeocodeSearch(req)
        }
        else if let req = request as? AMapReGeocodeSearchRequest {
            search.aMapReGoecodeSearch(req)
        }
        else {
            NSLog("unsupported request")
            return
        }
        
        mapTable.setObject(completionBlock as AnyObject?, forKey: request)
    }
    
    private func performBlock(withRequest request: AMapSearchObject, withResponse response: AMapSearchObject) {
        guard let block = mapTable.object(forKey: request) as? MapSearchCompletionBlock else {
            return
        }
        
        block(request, response, nil)
        
        mapTable.removeObject(forKey: request)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        guard let block = mapTable.object(forKey: request as AnyObject?) as? MapSearchCompletionBlock else {
            return
        }
        
        block(request as! AMapSearchObject, nil, error as NSError?)
        
        mapTable.removeObject(forKey: request as AnyObject?)
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
}
