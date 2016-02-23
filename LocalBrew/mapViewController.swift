//
//  mapViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/22/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate {

    var breweryObjects = [Brewery]()
    var averageLatitude: Double = 0
    var averageLongitude: Double = 0
    let centerAnnotation = MKPointAnnotation()
    var annotations = [MKPointAnnotation]()


    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

            for brewery in self.breweryObjects
            {
                
                self.dropPinForLocation(brewery)

                self.averageLatitude = self.averageLatitude + brewery.latitude
                self.averageLongitude = self.averageLongitude + brewery.longitude
        }
        self.averageLatitude = self.averageLatitude / Double(self.breweryObjects.count)
        self.averageLongitude = self.averageLongitude / Double(self.breweryObjects.count)
        self.centerAnnotation.coordinate = CLLocationCoordinate2DMake(self.averageLatitude, self.averageLongitude)
        self.mapView.setRegion(MKCoordinateRegionMake(self.centerAnnotation.coordinate, MKCoordinateSpanMake(0.1, 0.1)), animated: true)

        
    }
    
    
    func dropPinForLocation(brewery: Brewery)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(brewery.latitude, brewery.longitude)
        annotation.title = brewery.name
        self.mapView.addAnnotation(annotation)
        self.annotations.append(annotation)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
    if annotation .isEqual(mapView.userLocation)
    {
        return nil
   
    } else {

        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pin
        }
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        for brewery in breweryObjects
        {
            if brewery.name == ((view.annotation?.title)!) {
                let breweryCoordinates = CLLocationCoordinate2DMake(brewery.latitude, brewery.longitude)
                openMapForPlace(brewery, breweryCoordinates: breweryCoordinates)
            }
        }
    
    }
    
    func openMapForPlace(brewery: Brewery, breweryCoordinates: CLLocationCoordinate2D) {
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        let placemark = MKPlacemark(coordinate: breweryCoordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(brewery.name)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    

}
