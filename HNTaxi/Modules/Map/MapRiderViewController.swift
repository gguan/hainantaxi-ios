//
//  MapRiderViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import HNTaxiKit
import RxCocoa
import RxSwift
import SVProgressHUD
import CocoaMQTT


class MapRiderViewController: UIViewController {
    // MAR: Flag
    fileprivate var isInitial = true
    
    // MARK: - ViewModel
    fileprivate let viewModel = MapRiderViewModel(dependence: SVProgressHUDManager())
    fileprivate let disposeQueue = DisposeQueue()

    // MARK: - Map
    fileprivate var pathPolyline: MAPolyline?
    fileprivate var carAnnotation = [String: MovingAnnotation]()
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
    fileprivate let centerBubbleView = TextBubbleView(frame: CGRect(width: 160, height: 40))
    fileprivate let centerSelectPoint = UIImageView(image: R.image.map_select_point())
    
    fileprivate let locationSelectView = LocationSelectView()
    fileprivate let myLocationButton = UIButton(image: R.image.map_switch_to_location())
    fileprivate let pricePopupCard = PricePopupCard()
    
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
        view.addSubview(centerSelectPoint)
        view.addSubview(centerBubbleView)
        view.addSubview(myLocationButton)
        view.addSubview(locationSelectView)
        view.addSubview(pricePopupCard)
        
        
        mapView.delegate = self
        mapView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(view)
        }
        centerSelectPoint.contentMode = .scaleAspectFit
        centerSelectPoint.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerY.equalTo(view.snp.centerY).offset(-R.Height.fullNavigationBar/2 + 15)
            make.centerX.equalTo(view)
        }
        centerBubbleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(centerSelectPoint)
            make.bottom.equalTo(centerSelectPoint.snp.top).offset(-4)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        myLocationButton.snp.makeConstraints { (make) in
            make.size.equalTo(30)
            make.left.equalTo(view).offset(R.Margin.large)
            make.bottom.equalTo(view.snp.bottom).offset(-140)
        }
        
        locationSelectView.frame = CGRect(x: R.Margin.large - 5,
                                      y: R.Margin.large,
                                      width: R.Width.screen - R.Margin.large * 2 + 10,
                                      height: 100)
        
        let w = centerBubbleView.setText("在这打人")
        centerBubbleView.snp.updateConstraints { (make) in
            make.width.equalTo(w)
        }
        
        pricePopupCard.configureWithDataModel((distance: "100", price: "100"))
    }
    
    
    private func configureObservable() {
        // 跳转至我的位置
        myLocationButton.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                guard let loc = self.mapView.userLocation?.coordinate else { return }
                self.mapView.setCenter(loc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "SwitchToMyLocation")
        
        // 选择目的地
        locationSelectView.buttons.destination.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                guard !self.viewModel.orderLocation.value.isVaild else { return }
                self.showSearchViewController()
            })
            .addDisposableTo(disposeQueue, key: "destination")
        
        // 用户信息按钮
        userItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                let vc = HTAuthManager.default.isAuth ? UserViewController() : MainAuthViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "userItem")
       
        // 消息按钮
        msgItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                let vc = MessageViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "msgItem")
        
        // 取消目的地
        backItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.orderLocation.value.to = nil
                self.navigationItem.leftBarButtonItem = self.userItem
                self.locationSelectView.buttons.destination.title = "选择目的地"
            })
            .addDisposableTo(disposeQueue, key: "backItem")
    
        // 订单预览
        viewModel.orderPreview.asObservable()
            .subscribe(onNext: {[weak self] (req: HTReuqestOrder?, res: HTOrderPreview?) in
                self?.changeDisplayPath(travelRequest: req, travelRespone: res)
            })
            .addDisposableTo(disposeQueue, key: "TravelPathChange")
        
        
        // 起始点目的地选择状态
        viewModel.orderLocation.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (loc: OrderSelectLocation) in
                self?.locationSelectView.buttons.from.title = loc.from?.name
                self?.changeCenterDisplayStatus(isShow: !loc.isVaild)
            })
            .addDisposableTo(disposeQueue, key: "orderLocation")
        
        
        // 附近司机位置
        viewModel.drivers.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (drivers: [DriverLocation]) in
                self?.updateDriverAnnotation(drivers: drivers)
            })
            .addDisposableTo(disposeQueue, key: "driverLocation")
    }
    
    // 更新 UI操作
    private func changeCenterDisplayStatus(isShow: Bool) {
        if !isShow {
            centerBubbleView.isHidden = true
            centerSelectPoint.isHidden = true
        } else {
            if !centerBubbleView.isHidden { return }
            centerBubbleView.alpha = 0
            centerSelectPoint.alpha = 0
            centerBubbleView.isHidden = false
            centerSelectPoint.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.centerBubbleView.alpha = 1
                self.centerSelectPoint.alpha = 1
            })
        }
    }
    
    private func changeDisplayPath(travelRequest: HTReuqestOrder?, travelRespone: HTOrderProtocol?){
        func removeOldAnnotation() {
            if let start = annotation.start  {
                mapView.removeAnnotation(start)
                annotation.start = nil
            }
            if let end = annotation.end {
                mapView.removeAnnotation(end)
                annotation.end = nil
            }
        }
        if let line = pathPolyline {
            pathPolyline = nil
            mapView.remove(line)
        }
        if let path = travelRequest, let res = travelRespone {
            // 显示价格框
            do {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.pricePopupCard.frame.origin.y = PricePopupCard.Layout.showY
                    self.locationSelectView.frame.origin.y = -200
                }, completion: nil)
                let dis = String(format: "%.1f", Double(res.distance ?? 0)/1000.0)
                let price = String(format: "%.2f", res.estimatePrice ?? 0)
                pricePopupCard.configureWithDataModel((distance: dis, price: price))
            }
            
            navigationItem.leftBarButtonItem = backItem
            removeOldAnnotation()
            if let start = path.from?.coordinate,
                let end = path.to?.coordinate {
                let startPoint = MAPointAnnotation()
                startPoint.coordinate = start
                startPoint.title = AnnotationIden.PointType.start
                mapView.addAnnotation(startPoint)
                let endPoint = MAPointAnnotation()
                endPoint.coordinate = end
                endPoint.title = AnnotationIden.PointType.end
                mapView.addAnnotation(endPoint)
                mapView.showAnnotations([startPoint, endPoint], edgePadding: UIEdgeInsets(top: 500, left: 100, bottom: 500, right: 100), animated: true)
                annotation = (startPoint, endPoint, nil)
            }
            
        } else {
            if pricePopupCard.frame.origin.y.isEqual(to: PricePopupCard.Layout.showY) {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.pricePopupCard.frame.origin.y = PricePopupCard.Layout.hideY
                    self.locationSelectView.frame.origin.y = R.Margin.large                   
                }, completion: nil)
            }
            viewModel.currentPosition.value = mapView.centerCoordinate
            removeOldAnnotation()
        }
    }
    
    
    private func updateDriverAnnotation(drivers: [DriverLocation]) {
        let current = drivers.flatMap({ $0.data.id })
        var currentAnnotations = carAnnotation
        var removeAnnotations = [MovingAnnotation]()
        var activeAnnotations = [String: MovingAnnotation]()
        for k in currentAnnotations.keys {
            guard let an = carAnnotation[k] else { continue }
            if !current.contains(k) {
                removeAnnotations.append(an)
                currentAnnotations.removeValue(forKey: k)
            } else {
                activeAnnotations[k] = an
            }
        }
        let activeKeys = activeAnnotations.keys
        self.mapView.removeAnnotations(removeAnnotations)
        for d in drivers {
            guard let id = d.data.id else { return }
            if activeKeys.contains(id) {
                guard let an = activeAnnotations[id], let p = d.data.locations else { continue }
                var loc = [p]
                an.addMoveAnimation(withKeyCoordinates: &loc, count: 1, withDuration: 2, withName: nil, completeCallback: nil)
            } else if let an = MapElementRender.driverPoint(coordinate: d.data.locations, iden: id) {
                currentAnnotations[id] = an
                mapView.addAnnotation(an)
            }
        }
        carAnnotation = currentAnnotations

    }
    
    private func showSearchViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.locationSelectView.frame.origin.y = -200
        }, completion: nil)
        let vc = MapSearchViewController(canShowHeader: true)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension MapRiderViewController: MapSearchViewControllerDelegate {
    func mapSearchViewController(didDismiss vc: MapSearchViewController) {
        self.locationSelectView.frame.origin.y = R.Margin.large
    }
    
    func mapSearchViewController(didSelect vc: MapSearchViewController, data: HTLocation) {
        locationSelectView.buttons.destination.title = data.name
        viewModel.orderLocation.value.to = data
    }
}


extension MapRiderViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if viewModel.didSelectStartAndEndLocation { return }
        viewModel.currentPosition.value = mapView.centerCoordinate
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if isInitial, let loc = userLocation?.coordinate {
            mapView.setZoomLevel(17, animated: true)
            mapView.setCenter(loc, animated: true)
            isInitial = false
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        return MapElementRender.polyline(mapView, rendererFor: overlay)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
       return MapElementRender.dequeue(mapView, viewFor: annotation)
    }
}
