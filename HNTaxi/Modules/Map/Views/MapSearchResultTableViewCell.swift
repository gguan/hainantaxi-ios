//
//  MapSearchResultTableViewCell.swift
//  HNTaxi
//
//  Created by Tbxark on 16/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit



class MapSearchResultHeaderView: UITableViewHeaderFooterView, Reusable {
    
    private class Cell: UIView {
        let typeImage = UIImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        let nameLabel = UILabel().then {
            $0.font = UIFont.boldSystemFont(ofSize: 14)
            $0.textColor = UIColor.darkGray
            $0.textAlignment = .left
        }
        let addressLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = UIColor.gray
            $0.textAlignment = .left
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            shareInit()
        }
        
        init() {
            super.init(frame: CGRect.zero)
            shareInit()
        }

        
        func shareInit() {
            addSubview(typeImage)
            addSubview(nameLabel)
            addSubview(addressLabel)
            
            typeImage.snp.makeConstraints { (make) in
                make.left.equalTo(self).offset(R.Margin.large)
                make.size.equalTo(20)
                make.centerY.equalTo(self)
            }
            nameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self).offset(R.Margin.small)
                make.bottom.equalTo(self.snp.centerY)
                make.left.equalTo(typeImage.snp.right).offset(R.Margin.large)
                make.right.equalTo(self).offset(-R.Margin.large)
            }
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(self).offset(-R.Margin.small)
                make.top.equalTo(self.snp.centerY)
                make.left.equalTo(typeImage.snp.right).offset(R.Margin.large)
                make.right.equalTo(self).offset(-R.Margin.large)
            }
        }
    }
    
    
    private let leftView = Cell()
    private let rightView = Cell()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }

    
    func shareInit() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(leftView)
        contentView.addSubview(rightView)
        
        leftView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(contentView)
            make.right.equalTo(contentView.snp.centerX)
        }
        rightView.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(contentView)
            make.left.equalTo(contentView.snp.centerX)
        }
        
    }
    
    func configureWithDataModel( left: (title: String, address: String), right: (title: String, address: String)) {
        leftView.typeImage.image = R.image.map_pio_location()
        leftView.nameLabel.text = left.title
        leftView.addressLabel.text = left.address
        
        rightView.typeImage.image =  R.image.map_pio_location()
        rightView.nameLabel.text = right.title
        rightView.addressLabel.text = right.address
    }
    
}


class MapSearchResultTableViewCell: UITableViewCell, Reusable {

    
    fileprivate let typeImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.darkGray
        $0.textAlignment = .left
    }
    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.gray
        $0.textAlignment = .left
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }

    func shareInit() {
        contentView.addSubview(typeImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
        
        typeImage.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(R.Margin.large)
            make.size.equalTo(20)
            make.centerY.equalTo(contentView)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(R.Margin.small)
            make.bottom.equalTo(contentView.snp.centerY)
            make.left.equalTo(typeImage.snp.right).offset(R.Margin.large)
            make.right.equalTo(contentView).offset(-R.Margin.large)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView).offset(-R.Margin.small)
            make.top.equalTo(contentView.snp.centerY)
            make.left.equalTo(typeImage.snp.right).offset(R.Margin.large)
            make.right.equalTo(contentView).offset(-R.Margin.large)
        }
    }
    
    func configureWithDataModel(_ dataModel: (name: String, address: String)) {
        typeImage.image = R.image.map_pio_location()
        nameLabel.text = dataModel.name
        addressLabel.text = dataModel.address
    }

}
