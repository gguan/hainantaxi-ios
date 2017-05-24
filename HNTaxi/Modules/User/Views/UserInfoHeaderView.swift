//
//  UserInfoHeaderView.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class UserInfoHeaderView: UIView {
    private let userAvatar = UIImageView()
    private let userName = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    func shareInit() {
        addSubview(userAvatar)
        addSubview(userName)
        
    }

    
}
