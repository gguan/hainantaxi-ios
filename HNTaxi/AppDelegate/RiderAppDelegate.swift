//
//  AppDelegate.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import HNTaxiKit
import IQKeyboardManagerSwift

@UIApplicationMain
class RiderAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationUpdateTimer: Timer?
//    let locationTracker = 

    // MARK: Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MapRiderViewController().embedInNavigation(BaseNavigationViewController.self)
        installVendor()
        setApperance()
        _ = HTAuthManager.default.readCache()
        window?.makeKeyAndVisible()
        MQTTService.shared.start()
        _ = LocationService.shared.beginLocationTracking()
        if let _ = launchOptions?[.location] {
            MQTTService.shared.start()
            CoreLocationManager.shared.requestAlwaysAuthorization()
            if #available(iOS 9.0, *) {
                CoreLocationManager.shared.allowsBackgroundLocationUpdates = true
            }
            CoreLocationManager.shared.startMonitoringSignificantLocationChanges()
        }
        _ = BackgroundTaskHelper.checkPermission()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        MQTTService.shared.start()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension RiderAppDelegate {
        
    fileprivate func installVendor() {
        SMSService.install()
        AMapServices.shared().apiKey = "be62598784b82e8a21bbb2ba77427a36"
        IQKeyboardManager.sharedManager().enable = true
    }
    
    fileprivate func setApperance() {
        UIToolbar.appearance().tintColor = UIColor.darkGray
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().backIndicatorImage = R.image.nav_back_icon()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.nav_back_icon()
        UINavigationBar.appearance().tintColor = UIColor.darkGray
        UITableViewCell.appearance().selectionStyle = .none
    }

}

