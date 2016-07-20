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
    var logText: String = ""
    
    func updateData(data: DataUpdate) {
        if let altitude = data.altitudeData {
            altitudeData = altitude
        }
        
        if let location = data.locations?.last {
            locations = location
        }
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func log() {
        logText = logText + "\nDADOS DE VOO"
        
        do {
            try logText.writeToFile(getDocumentsDirectory().stringByAppendingPathComponent(file), atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print("Não conseguiu escrever")
        }
    }
    
    func readBaseFile() {
        let filePath = NSBundle.mainBundle().pathForResource("fly", ofType:"igc")
        if let file = filePath {
            
            do {
                logText = try String(contentsOfFile: file)
                print(logText)
            } catch {
                print("No File")
            }
        }
    }
    
    func startLogging() {
        logText = ""
        readBaseFile()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(log), userInfo: nil, repeats: true)
    }
    
    func stopLoggin() {
        timer?.invalidate()
        
    }
    
    
    
    
}