//
//  MessageViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func layoutViewController() {
        title = "消息"
        view.backgroundColor = UIColor.white
    }
    
    
    private func configureObservable() {
        
        
    }
}
