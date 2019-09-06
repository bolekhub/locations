//
//  MapViewController.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

/// Handle all interactions with GoogleMaps
class MapViewController: UIViewController {
    
    /// GoogleMaps in wich all elements are rendered
    private var mapView: GMSMapView {
        return self.view as! GMSMapView
    }
    
    override func loadView() {
        self.setupView()
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        let originalImage = UIImage(named: "australia-large")
        marker.icon = originalImage?.resizedImage(for: CGSize(width: 40, height: 40) )
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.mapView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearch))
        NotificationCenter.default.addObserver(self, selector: #selector(locateCoordinateOnMap), name: .showCoordinate, object: nil)
    }
    
    /// Add Map marker
    ///
    /// - Parameter metadata: model item to extract elements to update UI
    private func addmarker(metadata: TrafficCameraItem) {
        
        let coordinate = CLLocationCoordinate2D(latitude: metadata.lat, longitude: metadata.lon)
        let marker = GMSMarker(position: coordinate)
        marker.title = metadata.title
        marker.snippet = metadata.region
        marker.map = self.mapView
        marker.userData = metadata.identifier
    }
    
    @objc private func showSearch() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let search = sb.instantiateViewController(withIdentifier: ForwardSearchViewController.identifier)
        let nc = UINavigationController(rootViewController: search)
        self.present(nc, animated: true, completion: nil)
    }
    
    /// process a notification containig a coordinate
    ///
    /// - Parameter note: notification with a CLLocationCoordinate on a userinfo
    @objc private func locateCoordinateOnMap(_ note: NSNotification) {
        if let receivedCoordinate = note.userInfo?[kNotificationCoordinateKey] as? CLLocationCoordinate2D {
            self.mapView.clear()
            
            let circle = GMSCircle(position: receivedCoordinate, radius: kDefaultSearchRadio)
            circle.strokeColor = .green
            circle.fillColor = UIColor(displayP3Red: 2, green: 34, blue: 76, alpha: 0.6)
            circle.map = self.mapView
            
            let boundingBox = circle.bounds() 
            let update = GMSCameraUpdate.fit(boundingBox)
            self.mapView.animate(with: update)
        }
    }
    
}


extension MapViewController: TCameraSelectedDelegate {
    
    func trafficCamSelected(_ item: TrafficCameraItem) {
        self.addmarker(metadata: item)
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        let camera = GMSCameraPosition(latitude: item.lat, longitude: item.lon, zoom: 13)
        self.mapView.animate(to: camera)
        CATransaction.commit()
    }
    
    
}

extension MapViewController: GMSMapViewDelegate{
    
    private func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 7.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let sb = UIStoryboard.init(name: kMainStoryboardIdentifier, bundle: nil)
        guard let imageVC = sb.instantiateViewController(withIdentifier: ImageViewController.identifier) as? ImageViewController else {
            return
        }
        if let metadataId = marker.userData as? String {
            imageVC.camIdentifier = metadataId
        }

        imageVC.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .pad ? .pageSheet : .popover
        self.present(imageVC, animated: true, completion: nil)
    }
}
