//
//  mapViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/22/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController {

    var breweryObjects = [Brewery]()
    var averageLatitude: Double = 0
    var averageLongitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

            for brewery in self.breweryObjects
            {
                    print(brewery)
//                self.dropPinForLocation(brewery)
//
//                self.averageLatitude = self.averageLatitude + self.breweryObjects
//                self.averageLongitude = self.averageLongitude + busStop.longitude
        }
        
        
    }
//    func dropPinForLocation(brewery: Brewery)
//    {
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2DMake(busStop.latitude, busStop.longitude)
//        annotation.title = busStop.name
//        annotation.subtitle = "Routes: \(busStop.routes)"
//        self.mapView.addAnnotation(annotation)
//        self.annotations.append(annotation)
//        
//    }
//    
//    

}
