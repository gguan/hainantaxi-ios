//
//  UserInfoHeaderView.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class UserInfoHeaderView: UIView {
    struct Layout {
        static let size = CGSize(width: R.Width.screen, height: 100)
    }
    private let userAvatar = UIImageView()
    private let userName = UILabel()
    
    
    convenience init() {
        self.init(frame: CGRect(origin: CGPoint.zero, size: Layout.size))
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
        let bg = UIView()
        bg.backgroundColor = UIColor.white
        addSubview(bg)
        addSubview(userAvatar)
        addSubview(userName)
        let size = Layout.size.height - 10 - R.Margin.large * 2
        userAvatar.addCorner(radius: size/2, sourceSize: CGSize(width: size, height: size), color: UIColor.white)
        userAvatar.snp.makeConstraints { (make) in
            make.size.equalTo(size)
            make.top.left.equalTo(R.Margin.large)
        }
        userName.snp.makeConstraints { (make) in
            make.left.equalTo(userAvatar.snp.right).offset(R.Margin.large)
            make.right.equalTo(self).offset(-R.Margin.large)
            make.top.bottom.equalTo(userAvatar)
        }
        bg.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
    }
    
    
    func test() -> UserInfoHeaderView {
        configureWithDataModel(avatar: URL(string: "https://cdn.playalot.cn/user/avatar/ee5a1_1483941122_w_1210_h_1210_569209f31100001c00fd83f3.jpg"),
                                           nickName: "tbxark")
        return self
    }
    
    func configureWithDataModel(avatar: URL?, nickName: String?) {
        userAvatar.ht_setImageWithURL(avatar)
        userName.text = nickName
    
    }

    
}
