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
import HNTaxiKit
 

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    static var location: Observable<Coordinate2D> {
        return shared.location.asObservable()
    }
    private var manager = CoreLocationManager.shared
    private let bgTask = BackgroundTaskManager.shared
    private let location = PublishSubject<Coordinate2D>()
    
    
    private var timer: Timer?
    private var stopTimer: Timer?
    
    private override init() {
        super.init()
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                manager.requestAlwaysAuthorization()
                manager.startUpdatingLocation()
            }
        }
        manager.startUpdatingLocation()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LocationService.applicationEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    

    @objc private func applicationEnterBackground() {
        manager.requestAndStartUpdatingLocation()
        _ = bgTask.beginNewBackgroundTask()
    }
    
    
    @objc private func restartLocationUpdates() {
        timer?.invalidate()
        timer = nil
        manager.requestAndStartUpdatingLocation()
    }
    
    
    
    func beginLocationTracking() -> Bool {
        
        guard CLLocationManager.locationServicesEnabled() else { return false }
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            return false
        default:
            manager.startUpdatingLocation()
            return true
        }
    }
    
    
    func stopLocationTracking() {
        manager.stopUpdatingLocation()
    
    }
    
    
    func updateLocationToServer() {
    
    
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coor = MQTTDriverLocation(id: "test", location: locations.first?.coordinate)?.toJSONString() else { return }
//        _ = MQTTService.publish(topic: MQTTTopic.riderLocation, message: coor)
        
        guard UIApplication.shared.applicationState == .background else { return }
        if timer != nil { return }
        _ = bgTask.beginNewBackgroundTask()
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(LocationService.restartLocationUpdates), userInfo: nil, repeats: false)
        stopTimer?.invalidate()
        stopTimer = nil
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(LocationService.stopLocationTracking), userInfo: nil, repeats: false)
    }

}
 
 
class CoreLocationManager: CLLocationManager {
    static let shared = CoreLocationManager()
    private override init() {
        super.init()
        desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if #available(iOS 9.0, *) {
            allowsBackgroundLocationUpdates = true
        }
        pausesLocationUpdatesAutomatically = false
        distanceFilter = kCLDistanceFilterNone
        requestAndStartUpdatingLocation()
        
    }

    func requestAndStartUpdatingLocation() {
        requestAlwaysAuthorization()
        startUpdatingLocation()
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
        let latlng = string.components(separatedBy: ",")
        guard latlng.count == 2,
            let latStr = latlng.last,
            let lat = Double(latStr),
            let lngStr = latlng.first,
            let lng = Double(lngStr)  else { return nil }
        longitude = lng
        latitude = lat
    }
}
