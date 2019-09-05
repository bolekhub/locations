//
//  MapViewController.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import GoogleMaps

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
}


extension MapViewController: TCameraSelectedDelegate {
    
    func trafficCamSelected(_ item: TrafficCameraItem) {
        self.addmarker(metadata: item)
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        let camera = GMSCameraPosition(latitude: item.lat, longitude: item.lon, zoom: 10)
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
        imageVC.modalPresentationStyle = .popover
        imageVC.popoverPresentationController?.sourceView = marker.iconView!
        //imageVC.popoverPresentationController?.sourceRect = marker.iconView!.bounds
        self.present(imageVC, animated: true, completion: nil)
    }
}


extension ImageViewController: UIPopoverPresentationControllerDelegate {

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let popController = viewControllerToPresent.popoverPresentationController,
            popController.sourceView == nil{
            return
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}
