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
    fileprivate var canShowPath = true
    fileprivate var isShowCenterView: Bool {
        get {
            return !centerBubbleView.isHidden
        }
        set {
            centerBubbleView.isHidden = !newValue
            centerSelectPoint.isHidden = !newValue
        }
    }
    fileprivate var annotation: (start: MAPointAnnotation?, end: MAPointAnnotation?) = (nil, nil)

    // MARK: - Data
    fileprivate let disposeQueue = DisposeQueue()
    fileprivate let orderLocation = Variable<(from: Coordinate2D?, to: Coordinate2D?)>.init((from: nil, to: nil))
    fileprivate var travelPath: HTPath? {
        didSet {
            if let line = pathPolyline {
                pathPolyline = nil
                mapView.remove(line)
            }
            if let path = travelPath {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.pricePopupCard.frame.origin.y = PricePopupCard.Layout.showY
                }, completion: nil)
                let dis = String(format: "%.1f", Double(path.distance ?? 0)/1000.0)
                let price = String(format: "%.2f", path.tolls ?? 0)
                pricePopupCard.configureWithDataModel((distance: dis, price: price))
                navigationItem.leftBarButtonItem = backItem
                if canShowPath, var coordinates = path.lineCoordinates {
                    let line: MAPolyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                    pathPolyline = line
                    mapView.add(pathPolyline)
                }
//                let test = path.lineCoordinates?.map({ c in "{log: \(c.longitude.description), lat: \(c.latitude.description)},"}).reduce("", +)
//                print(test ?? "")
                if let start = path.lineCoordinates?.first,
                    let end = path.lineCoordinates?.last {
                    let startPoint = MAPointAnnotation()
                    startPoint.coordinate = start
                    startPoint.title = AnnotationIden.PointType.start
                    mapView.addAnnotation(startPoint)
                    let endPoint = MAPointAnnotation()
                    endPoint.coordinate = end
                    endPoint.title = AnnotationIden.PointType.end
                    mapView.addAnnotation(endPoint)
                    annotation = (startPoint, endPoint)
                }
                isShowCenterView = false
            } else {
                isShowCenterView = true
                if pricePopupCard.frame.origin.y.isEqual(to: PricePopupCard.Layout.showY) {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        self.pricePopupCard.frame.origin.y = PricePopupCard.Layout.hideY
                    }, completion: nil)
                }
                if let start = annotation.start  {
                    mapView.removeAnnotation(start)
                    annotation.start = nil
                }
                if let end = annotation.end {
                    mapView.removeAnnotation(end)
                    annotation.end = nil
                }
            }
        }
    }
    
    // MARK: - Map
    fileprivate var pathPolyline: MAPolyline?
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
        DriverManagerService.shared.start()
        
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
        myLocationButton.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                guard let loc = self.mapView.userLocation?.coordinate else { return }
                self.mapView.setCenter(loc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "SwitchToMyLocation")
        
        locationSelectView.buttons.destination.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showSearchViewController()
            })
            .addDisposableTo(disposeQueue, key: "destination")
        
        userItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                let vc = HTAuthManager.default.isAuth ? UserViewController() : MainAuthViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .addDisposableTo(disposeQueue, key: "userItem")
        backItem.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.orderLocation.value.to = nil
                self.navigationItem.leftBarButtonItem = self.userItem
                self.locationSelectView.buttons.destination.title = "选择目的地"
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
            self.travelPath = nil
            return
        }
        SVProgressHUD.show()
        MapSearchManager.searchPathInfo(from: f, to: t)
            .subscribe(onNext: {[weak self] (path: HTPath) in
                guard let `self` = self else { return }
                self.travelPath = path
                SVProgressHUD.dismiss()
            }, onError: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription ?? "Error")
                print(error)
            })
            .addDisposableTo(disposeQueue, key: "ReuqestPath")
    }
    
    
    private func showSearchViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.locationSelectView.frame.origin.y = -200
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
        self.locationSelectView.frame.origin.y = R.Margin.large
    }
    
    func mapSearchViewController(didSelect vc: MapSearchViewController, data: HTLocation) {
        locationSelectView.buttons.destination.title = data.name
        orderLocation.value.to = data.coordinate
    }
}



private struct AnnotationIden {
    struct ReuseIndetifier {
        static let user =  "UserLocationReuseIndetifier"
    }
    struct PointType {
        static let start = "start"
        static let end   = "end"
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
                self.locationSelectView.buttons.from.title = location.name
            }, onError: { (error: Error) in
                print(error)
            })
            .addDisposableTo(disposeQueue, key: "ReGeocode")
        if let point =  mapView?.centerCoordinate {
            DriverManagerService.shared.updateSelectLocation(point)
        }

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
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        guard let mapView = mapView, let annotation = annotation else { return nil }
        if let user = annotation as? MAPointAnnotation, let iden = user.title {
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIden.ReuseIndetifier.user)
            if annotationView == nil {
                annotationView = MAAnnotationView.init(annotation: user, reuseIdentifier: AnnotationIden.ReuseIndetifier.user)
            }
            switch iden {
            case AnnotationIden.PointType.start:
                annotationView?.image = R.image.map_start_point()
            case AnnotationIden.PointType.end:
                annotationView?.image = R.image.map_end_point()
            default:
                return nil
            }
            annotationView?.canShowCallout = false
            annotationView?.centerOffset = CGPoint(x: 0, y: -15)
            return annotationView
            
        }
        return nil
    }
}
