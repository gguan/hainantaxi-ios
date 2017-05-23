//
//  CityMultTableViewCell.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

protocol CityMultTableViewCellDelegate: class {
    func multCityTableViewCell(_ cell: CityMultTableViewCell, didSelect city: ChinaCityZipable)
}

class CityMultTableViewCell: UITableViewCell, Reusable {
    
    static var defaultHeight: CGFloat = 60
    
    weak var delegate: CityMultTableViewCellDelegate?
    fileprivate let textLabels = (l: UIButton(), m: UIButton(), r: UIButton())
    fileprivate var dataModel: (l: ChinaCityZipable?, m: ChinaCityZipable?, r: ChinaCityZipable?)?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been imemented")
    }
    
    func shareInit() {
        let tw = R.Width.screen - 15
        let w = (tw - 14 * 4) / 3
        let style: (UIButton) -> Void = { btn in
            btn.setTitle("", for: .normal)
            btn.setTitleColor(Color.textDarkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.layer.borderColor = Color.bgLightGay.cgColor
            btn.layer.borderWidth = 1
            btn.backgroundColor = Color.white
        }
        style(textLabels.l)
        style(textLabels.m)
        style(textLabels.r)
        var rect = CGRect(x: 14, y: (CityMultTableViewCell.defaultHeight - 30) / 2, width: w, height: 30)
        textLabels.l.frame = rect
        rect.origin.x += w + 14
        textLabels.m.frame = rect
        rect.origin.x += w + 14
        textLabels.r.frame = rect
        
        contentView.addSubview(textLabels.l)
        contentView.addSubview(textLabels.m)
        contentView.addSubview(textLabels.r)
        
        textLabels.l.tag = 0
        textLabels.m.tag = 1
        textLabels.r.tag = 2
        
        
        textLabels.l.addTarget(self, action: #selector(CityMultTableViewCell.didSelectCity(_:)), for: .touchUpInside)
        textLabels.m.addTarget(self, action: #selector(CityMultTableViewCell.didSelectCity(_:)), for: .touchUpInside)
        textLabels.r.addTarget(self, action: #selector(CityMultTableViewCell.didSelectCity(_:)), for: .touchUpInside)
        
    }
    
    
    @objc fileprivate func didSelectCity(_ sender: UIButton) {
        var city: ChinaCityZipable? = nil
        switch sender.tag {
        case 0: city = dataModel?.l
        case 1: city = dataModel?.m
        case 2: city = dataModel?.r
        default: return
        }
        guard let c = city else {
            return
        }
        delegate?.multCityTableViewCell(self, didSelect: c)
    }
    
    func configureWithDataModel(_ dataModel: (l: ChinaCityZipable?, m: ChinaCityZipable?, r: ChinaCityZipable?)) {
        self.dataModel = dataModel
        textLabels.l.setTitle(dataModel.l?.name, for: .normal)
        textLabels.m.setTitle(dataModel.m?.name, for: .normal)
        textLabels.r.setTitle(dataModel.r?.name, for: .normal)
        textLabels.l.isHidden = dataModel.l == nil
        textLabels.m.isHidden = dataModel.m == nil
        textLabels.r.isHidden = dataModel.r == nil
        
    }
}


class CityTextTableViewCell: UITableViewCell, Reusable {
    
    static var defaultHeight: CGFloat = 60
    fileprivate let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shareInit() {
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.textColor = Color.textDarkGray
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(R.Margin.small)
            make.top.bottom.right.equalTo(contentView)
        }
    }
    
    
    func configureWithDataModel(_ dataModel: String) {
        nameLabel.text = dataModel
    }
    
}



class CityListSectionHeaderView: UITableViewHeaderFooterView, Reusable {
    
    let titleView = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = Color.textLightGray
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shareInit() {
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(R.Margin.large)
            make.top.right.bottom.equalTo(contentView)
        }
    }
}

