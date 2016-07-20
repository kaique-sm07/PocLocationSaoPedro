//
//  Altimeter.swift
//  CoreMotionPOC
//
//  Created by Rodrigo Carvalho da Silva on 7/12/16.
//  Copyright © 2016 Rodrigo Silva. All rights reserved.
//

import Foundation
import CoreMotion

class Altimeter {
    
    let altimeter: CMAltimeter
    
    init() {
        altimeter = CMAltimeter()
    }
    
    func startAltitudeTracking() -> Bool {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return false}
        
        let altimeterQueue = NSOperationQueue()
        
        altimeter.startRelativeAltitudeUpdatesToQueue(altimeterQueue) { (inData, error) in
            guard let data = inData else { print("Error: \(error?.localizedDescription)"); return }
            
            let dataUpdate = DataUpdate(locations: nil, altitudeData: data)
            POCLogger.sharedInstance.updateData(dataUpdate)
            
            print("Relative Altitude \(data.relativeAltitude.floatValue)  Pressure \(data.pressure.floatValue)  Timestamp \(data.timestamp)")
        }
        
        return true
    }
    
    func stopAltitudeTracking() {
        altimeter.stopRelativeAltitudeUpdates()
    }
    
}