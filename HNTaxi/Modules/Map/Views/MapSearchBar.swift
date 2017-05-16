//
//  MapSearchBar.swift
//  HNTaxi
//
//  Created by Tbxark on 16/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class MapSearchBar: UIView {

    let cityButton = UIButton().then {
        $0.title = "北京 ▾  "
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    let searchTextfield = UITextField().then {
        $0.textColor = UIColor.darkGray
        $0.placeholder = "你要去哪儿"
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    let cancleButton = UIButton().then {
        $0.title = "取消"
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitleColor(UIColor.gray, for: .normal)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: R.Height.statusBar, width: R.Width.screen, height: R.Height.navigationBar))
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
        addSubview(cityButton)
        addSubview(searchTextfield)
        addSubview(cancleButton)
        
        cityButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(R.Margin.large)
            make.top.bottom.equalTo(self)
            make.width.equalTo(80)
        }
        cancleButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-R.Margin.large)
            make.top.bottom.equalTo(self)
            make.width.equalTo(60)
        }
        searchTextfield.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.equalTo(cityButton.snp.right).offset(R.Margin.small)
            make.right.equalTo(cancleButton.snp.left).offset(-R.Margin.small)
        }
    }
}
