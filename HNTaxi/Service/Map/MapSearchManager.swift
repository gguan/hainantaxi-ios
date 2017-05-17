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

typealias Coordinate2D = CLLocationCoordinate2D
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
    var hnLocation: HTLocation {
        return HTLocation(coordinate: location.cooridinate, name: name, cityCode: citycode, address: address)
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
    
    
    static func searchPOIKeywords(city: String, keywords: String ) -> Observable<[HTLocation]> {
        guard !city.isEmpty && !keywords.isEmpty else {
            return Observable<[HTLocation]>.error(NSError.build(desc: "Keyword is empty"))
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
                    let locations = aResponse.pois?.map({ (poi: AMapPOI) -> HTLocation in
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
    
    
    static func searchReGeocode(coordinate: CLLocationCoordinate2D, ingorePOI: Bool = true) -> Observable<HTLocation> {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = coordinate.aMapGeoPoint
        regeo.requireExtension = true
        return Observable.create({ anyObserver -> Disposable in
            MapSearchManager.shared.searchForRequest(request: regeo, completionBlock: {
                (req: AMapSearchObject, res: AMapSearchObject?, error: NSError?) in
                if let e = error {
                    anyObserver.on(.error(e))
                } else if let aResponse = res as? AMapReGeocodeSearchResponse {
                    var isReturn = false
                    if !ingorePOI, let poi = aResponse.regeocode?.pois?.first {
                        anyObserver.on(.next(poi.hnLocation))
                        isReturn = true
                    }
                    
                    if !isReturn {
                        let coordinate = aResponse.regeocode?.addressComponent?.streetNumber?.location?.cooridinate
                        var name = (aResponse.regeocode?.addressComponent?.township ?? "")
                        name += (aResponse.regeocode?.addressComponent?.neighborhood ?? "")
                        name += (aResponse.regeocode?.addressComponent?.streetNumber?.street ?? "" )
                        name += (aResponse.regeocode?.addressComponent?.streetNumber?.number ?? "")
                        name += (aResponse.regeocode?.addressComponent?.building ?? "")
                        let address = aResponse.regeocode?.addressComponent?.citycode
                        let cityCode = aResponse.regeocode?.addressComponent?.citycode
                        let location =  HTLocation(coordinate: coordinate, name: name, cityCode: cityCode, address: address)
//                        print("POI \( aResponse.regeocode?.pois?.first?.hnLocation.name ?? "")")
//                        print("Formate: \(aResponse.regeocode?.formattedAddress ?? "")")
//                        print("Name: \(name)")
//                        print(" ---------- ")
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
    
    static func searchPathInfo(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Observable<HTPath> {
        let navi = AMapDrivingRouteSearchRequest()
        navi.requireExtension = true
        navi.origin = from.aMapGeoPoint
        navi.destination = to.aMapGeoPoint
        navi.strategy = 5
        func stringToCoordinates( _ text: String) -> [CLLocationCoordinate2D] {
            return text.components(separatedBy: ";")
                .flatMap { (subText: String) -> CLLocationCoordinate2D? in
                    let xy = subText.components(separatedBy: ",")
                    guard xy.count == 2,
                        let ystr = xy.last,
                        let y = Double(ystr),
                        let xstr = xy.first,
                        let x = Double(xstr)  else { return nil }
                    return CLLocationCoordinate2D(latitude: y, longitude: x)
                }
        }
        return Observable.create({ anyObserver -> Disposable in
            MapSearchManager.shared.searchForRequest(request: navi, completionBlock: {
                (req: AMapSearchObject, res: AMapSearchObject?, error: NSError?) in
                if let e = error {
                    anyObserver.on(.error(e))
                } else if let route = (res as? AMapRouteSearchResponse)?.route, let path = route.paths?.first {
                    let points =  path.steps?.flatMap({ (step: AMapStep) -> [CLLocationCoordinate2D] in
                        guard let line = step.polyline else { return [] }
                        return stringToCoordinates(line)
                    })
                    let path = HTPath(distance: path.distance, duration: path.duration, tolls: Double(route.taxiCost), lineCoordinates: points)
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
