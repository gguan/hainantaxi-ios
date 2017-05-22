//
//  BaseStyleTableViewCell.swift
//  HNTaxi
//
//  Created by Tbxark on 22/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


class BaseTitleTableViewCell: UITableViewCell, Reusable {
    private let titleLabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    private func shareInit() {
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Color.textBlack
        let arrow = R.image.icon_arrow_right()
        let imgv = UIImageView(image: arrow)
        imgv.contentMode = .scaleAspectFit
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgv)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(R.Margin.large)
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(imgv.snp.left).offset(-R.Margin.large)
        }
        imgv.snp.makeConstraints { (make) in
            make.size.equalTo(8)
            make.right.equalTo(contentView).offset(-R.Margin.large)
            make.centerY.equalTo(contentView)
        }
    }
    
    func configureWithDataModel(title: String, isLogoutStyle: Bool = false) {
        titleLabel.text = title
        titleLabel.textColor = isLogoutStyle ? Color.orange : Color.textBlack
        titleLabel.textAlignment = isLogoutStyle ? .center : .left
    }
}


class BaseStyleTableViewCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }

    private func shareInit() {
    }
}
