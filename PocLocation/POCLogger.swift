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
	
	private let KEY = "M6VLw6RuK33EqX4E6HB74igo17E73QE4"
    
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
                logText = logText + "\n" + getInitialPoint()
                print(logText)
            } catch {
                print("No File")
            }
        }
    }
    
    func getInitialPoint() -> String {
    
        let hours = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        let minutes = NSCalendar.currentCalendar().component(.Minute, fromDate: NSDate())
        let seconds = NSCalendar.currentCalendar().component(.Second, fromDate: NSDate())
        return "LLXNORIGIN" + numberToString(hours) + numberToString(minutes) + numberToString(seconds) +
            getLatLong()
    
    }
    
    func getDataToIgc() -> String {
        
        //let altitude = location?.altitude
        
    
        let hours = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        let minutes = NSCalendar.currentCalendar().component(.Minute, fromDate: NSDate())
        let seconds = NSCalendar.currentCalendar().component(.Second, fromDate: NSDate())
        let altitudeBarometer = altitudeToString(Int(getAltitude()))
        let altitudeGps = altitudeToString(Int((self.location?.altitude)!))
        let geomData = "B" + numberToString(hours) + numberToString(minutes) + numberToString(seconds) +
                    getLatLong() + "A" + altitudeBarometer + altitudeGps
		
		print(geomData)
		
        return geomData
        
    }
    
    func getAltitude() -> Double {
        
        let altitude = (288.15 * (-1 + pow((((altitudeData?.pressure.doubleValue)! * 10) / 1013.25), 1/5.2561))) / -0.0065
        return altitude
        
    
    }
	
	func validateIGC()
	{
		if let path = NSBundle.mainBundle().pathForResource("test", ofType: "igc") {
			do {
				let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
				let lines = content.componentsSeparatedByString("\n")
				
				let context = UnsafeMutablePointer<CCHmacContext>.alloc(1)
				CCHmacInit(context, UInt32(kCCHmacAlgSHA256), KEY, KEY.characters.count)
				
				parseFile(lines, context: context)
				
			} catch {
				print("Deu ruim abrindo o arquivo para validação")
			}
		}
		
	}
	
	func parseFile(content: [String], context: UnsafeMutablePointer<CCHmacContext>)
	{
		logText = ""
		for line in content {
			if line.hasPrefix("HP") || line.hasPrefix("HO") ||
				(line.hasPrefix("L") && !line.hasPrefix("LLXN")
				|| line.characters.count == 0) {
				// Do nothing
			} else {
				logText += line.stringByAppendingString("\n")
				print(line)
				
				CCHmacUpdate(context, line.stringByAppendingString("\n"), line.characters.count + 1)
			}
		}
		
		finishValidation(context)
	}
	
	func finishValidation(context: UnsafeMutablePointer<CCHmacContext>)
	{
		var validationCode = Array<UInt8>(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
		CCHmacFinal(context, &validationCode)
		
		context.dealloc(1)
		
		var hexString = "G"
		
		for byte in validationCode {
			hexString += String(format: "%02X", byte)
		}
		
		hexString += "\n"
		
		logText += hexString
		
		do {
			try logText.writeToFile(getDocumentsDirectory().stringByAppendingPathComponent("validated.igc"), atomically: true, encoding: NSUTF8StringEncoding)
			print(hexString)
		} catch {
			print("Deu ruim imprimindo G")
		}
	}
	
    func altitudeToString(number:Int) -> String {
        return String(format: "%05d", abs(number))
    }
	
	func latToString(degree: Int, _ min: Int, _ isPositive: Bool) -> String
	{
		return String(format: "%02d%05d", degree, min) + (isPositive ? "N" : "S")
	}
	
	func longToString(degree: Int, _ min: Int, _ isPositive: Bool) -> String
	{
		return String(format: "%03d%05d", degree, min) + (isPositive ? "E" : "W")
	}
    
    func numberToString(number:Int) -> String {
        return String(format: "%02d", abs(number))
    }

    //Funcao que retorna a string de latitude e longitude
    func getLatLong() -> String {
        let latitude = self.location?.coordinate.latitude ?? 0
        let longitude = self.location?.coordinate.longitude ?? 0
        
        print(latitude)
        print(longitude)
        
        let latDegree = Int(abs(latitude))
        let latMinutes = Int((abs(latitude) - Double(latDegree)) * 60000)
		
        let longDegrees = Int(abs(longitude))
        let longMinutes = Int((abs(longitude) - Double(longDegrees)) * 60000)
		
        return latToString(latDegree, latMinutes, latitude >= 0) + longToString(longDegrees, longMinutes, longitude >= 0)
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