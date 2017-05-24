//
//  AddressBookViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 24/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import HNTaxiKit
import RxSwift
import SVProgressHUD



class AddressBookViewController: UIViewController {

    enum AddressType: Int {
        case home = 0
        case company
        static func totalCount() -> Int {
            return 2
        }
        func toIden() -> String {
            switch self {
            case .home: return "home"
            case .company: return "company"
            }
        }
        func toI18n() -> String {
            switch self {
            case .home: return "家庭"
            case .company: return "公司地址"
            }
        }
    }
    
    
    
    fileprivate let viewModel = AddressViewModel()
    fileprivate var currentSelectType: AddressType?
    fileprivate let disposeQueue = DisposeQueue()
    
    private let tableview = UITableView(frame: R.Rect.default, style: .grouped).then {
        $0.registerCell(MapSearchResultTableViewCell.self)
        $0.setDefaultStyle()
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
        navigationItem.title = "地址簿"
        view.backgroundColor = UIColor.white
        view.addSubview(tableview)
        
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    private func configureObservable() {
    }
}


extension AddressBookViewController: MapSearchViewControllerDelegate {
    func mapSearchViewController(didDismiss vc: MapSearchViewController) {
        
    }
    
    func mapSearchViewController(didSelect vc: MapSearchViewController, data: HTLocation) {
        guard let type = currentSelectType?.toIden() else { return }
        viewModel.setAddress(type: type, address: HTAddress())
            .subscribe(onNext: { _ in
                SVProgressHUD.show(withStatus: "设置成功")
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "设置失败")
                })
            .addDisposableTo(disposeQueue, key: "ChangeAddress")
    }
}



extension AddressBookViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddressType.totalCount()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MapSearchViewController()
        vc.delegate = self
        currentSelectType  = AddressType(rawValue: indexPath.row)
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MapSearchResultTableViewCell = tableView.dequeueReusableCell(indexPath)
        let title = AddressType(rawValue: indexPath.row)!.toI18n()
        cell.configureWithDataModel((name: title, address: "设置地址"))
        return cell
    }
}
