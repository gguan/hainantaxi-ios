//
//  MapElementRender.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import CoreLocation


struct AnnotationIden {
    struct ReuseIndetifier {
        static let user =  "UserLocationReuseIndetifier"
        static let car  = "CarLocationReuseIndetifier"
    }
    struct PointType {
        static let start = "start"
        static let end   = "end"
    }
}


struct MapElementRender {
    static func startPoint(coordinate: CLLocationCoordinate2D?) -> MAPointAnnotation? {
        guard let c = coordinate else { return nil }
        let startPoint = MAPointAnnotation()
        startPoint.coordinate = c
        startPoint.title = AnnotationIden.PointType.start
        return startPoint
    }
    
    static func endPoint(coordinate: CLLocationCoordinate2D?) -> MAPointAnnotation?{
        guard let c = coordinate else { return nil }
        let endPoint = MAPointAnnotation()
        endPoint.coordinate = c
        endPoint.title = AnnotationIden.PointType.end
        return endPoint
    }
    
    static func driverPoint(coordinate: CLLocationCoordinate2D?, iden: String?, type: String?) -> MovingAnnotation? {
        guard let c = coordinate, let i = iden, let t = type else { return nil }
        let point = MovingAnnotation()
        point.coordinate = c
        point.title = i
        point.subtitle = t
        return point
    }
    
    static func dequeue(_ mapView: MAMapView?, viewFor annotation: MAAnnotation?) -> MAAnnotationView? {
        return dequeueStartOrEndPoint(mapView, viewFor: annotation) ?? dequeueDriverPoint( mapView,viewFor: annotation)
    }
    
    static func polyline(_ mapView: MAMapView?, rendererFor overlay: MAOverlay?) -> MAOverlayRenderer? {
        if overlay?.isKind(of: MAPolyline.self) ?? false  {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = Color.blue
            return renderer
        }
        return nil
    }
    
    static func dequeueStartOrEndPoint(_ mapView: MAMapView?, viewFor annotation: MAAnnotation?) -> MAAnnotationView? {
        guard let mapView = mapView, let annotation = annotation else { return nil }
        if let user = annotation as? MAPointAnnotation, let iden = user.title {
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIden.ReuseIndetifier.user)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: user, reuseIdentifier: AnnotationIden.ReuseIndetifier.user)
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
    
    static func dequeueDriverPoint(_ mapView: MAMapView?, viewFor annotation: MAAnnotation?) -> MAAnnotationView? {
        guard let mapView = mapView, let annotation = annotation else { return nil }
        if let car = annotation as? MovingAnnotation {
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIden.ReuseIndetifier.car)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: car, reuseIdentifier: AnnotationIden.ReuseIndetifier.car)
            }
            annotationView?.image = R.image.map_car_point()
            annotationView?.canShowCallout = false
            return annotationView
        }
        return nil
    }
    
}
