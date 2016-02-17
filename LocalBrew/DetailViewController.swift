//
//  DetailViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/15/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBeerButton: UIBarButtonItem!
    @IBOutlet weak var breweryIconImageView: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabelField: UILabel!
    var favoriteBeerObjects = [FavoriteBeer]()
    var breweryDetail: Brewery!
    var breweryDestination = MKMapItem()
    let breweryAnnotation = MKPointAnnotation()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.breweryIconImageView.image = self.breweryDetail.breweryImageIcon
        self.title = self.breweryDetail.name
        
        // 1. set brewery region
        
        let breweryLatitude:CLLocationDegrees = self.breweryDetail.latitude
        let breweryLongitude:CLLocationDegrees = self.breweryDetail.longitude
        let breweryLatDelta:CLLocationDegrees = 0.08
        let breweryLongDelta:CLLocationDegrees = 0.08
        let span:MKCoordinateSpan = MKCoordinateSpanMake(breweryLatDelta, breweryLongDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(breweryLatitude, breweryLongitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        
        // 2. set brewery pin info
        
        breweryAnnotation.coordinate = CLLocationCoordinate2DMake(self.breweryDetail.latitude, self.breweryDetail.longitude)
        breweryAnnotation.title = self.breweryDetail.name
        mapView.addAnnotation(breweryAnnotation)
        
    
    }

    
    
    

func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = self.breweryDetail.breweryImageIcon
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pin
    
}


    @IBAction func addBeerOnButtonTapped(sender: AnyObject) {
        
        addFavoriteBeer()
        
    }


    func addFavoriteBeer() {
        let addBeer = UIAlertController(title: "Add your favorite Beer!", message: nil, preferredStyle: .Alert)
        addBeer.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, addBeer](action: UIAlertAction!) in
            let answer = addBeer.textFields![0].text
            let favoriteBeer = FavoriteBeer(name: answer!, favorite: 0)
            self.favoriteBeerObjects.append(favoriteBeer)
             self.tableView.reloadData()
        }
        addBeer.addAction(submitAction)
        
        presentViewController(addBeer, animated: true, completion: nil)
        
       
        
    }
    
    
    @IBAction func onWebsiteButtonPressed(sender: UIButton) {
    }
    
    @IBAction func onDirectionsButtonPressed(sender: UIButton) {
    }
    
    @IBAction func onCallButtonPressed(sender: UIButton) {
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return favoriteBeerObjects.count
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let favoriteBeer = favoriteBeerObjects[indexPath.row]

        
        if let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteBeerCellID") as? FavoriteBeerCell{
            cell.configureCell(favoriteBeer)
            return cell
            
        } else {
            return FavoriteBeerCell()
        }
    
    }

}
