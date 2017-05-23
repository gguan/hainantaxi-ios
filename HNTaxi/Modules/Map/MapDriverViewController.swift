//
//  MapDriverViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import HNTaxiKit
import RxCocoa
import RxSwift
import SVProgressHUD
import CocoaMQTT

class MapDriderViewController: UIViewController {
    
    // MARK: - ViewModel
    fileprivate let viewModel = MapDriverViewModel()
    fileprivate let disposeQueue = DisposeQueue()

    
    // MARK: - Map
    fileprivate var pathPolyline: MAPolyline?
    fileprivate var annotation: (start: MAPointAnnotation?, end: MAPointAnnotation?, driver: MovingAnnotation?) = (nil, nil, nil)
    fileprivate let mapView = MAMapView(frame: R.Rect.default).then {
        $0.showsCompass = false
        $0.isShowsIndoorMap = false
        $0.isRotateEnabled = false
        $0.showsScale = false
        $0.showsUserLocation = true
        $0.userTrackingMode = .follow
        $0.customizeUserLocationAccuracyCircleRepresentation = true
        let r = MAUserLocationRepresentation()
        r.image = R.image.map_mine_location()
        $0.update(r)
        if let url = R.file.style_jsonJson(),
            let data = NSData(contentsOf: url) {
            $0.setCustomMapStyle(data as Data)
        }
    }
    
    
    // MARK: - Control
    fileprivate let myLocationButton = UIButton(image: R.image.map_switch_to_location())
    
    fileprivate let userItem = UIBarButtonItem(image: R.image.icon_user()?.resizeToNavigationItem(),
                                               style: .plain, target: nil, action: nil)
    fileprivate let msgItem = UIBarButtonItem(image: R.image.icon_message()?.resizeToNavigationItem(),
                                              style: .plain, target: nil, action: nil)
    
    fileprivate let backItem = UIBarButtonItem(image: R.image.icon_arrow_left()?.resizeToNavigationItem(),
                                               style: .plain, target: nil, action: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for v in mapView.subviews {
            if let imgv = v as? UIImageView,
                imgv.frame.size.width.isEqual(to: 55),
                imgv.frame.size.height.isEqual(to: 13),
                imgv.frame.origin.x.isEqual(to: 5) {
                UIView.animate(withDuration: 1, animations: {
                    imgv.alpha = 0
                })
            }
        }
    }
    
    private func layoutViewController() {
        navigationItem.title = "主页"
        navigationItem.titleView = UIImageView(image: R.image.title_label())
        navigationItem.leftBarButtonItem = userItem
        navigationItem.rightBarButtonItem = msgItem
        
        AMapServices.shared().enableHTTPS = true
        
        view.addSubview(mapView)
        view.addSubview(myLocationButton)
        
        
        mapView.delegate = self
        mapView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(view)
        }
        myLocationButton.snp.makeConstraints { (make) in
            make.size.equalTo(30)
            make.left.equalTo(view).offset(R.Margin.large)
            make.bottom.equalTo(view.snp.bottom).offset(-140)
        }
        
    }
    
    
    private func configureObservable() {
    
    }
    

}



extension MapDriderViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        viewModel.currentPosition.value = userLocation?.coordinate
    }
}
