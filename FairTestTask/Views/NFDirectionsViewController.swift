//
//  NFDirectionsViewController.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 11/12/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import NVActivityIndicatorView

class NFDirectionsViewController: UIViewController, MKMapViewDelegate {
    
    public var sourceLocation: CLLocationCoordinate2D?
    public var destinationLocation: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawRoute()
    }
    
    private func drawRoute() {
        let request = MKDirections.Request()
        if let sLocation = sourceLocation, let dLocation = destinationLocation {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: sLocation, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: dLocation, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            
            // Show loader
            let activityData = ActivityData.init(size: nil, message: nil, messageFont: nil, messageSpacing: nil, type: .circleStrokeSpin, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
            
            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }
                if let route = unwrappedResponse.routes.first {
                    self.mapView.add(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsetsMake(60, 60, 60, 60), animated: true)
                }
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        }
    }
    
    private func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(hexString: "FE5A00")
        renderer.lineWidth = 3
        return renderer
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


