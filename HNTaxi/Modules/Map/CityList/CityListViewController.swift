//
//  CityListViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 23/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

protocol CityListDelegate: class {
    func cityList(_ vc: CityListViewController, didSelect city: ChinaCityZipable)
}


class CityListViewController: UIViewController {
    
    fileprivate lazy var dataArray: SortDictionary<String, [ChinaCityZipable]> = CityDataManager.localAddressList().toGroup()
    fileprivate let searchBar = UISearchBar()
    
    fileprivate lazy var cityView: UITableView = {
        let tableView = UITableView(frame: R.Rect.default)
        tableView.registerCell(CityTextTableViewCell.self)
        tableView.registerCell(CityMultTableViewCell.self)
        tableView.registerHeaderFooter(CityListSectionHeaderView.self)
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = 24
        tableView.rowHeight = CityTextTableViewCell.defaultHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = Color.bgLightGay
        tableView.sectionIndexColor = Color.textLightGray
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.white
        return tableView
    }()
    
    weak var delegate: CityListDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择城市"
        layoutViewController()
    }
    
    private func layoutViewController() {
        view.addSubview(cityView)
        _ = addCloseBarButtonItem()
    }

    
}

extension CityListViewController: CityMultTableViewCellDelegate {
    
    
    func multCityTableViewCell(_ cell: CityMultTableViewCell, didSelect city: ChinaCityZipable) {
        delegate?.cityList(self, didSelect: city)
    }
}


fileprivate let kSpecialKeys = ["*", "#"]

extension CityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataArray.allKeys
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.allKeys.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: CityListSectionHeaderView = tableView.dequeueReusableHeaderFooter()
        let str = dataArray.allKeys[section]
        header.titleView.text = kSpecialKeys.contains(str) ? "热门城市" : str
        return header
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let str = dataArray.allKeys[section]
        let count = dataArray[section].value.count
        if kSpecialKeys.contains(str) {
            return count / 3 + (count % 3 > 0 ? 1 : 0)
        } else {
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = dataArray.allKeys[indexPath.section]
        if !kSpecialKeys.contains(str) {
            let model = dataArray[indexPath.section].value[indexPath.row]
            delegate?.cityList(self, didSelect: model)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str = dataArray.allKeys[indexPath.section]
        if kSpecialKeys.contains(str) {
            let cell: CityMultTableViewCell = tableView.dequeueReusableCell(indexPath)
            cell.delegate = self
            let data = dataArray[indexPath.section].value
            let i = indexPath.row * 3
            let c = data.count
            var dataModel: (l: ChinaCityZipable?, m: ChinaCityZipable?, r: ChinaCityZipable?) = (nil, nil, nil)
            if i < c {
                dataModel.l = data[i]
            }
            if i + 1 < c {
                dataModel.m = data[i + 1]
            }
            if i + 2 < c {
                dataModel.r = data[i + 2]
            }
            cell.configureWithDataModel(dataModel)
            return cell
        } else {
            let cell: CityTextTableViewCell = tableView.dequeueReusableCell(indexPath)
            let model = dataArray[indexPath.section].value[indexPath.row]
            cell.configureWithDataModel(model.name)
            return cell
        }
        
    }
    
}
