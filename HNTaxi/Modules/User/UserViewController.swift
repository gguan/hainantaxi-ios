//
//  UserViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 17/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func layoutViewController() {
        navigationItem.title = "已登录"
        view.backgroundColor = UIColor.white
        
    }
    
    
    private func configureObservable() {
        
        
    }
}
