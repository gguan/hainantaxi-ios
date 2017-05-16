//
//  AppDelegate.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MapViewController().embedInNavigation(BaseNavigationViewController.self)
        installVendor()
        setApperance()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension AppDelegate {
    fileprivate func installVendor() {
        AMapServices.shared().apiKey = "be62598784b82e8a21bbb2ba77427a36"
    }
    
    fileprivate func setApperance() {
        UIToolbar.appearance().tintColor = UIColor.darkGray
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().backIndicatorImage = R.image.icon_arrow_left()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.icon_arrow_left()
        UINavigationBar.appearance().tintColor = UIColor.darkGray
        UITableViewCell.appearance().selectionStyle = .none
    }

}

