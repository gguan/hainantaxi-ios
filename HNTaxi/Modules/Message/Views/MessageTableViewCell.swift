//
//  MessageTableViewCell.swift
//  HNTaxi
//
//  Created by Tbxark on 25/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import YYText

class MessageTableViewCell: UITableViewCell {
    
    struct Layout {
        static let inset = UIEdgeInsets(top: R.Margin.large, left: R.Margin.large, bottom: R.Margin.large, right: R.Margin.large)
        static let imageSize: CGSize = {
            let w = R.Width.screen - inset.left - inset.right - R.Margin.large * 2
            let h = w * 0.5
            return CGSize(width: w, height: h)
        }()
    }

    private let headerImage = UIImageView()
    private let contentText = YYLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }


    func shareInit() {
        let bg = UIImageView(image: R.image.bg_white_card())
        let spline = UIView().then {
            $0.backgroundColor = Color.bgLightGay
        }
        let showMore = UILabel().then {
            $0.text = "查看详情 ▸"
            $0.textColor = Color.textDarkGray
        }
        contentView.addSubview(bg)
        contentView.addSubview(headerImage)
        contentView.addSubview(contentText)
        contentView.addSubview(spline)
        contentView.addSubview(showMore)
        
        bg.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView).offset(R.Margin.large)
            make.bottom.right.equalTo(contentView).offset(-R.Margin.large)
        }
        headerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(bg)
            make.height.equalTo(Layout.imageSize.height)
        }
        showMore.snp.makeConstraints { (make) in
            make.left.equalTo(bg).offset(R.Margin.large)
            make.bottom.right.equalTo(bg).offset(-R.Margin.large)
            make.height.equalTo(40)
        }
        spline.snp.makeConstraints { (make) in
            make.left.equalTo(bg).offset(R.Margin.large)
            make.right.equalTo(bg).offset(-R.Margin.large)
            make.height.equalTo(1)
            make.bottom.equalTo(showMore.snp.top).offset(-R.Margin.large)
        }
        contentText.snp.makeConstraints { (make) in
            make.top.equalTo(headerImage.snp.bottom).offset(R.Margin.large)
            make.left.equalTo(bg).offset(R.Margin.large)
            make.right.equalTo(bg).offset(-R.Margin.large)
            make.bottom.equalTo(spline.snp.top).offset(-R.Margin.large)
        }
    }
}
