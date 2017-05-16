//
//  MapViewController.swift
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

class MapViewController: UIViewController {
    // MAR: Flag
    fileprivate var isInitial = true
    fileprivate var showPath = true
    fileprivate var showSeletView: Bool {
        get {
            return !selectBubbleView.isHidden
        }
        set {
            selectBubbleView.isHidden = !newValue
            selectPoint.isHidden = !newValue
        }
    }

    // MARK: - Data
    fileprivate let disposeQueue = DisposeQueue()
    fileprivate let orderLocation = Variable<(from: Coordinate2D?, to: Coordinate2D?)>.init((from: nil, to: nil))
    fileprivate var displayPath: HTPath? {
        didSet {
            if let line = polyline {
                polyline = nil
                mapView.remove(line)
            }
            if let path = displayPath {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.priceCard.frame.origin.y = PricePopupCard.Layout.showY
                }, completion: nil)
                let dis = String(format: "%.1f", Double(path.distance ?? 0)/1000.0)
                let price = String(format: "%.2f", path.tolls ?? 0)
                priceCard.configureWithDataModel((distance: dis, price: price))
                navigationItem.leftBarButtonItem = backItem
                if showPath, var coordinates = path.lineCoordinates {
                    let line: MAPolyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                    polyline = line
                    mapView.add(polyline)
                }
                showSeletView = false
            } else {
                showSeletView = true
                if priceCard.frame.origin.y.isEqual(to: PricePopupCard.Layout.showY) {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        self.priceCard.frame.origin.y = PricePopupCard.Layout.hideY
                    }, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Map
    fileprivate var polyline: MAPolyline?
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
    fileprivate let selectBubbleView = TextBubbleView(frame: CGRect(width: 160, height: 40))
    fileprivate let selectPoint = UIImageView(image: R.image.map_select_point())
    
    fileprivate let switchToMyLocation = UIButton(image: R.image.map_switch_to_location())
    fileprivate let selectLocation = LocationSelectView()
    fileprivate let priceCard = PricePopupCard()
    
    fileprivate let userItem = UIBarButtonItem(image: R.image.icon_user()?.resize(maxHeight: 16),
                                               style: .plain, target: nil, action: nil)
    fileprivate let msgItem = UIBarButtonItem(image: R.image.icon_message()?.resize(maxHeight: 16),
                                              style: .plain, target: nil, action: nil)
    
    fileprivate let backItem = UIBarButtonItem(image: R.image.icon_arrow_left()?.resize(maxHeight: 16),
                                              style: .plain, target: nil, action: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
        
    }
    
    private func layoutViewController() {
        navigationItem.titleView = UIImageView(image: R.image.title_label())
        navigationItem.leftBarButtonItem = userItem
        navigationItem.rightBarButtonItem = msgItem
        
        AMapServices.shared().enableHTTPS = true
        
        view.addSubview(mapView)
        view.addSubview(selectPoint)
        view.addSubview(selectBubbleView)
        view.addSubview(switchToMyLocation)
        view.addSubview(selectLocation)
        view.addSubview(priceCard)
        
        mapView.delegate = self
        mapView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(view)
        }
        selectPoint.contentMode = .scaleAspectFit
        selectPoint.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerY.equalTo(view.snp.centerY).offset(-R.Height.fullNavigationBar/2 + 15)
            make.centerX.equalTo(view)
        }
        selectBubbleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(selectPoint)
            make.bottom.equalTo(selectPoint.snp.top).offset(-4)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        switchToMyLocation.snp.makeConstraints { (make) in
            make.size.equalTo(30)
            make.left.equalTo(view).offset(R.Margin.large)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        
        selectLocation.frame = CGRect(x: R.Margin.large - 5,
                                      y: R.Margin.large,
                                      width: R.Width.screen - R.Margin.large * 2 + 10,
                                      height: 100)
        
        let w = selectBubbleView.setText("在这打人")
        selectBubbleView.snp.updateConstraints { (make) in
            make.width.equalTo(w)
        }
        
        priceCard.configureWithDataModel((distance: "100", price: "100"))

    }
    
    
    private func configureObservable() {
        switchToMyLocation.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                guard let loc = self.mapView.userLocation?.coordinate else { return }
                self.mapView.setCenter(loc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "SwitchToMyLocation")
        
        selectLocation.buttons.destination.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showSearchViewController()
            })
            .addDisposableTo(disposeQueue, key: "destination")
        
        backItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.orderLocation.value.to = nil
                self.navigationItem.leftBarButtonItem = self.userItem
                self.selectLocation.buttons.destination.title = "选择目的地"
            })
            .addDisposableTo(disposeQueue, key: "backItem")
    
        orderLocation.asObservable()
            .subscribe(onNext: {[weak self]  coordinate in
                guard let `self` = self else { return }
                self.changePriceStatus(coordinate: coordinate)
            })
            .addDisposableTo(disposeQueue, key: "orderLocation")
        
    
    }
    
    
    private func changePriceStatus(coordinate: (from: Coordinate2D?, to: Coordinate2D?)) {
        guard let f = coordinate.from, let t = coordinate.to  else {
            self.displayPath = nil
            return
        }
        SVProgressHUD.show()
        MapSearchManager.searchPathInfo(from: f, to: t)
            .subscribe(onNext: {[weak self] (path: HTPath) in
                guard let `self` = self else { return }
                self.displayPath = path
                SVProgressHUD.dismiss()
            }, onError: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription ?? "Error")
                print(error)
            })
            .addDisposableTo(disposeQueue, key: "ReuqestPath")
    }
    
    
    private func showSearchViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.selectLocation.frame.origin.y = -200
        }, completion: nil)
        let vc = MapSearchViewController()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension MapViewController: MapSearchViewControllerDelegate {
    func mapSearchViewController(didDismiss vc: MapSearchViewController) {
        self.selectLocation.frame.origin.y = R.Margin.large
    }
    
    func mapSearchViewController(didSelect vc: MapSearchViewController, data: HTLocation) {
        selectLocation.buttons.destination.title = data.name
        orderLocation.value.to = data.coordinate
    }
}


extension MapViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if orderLocation.value.to != nil && orderLocation.value.from != nil { return }
        orderLocation.value.from = mapView.centerCoordinate
        MapSearchManager.searchReGeocode(coordinate:  mapView.centerCoordinate)
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (location: HTLocation) in
                guard let `self` = self else { return }
                self.selectLocation.buttons.from.title = location.name
            }, onError: { (error: Error) in
                print(error)
            })
            .addDisposableTo(disposeQueue, key: "ReGeocode")
        
    }
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if isInitial, let loc = userLocation?.coordinate {
            mapView.setZoomLevel(17, animated: true)
            mapView.setCenter(loc, animated: true)
            isInitial = false
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = Color.blue
            
            return renderer
        }
        return nil
    }
}
