//
//  AppDelegate.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import RxSwift
import HNTaxiKit
import IQKeyboardManagerSwift

@UIApplicationMain
class RiderAppDelegate: UIResponder, UIApplicationDelegate {

    fileprivate let disposeBag = DisposeBag()
    var window: UIWindow?
    var locationUpdateTimer: Timer?

    // MARK: Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        installVendor()
        setApperance()
        initAuth()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MapRiderViewController().embedInNavigation(BaseNavigationViewController.self)
        window?.makeKeyAndVisible()
        _ = LocationService.shared.beginLocationTracking()
        if GlobalConfig.role.isDriver, let _ = launchOptions?[.location] {
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
        MQTTService.shared.restart()
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
        let userId = HTAuthManager.default.readCache()?.id ?? ""
        MQTTService.shared.start(id: userId)
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
    
    fileprivate func initAuth() {
        HTAuthManager.default.authChangeObservable
            .subscribe(onNext: { isAuth in
                MQTTService.shared.reset(id: HTAuthManager.default.userId ?? "none")
            })
            .addDisposableTo(disposeBag)
            
    }

}

