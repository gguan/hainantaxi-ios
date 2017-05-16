//
//  LocationSelectView.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class LocationSelectView: UIView {
    let buttons = (from: UIButton(), destination: UIButton())
    
    init() {
        super.init(frame: CGRect.zero)
        shareInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    func shareInit() {
        let selectlocationBg = UIImageView(image: R.image.map_select_location())
        isUserInteractionEnabled = true
        addSubview(selectlocationBg)
        addSubview(buttons.from)
        addSubview(buttons.destination)
        
        selectlocationBg.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        
        
        buttons.from.snp.makeConstraints { (make) in
            make.left.equalTo(selectlocationBg).offset(40)
            make.right.equalTo(selectlocationBg)
            make.top.equalTo(selectlocationBg).offset(5)
            make.height.equalTo(50)
        }
        buttons.destination.snp.makeConstraints { (make) in
            make.left.equalTo(selectlocationBg).offset(40)
            make.right.equalTo(selectlocationBg)
            make.bottom.equalTo(selectlocationBg).offset(-5)
            make.height.equalTo(50)
        }
        func configureButton(btn: UIButton, title: String) {
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(UIColor.darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            btn.titleLabel?.textAlignment = .left
            btn.contentHorizontalAlignment = .left
        }
        configureButton(btn: buttons.from, title: "我的位置")
        configureButton(btn: buttons.destination, title: "选择目的地")
    }

}
