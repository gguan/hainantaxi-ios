 //
//  LocationService.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    static var location: Observable<Coordinate2D> {
        return shared.location.asObservable()
    }
    private var manager = CLLocationManager()
    private var currentStatus: Bool?
    private let location = PublishSubject<Coordinate2D>()
    private override init() {
        super.init()
        manager.delegate = self
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        if let s = currentStatus, s == false {
            return
        }
        if CLLocationManager.authorizationStatus() == .notDetermined {
            currentStatus = false
            manager.requestAlwaysAuthorization()
            self.configManager()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                manager.requestWhenInUseAuthorization()
                currentStatus = false
                self.configManager()
            }
        }
        self.configManager()
    }
    
    private func configManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100.0
        updatingLocation()
        
    }
    
    func updatingLocation() {
        manager.startUpdatingLocation()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = manager.location?.coordinate else { return }
        location.on(.next(coordinate))
    }
}
 
class CoordinateBuffer {
    private(set) var container = Array<CLLocationCoordinate2D>()
    private let maxSize: Int
    init(size: UInt) {
        maxSize = Int(size)
    }
    func append(_ point: CLLocationCoordinate2D) -> Bool {
        if container.count <  maxSize {
            container.append(point)
            return true
        } else {
            return false
        }
    }
    func encode(cleanBuffer: Bool = true) -> String {
        let str = CLLocationCoordinate2D.encode(points: container)
        if cleanBuffer {
            container.removeAll()
        }
        return str
    }
}
 
extension CLLocationCoordinate2D {
    
    var zipString: String {
        return "\(longitude),\(latitude)"
    }
    
    
    static func decode(string: String) -> [CLLocationCoordinate2D] {
        return string.components(separatedBy: ";")
            .flatMap { CLLocationCoordinate2D(string: $0) }
    }
    
    static func encode(points: [CLLocationCoordinate2D]) -> String {
        return points.reduce("", { o, p in "\(o);\(p.zipString)"})
    }
    
    init?(string: String) {
        let xy = string.components(separatedBy: ",")
        guard xy.count == 2,
            let ystr = xy.last,
            let y = Double(ystr),
            let xstr = xy.first,
            let x = Double(xstr)  else { return nil }
        latitude = y
        longitude = x
    }
}
