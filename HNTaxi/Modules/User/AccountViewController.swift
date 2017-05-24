//
//  AccountViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    fileprivate(set) var sectionData: [[(String, String?)]] = [ [("更换手机号码", "")],
                                                            [("密码设置", nil), ("绑定第三方", nil)]
                                                          ]
    private let tableview = UITableView(frame: R.Rect.default, style: .grouped).then {
        $0.setDefaultStyle()
        $0.registerCell(BaseTitleTableViewCell.self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func layoutViewController() {
        view.backgroundColor = UIColor.white
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        navigationItem.title = "帐号与安全"
    }
    
    
    private func configureObservable() {
        
        
    }
}


extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaseTitleTableViewCell = tableView.dequeueReusableCell(indexPath)
        let data = sectionData[indexPath.section][indexPath.row]
        cell.configureWithDataModel(title: data.0, subTitle: data.1, isLogoutStyle: false)
        return cell
    }
    
}
