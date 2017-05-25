//
//  HUGManager.swift
//  HNTaxi
//
//  Created by Tbxark on 25/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SVProgressHUD


protocol HUDManager {
    func showHUD()
    func hideHUD()
    func showError(_ error: Error)
    func isShowHUD() -> Bool
}

struct SVProgressHUDManager: HUDManager {
    func showHUD() {
        SVProgressHUD.show()
    }
    func hideHUD() {
        SVProgressHUD.dismiss()
    }
    func showError(_ error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription ?? "Error")
    }
    func isShowHUD() -> Bool {
        return SVProgressHUD.isVisible()
    }
}
