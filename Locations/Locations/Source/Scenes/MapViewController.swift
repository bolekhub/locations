//
//  MapViewController.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    private var mapView: GMSMapView {
        return self.view as! GMSMapView
    }
    
    var selectedItem: TrafficCameraItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.icon = UIImage(named: "australia-large")
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    private func addmarker(metadata: TrafficCameraItem) {
        let coordinate = CLLocationCoordinate2D(latitude: metadata.lat, longitude: metadata.lon)
        let marker = GMSMarker(position: coordinate)
        marker.snippet = metadata.region
        marker.title = metadata.title
        marker.map = self.mapView
        marker.userData = metadata.identifier
    }
}


extension MapViewController: TCameraSelectedDelegate {
    func trafficCamSelected(_ item: TrafficCameraItem) {
        self.addmarker(metadata: item)
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        let camera = GMSCameraPosition(latitude: item.lat, longitude: item.lon, zoom: 10)
        mapView.animate(to: camera)
        CATransaction.commit()
    }
    
    
}

extension MapViewController {
    

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("\(String(describing: marker.userData))")
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        guard let imageVC = sb.instantiateViewController(withIdentifier: "image_vc") as? ImageViewController else {
            return
        }
        if let metadataId = marker.userData as? String {
            imageVC.camIdentifier = metadataId
        }
        guard let anchorView = marker.iconView else {
            return
        }
        imageVC.popoverPresentationController?.sourceView = anchorView
        imageVC.modalPresentationStyle = .popover

        self.present(imageVC, animated: true, completion: nil)
    }
}
