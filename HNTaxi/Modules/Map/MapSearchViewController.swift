//
//  MapSearchViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 16/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HNTaxiKit
import SVProgressHUD


protocol MapSearchViewControllerDelegate: class {
    func mapSearchViewController(didDismiss vc: MapSearchViewController)
    func mapSearchViewController(didSelect vc: MapSearchViewController, data: HTLocation)
}

class MapSearchViewController: UIViewController {
    fileprivate let currentCity = Variable<String>("北京")
    weak var delegate: MapSearchViewControllerDelegate?
    fileprivate let searchBar =  MapSearchBar()
    fileprivate let disposeQueue = DisposeQueue()
    fileprivate var poiData = [HTLocation]() {
        didSet {
            poiList.reloadData()
        }
    }
    fileprivate let poiList = UITableView().then {
        $0.registerCell(MapSearchResultTableViewCell.self)
        $0.tableFooterView = UIView()
        $0.rowHeight = 70
        $0.backgroundColor = UIColor.white
        $0.separatorColor = UIColor.lightGray
        $0.keyboardDismissMode = .onDrag
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
        seachPOI(city: currentCity.value, keyword: currentCity.value) 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func layoutViewController() {
        let container = UIView(frame: CGRect(width: R.Width.screen, height: R.Height.fullNavigationBar))
        container.backgroundColor = UIColor.white
        view.addSubview(container)
        container.addSubview(searchBar)
        view.addSubview(poiList)
        poiList.delegate = self
        poiList.dataSource = self
        poiList.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).offset(R.Margin.medium)
            make.bottom.equalTo(view)
            make.right.equalTo(view).offset(-R.Margin.medium)
            make.left.equalTo(view).offset(R.Margin.medium)
        }
        
    }
    
    
    private func configureObservable() {
        searchBar.cancleButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else { return }
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.mapSearchViewController(didDismiss: self)
                })
            .addDisposableTo(disposeQueue, key: "CancleButton")
        
        let search = searchBar.searchTextfield.rx.text
            .throttle(1, latest: true, scheduler: MainScheduler.asyncInstance)
            
        Observable.combineLatest(search, currentCity.asObservable(), resultSelector: { k, c  in (k, c)})
            .subscribe(onNext: {[weak self] (keyword, city) in
                self?.seachPOI(city: city, keyword: keyword ?? city)
            })
            .addDisposableTo(disposeQueue, key: "SearchChange")
    }
    
    
    fileprivate func seachPOI(city: String, keyword: String) {
        MapSearchManager.searchPOIKeywords(city: city, keywords: keyword)
            .subscribe(onNext: {[weak self] (value: [HTLocation]) in
                self?.poiData = value
                }, onError: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription ?? "")
            })
            .addDisposableTo(disposeQueue, key: "SearchPOIKeywords")
    
    }
    
}


extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = poiData[indexPath.row]
        delegate?.mapSearchViewController(didSelect: self, data: data)
        dismiss(animated: true, completion: nil)
        _ = searchBar.searchTextfield.resignFirstResponder()
        delegate?.mapSearchViewController(didDismiss: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MapSearchResultTableViewCell = tableView.dequeueReusableCell(indexPath)
        let data = poiData[indexPath.row]
        cell.configureWithDataModel((data.name ?? "" , data.address ?? ""))
        return cell
    }

}
