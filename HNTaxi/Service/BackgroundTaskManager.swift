//
//  BackgroundTaskManager.swift
//  HNTaxi
//
//  Created by Tbxark on 22/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit



class BackgroundTaskHelper {

    static func checkPermission() -> Bool {
        func showAlert(message: String) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            guard let top = UIApplication.topViewController() else { return  }
            top.present(alert, animated: true, completion: nil)
        }
        switch UIApplication.shared.backgroundRefreshStatus {
        case .denied:
            showAlert(message: "本应用需要后台刷新权限才能正常工作")
            return false
        case .restricted:
            showAlert(message: "本应用需要后台刷新权限才能正常工作")
            return false
        default:
            return true
        }
    }
}

class BackgroundTaskManager {
    
    static let shared = BackgroundTaskManager()
    private var bgTasgIdList = [UIBackgroundTaskIdentifier]()
    private var masterTaskId =  UIBackgroundTaskInvalid
    
    init() {}
    
    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
        let app = UIApplication.shared
        var bgTaskId = UIBackgroundTaskInvalid
        bgTaskId = app.beginBackgroundTask {[weak self, bgTaskId]  in
            guard let `self` = self else { return }
            if let idx = self.bgTasgIdList.index(of: bgTaskId) {
                self.bgTasgIdList.remove(at: idx)
                app.endBackgroundTask(bgTaskId)
            }
        }
        if masterTaskId == UIBackgroundTaskInvalid {
            masterTaskId = bgTaskId
        } else {
            bgTasgIdList.append(bgTaskId)
            endBackgroundTasks()
            
        }
        return bgTaskId
    }
    
    func endBackgroundTasks() {
        drainBGTaskList(all: false)
    }
    
    func endAllBackgroundTasks() {
        drainBGTaskList(all: true)
    }
    
    
    private func drainBGTaskList(all: Bool) {
        let app = UIApplication.shared
        let count = bgTasgIdList.count
        if (!all && count < 1) { return }
        for _ in (all ? 0 : 1)..<count {
            guard let bgTaskId = bgTasgIdList.first else { continue }
            app.endBackgroundTask(bgTaskId)
            _ = bgTasgIdList.removeFirst()
        }
        if all {
            app.endBackgroundTask(masterTaskId)
            masterTaskId = UIBackgroundTaskInvalid
        }
    }

}
