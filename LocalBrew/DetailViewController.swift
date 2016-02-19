//
//  DetailViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/15/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import Firebase

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var breweryIconImageView: UIImageView!
    @IBOutlet weak var breweryPhoneNumberButton: UIButton!
    @IBOutlet weak var breweryLikeButton: UIButton!
    
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
        self.addressLabelField.text = self.breweryDetail.streetAddress
        self.breweryPhoneNumberButton.setTitle(self.breweryDetail.phoneNumber, forState: .Normal)
        
        
        
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
        let url = NSURL(string: "http://api.brewerydb.com/v2/brewery/\(self.breweryDetail.breweryID)/beers?key=324f8ff71fe7f84fab3655aeab07f01c")
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                let brewList = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary

                
                self.beerList = (brewList.objectForKey("data") as? [NSDictionary])!
                for dict: NSDictionary in self.beerList {
                    let beerObject: Beer = Beer(beerDataDictionary: dict)
                    self.beerObjects.append(beerObject)

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
    
    
    
    func checkFirebaseForBrewery()
    {
        // Check if brewery is in firebase.
        let breweryRef = FirebaseConnection.firebaseConnection.BREWERY_REF
        //let userRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF
        
        breweryRef.queryOrderedByChild("breweryID").queryEqualToValue(self.breweryDetail.breweryID).observeSingleEventOfType(.Value, withBlock: {snapshots in
            print(snapshots)
            
            // if breweries entity is empty
            if(snapshots.value is NSNull)
            {
                FirebaseConnection.firebaseConnection.createNewBrewery(self.breweryDetail)
                self.likeBrewery()
            }
            else
            {
                for snapshot in snapshots.value.allObjects
                {
                    // if brewery exists in firebase
                    if snapshot["breweryID"] as! String == self.breweryDetail.breweryID
                    {
                        //print(snapshot.key as! String)
                        self.likeBrewery()
                        return
                    }
                    
                }
                //if brewery doesn't exist in firebase
                FirebaseConnection.firebaseConnection.createNewBrewery(self.breweryDetail)
                self.likeBrewery()
            }
            
        })
    }
    
    func likeBrewery()
    {
        
        let likedBreweryRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbreweries").childByAppendingPath(breweryDetail.firebaseID)
        likedBreweryRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if snapshot.exists()
            {
                likedBreweryRef.removeValue()
                self.breweryLikeButton.imageView?.image = UIImage(named: "beerEmpty")
            }
            else
            {
                likedBreweryRef.setValue(["breweryName":self.breweryDetail.name])
                self.breweryLikeButton.imageView?.image = UIImage(named: "beerFull")
                
            }
        })
        
    
        
    }
        
        
        
    
    
    
    
    @IBAction func onWebsiteButtonPressed(sender: UIButton) {
                
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
        let dvc = segue.destinationViewController as? WebsiteViewController
        print(self.breweryDetail)
        dvc?.breweryDetail = self.breweryDetail
        dvc?.title = self.breweryDetail.name
    }
    
    @IBAction func onCallButtonPressed(sender: AnyObject) {
        
        let phoneNumber = self.breweryDetail.phoneNumber
        
            let aURL = NSURL(string: "telprompt://\(phoneNumber)")
            if UIApplication.sharedApplication().canOpenURL(aURL!) {
                UIApplication.sharedApplication().openURL(aURL!)
            } else {
                print("error")
            }
    }
    
    
    
    @IBAction func onDirectionsButtonPressed(sender: UIButton) {
        
        openMapForPlace()
    }
    
    func openMapForPlace() {
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        let placemark = MKPlacemark(coordinate: breweryAnnotation.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.breweryDetail.name)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    @IBAction func onBreweryButtonTapped(sender: UIButton)
    {
        // Check if brewery is in firebase if not add it
        checkFirebaseForBrewery()
        
        //check if user has liked brewery
        //FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbreweries").queryOrderedByChild("breweryID").queryOrderedByValue().observeSingleEventOfType(.Value, withBlock: { snapshot in
            
           // print(snapshot.value)
       // })
        
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
