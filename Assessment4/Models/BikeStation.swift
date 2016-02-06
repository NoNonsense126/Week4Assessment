//
//  BikeStation.swift
//  Assessment4
//
//  Created by Wong You Jing on 05/02/2016.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import CoreLocation

class BikeStation: NSObject {
    let stationName: String
    let availableBikes: Int
    let coordinate: CLLocationCoordinate2D
    let location: CLLocation
    
    init(jsonDict: NSDictionary){
        stationName = jsonDict.objectForKey("stationName") as! String
        availableBikes = jsonDict.objectForKey("availableBikes") as! Int
        coordinate = CLLocationCoordinate2DMake(jsonDict.objectForKey("latitude") as! Double, jsonDict.objectForKey("longitude") as! Double)
        location = CLLocation(latitude: jsonDict.objectForKey("latitude") as! Double, longitude: jsonDict.objectForKey("longitude") as! Double)
    }
    
    func distanceFromLocation(location: CLLocation) -> CLLocationDistance{
        let distance = self.location.distanceFromLocation(location)
        let roundedDistance = round(distance/10)/100
        return roundedDistance
    }
}