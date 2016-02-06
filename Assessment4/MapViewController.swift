//
//  MapViewController.swift
//  Assessment4
//
//  Created by Ben Bueltmann on 2/3/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var bikeStation: BikeStation?
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        showBikeOnMap()
        zoomInOnBike()
    }
    
    func showBikeOnMap() {
        let annotation = MKPointAnnotation()
        annotation.title = bikeStation!.stationName
        annotation.subtitle = "\(bikeStation!.availableBikes)"
        annotation.coordinate = bikeStation!.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    func zoomInOnBike() {
        var region = MKCoordinateRegionMake(bikeStation!.coordinate, MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        region = self.mapView.regionThatFits(region)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView()
        pin.image = UIImage(named: "bikeImage")
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: bikeStation!.coordinate, addressDictionary: nil))
        request.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if let routes = response?.routes {
                if let route = routes.first {
                    var message = ""
                    for step in route.steps{
                        message += "\n\(step.instructions)"
                    }
                    let alertController = UIAlertController(title: "Directions", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let alertAction = UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(alertAction)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            }
            
        }
    }
}
