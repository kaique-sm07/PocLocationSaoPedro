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
    
    var location: CLLocation? = nil
    var altitudeData: CMAltitudeData? = nil
    var timer : NSTimer?
    
    var file = "data.igc"
    var logText: String = ""
    
    func updateData(data: DataUpdate) {
        if let altitude = data.altitudeData {
            altitudeData = altitude
        }
        
        if let location = data.locations?.last {
            self.location = location
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
    
    func getDataToIgc() -> String {
    
        let hours = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        let minutes = NSCalendar.currentCalendar().component(.Minute, fromDate: NSDate())
        let seconds = NSCalendar.currentCalendar().component(.Second, fromDate: NSDate())
        let geomData = "B" + "\(numberToString(hours))" + "\(numberToString(minutes))" + "\(numberToString(seconds))" +
                    "\(getLatLong())" + "A" //TODO: Falta altura
        return geomData
        
    }
    
    func numberToString(number:Int) -> String {
        
        var numberString = ""
        if abs(number) < 10 {
            numberString = "0" + String(abs(number))
        } else {
            numberString = String(abs(number))
        }
        
        return numberString
    
    }
    
    func longToString(number:Int) -> String {
        
        var numberString = ""
        if abs(number) < 10 {
            numberString = "00" + String(abs(number))
        } else if abs(number) > 9 && abs(number) < 100{
            numberString = "0" + String(abs(number))
        } else {
            numberString = String(abs(number))
        }
        
        return numberString
        
    }

    //Funcao que retorna a string de latitude e longitude
    func getLatLong() -> String {
        let latitude = self.location?.coordinate.latitude
        let longitude = self.location?.coordinate.latitude
        
        var latSeconds = Int(latitude! * 3600)
        let latDegrees = latSeconds / 3600
        let latDegreeString = numberToString(latDegrees)
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        var longSeconds = Int(longitude! * 3600)
        let longDegrees = longSeconds / 3600
        let longDegreeString = longToString(longDegrees)
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        return String(format:"%@%@%@%@%@%@%@%@",
                      latDegreeString,
                      numberToString(latMinutes),
                      numberToString(latSeconds),
                      {return latDegrees >= 0 ? "N" : "S"}(),
                      longDegreeString,
                      numberToString(longMinutes),
                      numberToString(longSeconds),
                      {return longDegrees >= 0 ? "E" : "W"}() )
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