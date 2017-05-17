//
//  BaseNavigationViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseNavigationViewController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        shareInit()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    func shareInit() {
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.backIndicatorImage = R.image.nav_back_icon()?.resizeToNavigationItem()
        navigationBar.backIndicatorTransitionMaskImage = R.image.nav_back_icon()?.resizeToNavigationItem()
        navigationBar.tintColor = UIColor.darkGray
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let backBarItem = UIBarButtonItem(image: UIImage(), style: .plain, target: nil, action: nil)
        backBarItem.title = "."
        backBarItem.width = 30
        viewController.navigationItem.backBarButtonItem = backBarItem
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    deinit {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
