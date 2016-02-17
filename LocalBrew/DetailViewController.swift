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
    
    var breweryDetail: Brewery!
    var breweryDestination = MKMapItem()
    let breweryAnnotation = MKPointAnnotation()
    var beerList = [NSDictionary]()
    var beerObjects = [Beer]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.breweryIconImageView.image = self.breweryDetail.breweryImageIcon
        self.title = self.breweryDetail.name
        
        print(self.breweryDetail.breweryID)
        
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
        
     accessDBBeerList()
        
    }

    
    func accessDBBeerList()
    {
        // MARK: logic to import breweryDB data
        let url = NSURL(string: "http://api.brewerydb.com/v2/brewery/\(self.breweryDetail.breweryID)/beers?key=6f75023f91495f22253de067b9136d1d")
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                let brewList = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                print(brewList)
                
                self.beerList = brewList.objectForKey("data") as! [NSDictionary]
                for dict: NSDictionary in self.beerList {
                    let beerObject: Beer = Beer(beerDataDictionary: dict)
                    self.beerObjects.append(beerObject)
                    print(self.beerObjects)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
            catch let error as NSError{
                print("JSON Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    

func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = self.breweryDetail.breweryImageIcon
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pin
    
}


//    @IBAction func addBeerOnButtonTapped(sender: AnyObject) {
//        
//        addFavoriteBeer()
//        
//    }
//
//
//    func addFavoriteBeer() {
//        let addBeer = UIAlertController(title: "Add your favorite Beer!", message: nil, preferredStyle: .Alert)
//        addBeer.addTextFieldWithConfigurationHandler(nil)
//        
//        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, addBeer](action: UIAlertAction!) in
//            let answer = addBeer.textFields![0].text
//            let favoriteBeer = FavoriteBeer(name: answer!, favorite: 0)
//            self.favoriteBeerObjects.append(favoriteBeer)
//             self.tableView.reloadData()
//        }
//        addBeer.addAction(submitAction)
//        
//        presentViewController(addBeer, animated: true, completion: nil)
//        
//       
//        
//    }
    
    
    @IBAction func onWebsiteButtonPressed(sender: UIButton) {
        
    }
    
    
    @IBAction func onDirectionsButtonPressed(sender: UIButton) {
    
    }
    
    
    @IBAction func onCallButtonPressed(sender: UIButton) {
    
    
    }
   
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return beerObjects.count
        
    }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let beer = beerObjects[indexPath.row]

        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BeerCellID") as? BeerCell{
            cell.configureCell(beer)
            return cell
            
        } else {
            return BeerCell()
        }
    
    }

}
