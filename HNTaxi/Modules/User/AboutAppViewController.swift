//
//  AboutAppViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func layoutViewController() {
        navigationItem.title = "关于我们"
        view.backgroundColor = UIColor.white
        
    }
    
    
    private func configureObservable() {
        
        
    }
    
}
