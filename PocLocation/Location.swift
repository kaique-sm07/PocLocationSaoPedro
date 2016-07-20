//
//  Location.swift
//  PocLocation
//
//  Created by Rodrigo Carvalho da Silva on 7/19/16.
//  Copyright © 2016 Kaique de Souza Monteiro. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.manager.distanceFilter = 1.0
    }
    
    func getlocationForUser() {
        
        //First need to check if the apple device has location services availabel. (i.e. Some iTouch's don't have this enabled)
        if CLLocationManager.locationServicesEnabled() {
            //Then check whether the user has granted you permission to get his location
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                //Request permission
                //Note: you can also ask for .requestWhenInUseAuthorization
                manager.requestAlwaysAuthorization()
            } else if CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied {
                //... Sorry for you. You can huff and puff but you are not getting any location
            } else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                // This will trigger the locationManager:didUpdateLocation delegate method to get called when the next available location of the user is available
                self.manager.startUpdatingLocation()
            }
        }
        
    }
    
    //MARK: CLLocationManager Delegate metho
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let data = DataUpdate(locations: locations, altitudeData: nil)
        POCLogger.sharedInstance.updateData(data)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}