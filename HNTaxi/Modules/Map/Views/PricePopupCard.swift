//
//  PricePopupCard.swift
//  HNTaxi
//
//  Created by Tbxark on 16/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class PricePopupCard: UIView {
    
    struct Layout {
        static let height: CGFloat  = 130
        static let showY = R.Height.screen - PricePopupCard.Layout.height - R.Height.fullNavigationBar
        static let hideY = R.Height.screen - R.Height.fullNavigationBar
    }
    fileprivate let distance = UILabel()
    fileprivate let price = UILabel()
    fileprivate let commit = UIButton().then {
        $0.backgroundColor = Color.orange
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.title = "确认打人"
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    
    init() {
        super.init(frame: CGRect.init(x: R.Margin.large - 5,
                                      y: Layout.hideY,
                                      width: R.Width.screen - R.Margin.large * 2 + 10,
                                      height: PricePopupCard.Layout.height))
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
        let bgImage = UIImageView.init(image: R.image.bg_wite_card())
        let spLine = UIView()
        spLine.backgroundColor = UIColor(white: 0.9, alpha: 1)
        addSubview(bgImage)
        addSubview(distance)
        addSubview(price)
        addSubview(commit)
        addSubview(spLine)
        clipsToBounds = true
        bgImage.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(8)
        }
        commit.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(R.Margin.large)
            make.right.bottom.equalTo(self).offset(-R.Margin.large)
            make.height.equalTo(40)
        }
        distance.textAlignment = .right
        distance.snp.makeConstraints { (make) in
            make.left.equalTo(commit)
            make.right.equalTo(self.snp.centerX).offset(-R.Margin.large)
            make.top.equalTo(self)
            make.bottom.equalTo(commit.snp.top)
        }
        price.snp.makeConstraints { (make) in
            make.right.equalTo(commit)
            make.left.equalTo(self.snp.centerX).offset(R.Margin.large)
            make.top.equalTo(self)
            make.bottom.equalTo(commit.snp.top)
        }
        spLine.snp.makeConstraints { (make) in
            make.width.equalTo(1)
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(R.Margin.large * 2)
            make.bottom.equalTo(commit.snp.top).offset(-R.Margin.large * 2)
        }
    }

    func configureWithDataModel(_ dataModel: (distance: String, price: String)) {
        func makeSubAttr(isBold: Bool, text: String) -> NSAttributedString {
            return NSAttributedString(string: text, attributes: [NSFontAttributeName: isBold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.darkGray])
        }
        let dis = NSMutableAttributedString()
        dis.append(makeSubAttr(isBold: false, text: "距离 "))
        dis.append(makeSubAttr(isBold: true, text: dataModel.distance))
        dis.append(makeSubAttr(isBold: false, text: " KM"))
        distance.attributedText = dis
        
        let pri = NSMutableAttributedString()
        pri.append(makeSubAttr(isBold: false, text: "预计 "))
        pri.append(makeSubAttr(isBold: true, text: dataModel.price))
        pri.append(makeSubAttr(isBold: false, text: " 元"))
        price.attributedText = pri
    }
}
