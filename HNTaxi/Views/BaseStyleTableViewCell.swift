//
//  BaseStyleTableViewCell.swift
//  HNTaxi
//
//  Created by Tbxark on 22/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


class BaseTitleTableViewCell: UITableViewCell, Reusable {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.numberOfLines = 0
        $0.textColor = Color.textBlack
    }
    private let subLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.numberOfLines = 0
        $0.textColor = Color.textDarkGray
        $0.textAlignment = .right
    }
    private let arrow = UIImageView(image: R.image.icon_arrow_right()).then {
        $0.contentMode = .scaleAspectFit
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    private func shareInit() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subLabel)
        contentView.addSubview(arrow)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(R.Margin.large)
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(arrow.snp.left).offset(-R.Margin.large)
        }
        subLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(R.Margin.large)
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(arrow.snp.left).offset(-R.Margin.large)
        }
        arrow.snp.makeConstraints { (make) in
            make.size.equalTo(8)
            make.right.equalTo(contentView).offset(-R.Margin.large)
            make.centerY.equalTo(contentView)
        }
    }
    
    func configureWithDataModel(title: String, subTitle: String? = nil, isLogoutStyle: Bool = false) {
        titleLabel.text = title
        titleLabel.textColor = isLogoutStyle ? Color.red : Color.textDarkGray
        titleLabel.textAlignment = isLogoutStyle ? .center : .left
        subLabel.text = subTitle
        arrow.isHidden = isLogoutStyle
    }
}


class BasImageTableViewCell: UITableViewCell, Reusable {
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.numberOfLines = 0
    }
    private let arrow = UIImageView(image: R.image.icon_arrow_right())
    private let iconImage = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    private func shareInit() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(iconImage)
        
        iconImage.snp.makeConstraints { (make) in
            make.size.equalTo(20)
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(R.Margin.large)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImage.snp.right).offset(R.Margin.large)
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(arrow.snp.left).offset(-R.Margin.large)
        }
        
        arrow.snp.makeConstraints { (make) in
            make.size.equalTo(8)
            make.right.equalTo(contentView).offset(-R.Margin.large)
            make.centerY.equalTo(contentView)
        }
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
