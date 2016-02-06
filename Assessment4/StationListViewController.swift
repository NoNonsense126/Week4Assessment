//
//  ViewController.swift
//  Assessment4
//
//  Created by Ben Bueltmann on 2/3/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import CoreLocation

class StationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allBikeStations = [BikeStation]()
    var filteredBikeStations = [BikeStation]()
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func loadBikeStations () {
        let apiURL = NSURL(string: "http://www.bayareabikeshare.com/stations/json")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(apiURL!) { (data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                let bikeStation = json.objectForKey("stationBeanList") as! [NSDictionary]
                self.allBikeStations = bikeStation.map({ BikeStation(jsonDict: $0) })
//                for station in bikeStation {
//                    self.allBikeStations.append(BikeStation(jsonDict: station))
//                }
                self.allBikeStations.sortInPlace({ (bike1, bike2) -> Bool in
                    bike1.distanceFromLocation(self.userLocation) < bike2.distanceFromLocation(self.userLocation)
                })
                
                
                self.filteredBikeStations = self.allBikeStations
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    // MARK: - Search Bar Delegates
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchTerm = searchBar.text
        if searchTerm == "" {
            filteredBikeStations = allBikeStations
        }else{
            filteredBikeStations = allBikeStations.filter({(bikeStation: BikeStation) -> Bool in
                let stringMatch = bikeStation.stationName.lowercaseString.rangeOfString((searchTerm?.lowercaseString)!)
                return stringMatch != nil ? true : false
            })
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Location Manager Delegates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            self.userLocation = location!
            locationManager.stopUpdatingLocation()
            loadBikeStations()
        }
    }
    
    // MARK: - Table View Delegates
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
    
        let bikeStation = filteredBikeStations[indexPath.row]
        cell.textLabel?.text = bikeStation.stationName
        cell.detailTextLabel?.text = "Bikes Available: \(bikeStation.availableBikes) | Distance: \(bikeStation.distanceFromLocation(self.userLocation))km"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TO DO
        return filteredBikeStations.count
    }
    
    // Mark: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! MapViewController
        let indexPath = self.tableView.indexPathForSelectedRow!
        let bikeStation = filteredBikeStations[indexPath.row]
        destinationVC.bikeStation = bikeStation
    }
    
}

