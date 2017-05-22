//
//  UserViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 17/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import HNTaxiKit

class UserViewController: UIViewController {
    
    struct Config {
        static let logOutSection  = 4
    }
    fileprivate let sectionTitle = [["帐号与安全"],
                           ["常用地址", "紧急联系人"],
                           ["用户指南", "给个好评"],
                           ["法律条款", "关于我们"],
                           ["退出登录"]]
    
    private let tableview = UITableView(frame: R.Rect.default, style: .grouped).then {
        $0.backgroundColor = Color.bgLightGay
        $0.sectionHeaderHeight = 1
//        $0.sectionFooterHeight = 10
        $0.rowHeight = 60
        $0.registerCell(BaseTitleTableViewCell.self)
        $0.tableFooterView = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func layoutViewController() {
        navigationItem.title = "已登录"
        view.backgroundColor = UIColor.white
        view.addSubview(tableview)
        
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    
    private func configureObservable() {
        
        
    }
}



extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Config.logOutSection {
            HTAuthManager.default.logout()
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaseTitleTableViewCell = tableView.dequeueReusableCell(indexPath)
        let title = sectionTitle[indexPath.section][indexPath.row]
        if indexPath.section == Config.logOutSection {
            cell.configureWithDataModel(title: title, isLogoutStyle: true)
        } else {
            cell.configureWithDataModel(title: title)
        }
        return cell
    }
}
