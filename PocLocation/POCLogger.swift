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
        logText = logText + "\n" + getDataToIgc()
        
        print(getAltitude())
        print(location?.altitude)
        
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
        
        //let altitude = location?.altitude
        
    
        let hours = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        let minutes = NSCalendar.currentCalendar().component(.Minute, fromDate: NSDate())
        let seconds = NSCalendar.currentCalendar().component(.Second, fromDate: NSDate())
        let altitudeBarometer = altitudeToString(Int(getAltitude()))
        let altitudeGps = altitudeToString(Int((self.location?.altitude)!))
        let geomData = "B" + "\(numberToString(hours))" + "\(numberToString(minutes))" + "\(numberToString(seconds))" +
                    "\(getLatLong())" + "A" + altitudeBarometer + altitudeGps
        
        return geomData
        
    }
    
    func getAltitude() -> Double {
        
        let altitude = (288.15 * (-1 + pow((((altitudeData?.pressure.doubleValue)! * 10) / 1013.25), 1/5.2561))) / -0.0065
        return altitude
        
    
    }
    
    func altitudeToString(number:Int) -> String {
        
        var numberString = ""
        if abs(number) < 10 {
            numberString = "0000" + String(abs(number))
        } else if abs(number) > 9 && abs(number) < 100{
            numberString = "000" + String(abs(number))
        } else if abs(number) > 99 && abs(number) < 1000{
            numberString = "00" + String(abs(number))
        } else if abs(number) > 999 && abs(number) < 10000{
            numberString = "0" + String(abs(number))
        } else {
            numberString = String(abs(number))
        }
        
        return numberString
        
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
        let longitude = self.location?.coordinate.longitude
        
        print(latitude)
        print(longitude)
        
        let latDegree = Int(abs(latitude!))
        let latMinutes = Int((abs(latitude!) - Double(latDegree)) * 60000)

        
        let longDegrees = Int(abs(longitude!))
        
        let longMinutes = Int((abs(longitude!) - Double(longDegrees)) * 60000)
        return String(format:"%@%@%@%@%@%@",
                      numberToString(latDegree),
                      numberToString(latMinutes),
                      {return latitude >= 0 ? "N" : "S"}(),
                      numberToString(longDegrees),
                      numberToString(longMinutes),
                      {return longitude >= 0 ? "E" : "W"}() )
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