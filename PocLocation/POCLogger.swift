//
//  POCLogger.swift
//  PocLocation
//
//  Created by Rodrigo Carvalho da Silva on 7/20/16.
//  Copyright © 2016 Kaique de Souza Monteiro. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

struct DataUpdate {
    let locations: [CLLocation]?
    let altitudeData: CMAltitudeData?
}

class POCLogger: NSObject {
    
    private override init() {}
    
    static let sharedInstance = POCLogger()
    
    var locations: CLLocation? = nil
    var altitudeData: CMAltitudeData? = nil
    var timer : NSTimer?
    
    var file = "data.igc"
    
    func updateData(data: DataUpdate) {
        
        if let altitude = data.altitudeData {
            altitudeData = altitude
        }
        
        if let location = data.locations?.last {
            locations = location
        }
    }
    
    func log() {
        
        let str = "Super long string here"
        let filename = getDocumentsDirectory().stringByAppendingPathComponent(file)
        
        do {
            try str.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func startLogging() {
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(log), userInfo: nil, repeats: true)
    }
    
    func stopLoggin() {
        timer?.invalidate()
    }
    
    
    
    
}