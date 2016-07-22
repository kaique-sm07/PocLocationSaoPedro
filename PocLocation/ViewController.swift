//
//  ViewController.swift
//  PocLocation
//
//  Created by Kaique de Souza Monteiro on 12/07/16.
//  Copyright © 2016 Kaique de Souza Monteiro. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = Location()
    let altimeter = Altimeter()

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.altimeter.startAltitudeTracking()
        self.locationManager.getlocationForUser()
        POCLogger.sharedInstance.startLogging()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    }

}

