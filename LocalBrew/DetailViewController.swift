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
    @IBOutlet weak var breweryDirectionsButton: UIButton!
    @IBOutlet weak var breweryWebsiteButton: UIButton!
    
    var breweryDetail: Brewery!
    var breweryDestination = MKMapItem()
    let breweryAnnotation = MKPointAnnotation()
    var beerList = [NSDictionary]()
    var beerObjects = [Beer]()
    let progressHUD = ProgressHUD(text: "Brewing")
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.breweryIconImageView.image = self.breweryDetail.breweryImageIcon
        self.title = self.breweryDetail.name
        self.addressLabelField.text = self.breweryDetail.streetAddress
        self.breweryPhoneNumberButton.setTitle(self.breweryDetail.phoneNumber, forState: .Normal)
        
        self.breweryPhoneNumberButton.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.breweryPhoneNumberButton.backgroundColor = UIColor.blackColor()
        self.breweryPhoneNumberButton.layer.cornerRadius = 5
        self.breweryPhoneNumberButton.layer.borderWidth = 1
        self.breweryPhoneNumberButton.layer.borderColor = UIColor.blackColor().CGColor
        self.breweryDirectionsButton.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.breweryDirectionsButton.backgroundColor = UIColor.blackColor()
        self.breweryDirectionsButton.layer.cornerRadius = 5
        self.breweryDirectionsButton.layer.borderWidth = 1
        self.breweryDirectionsButton.layer.borderColor = UIColor.blackColor().CGColor
        self.breweryWebsiteButton.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.breweryWebsiteButton.backgroundColor = UIColor.blackColor()
        self.breweryWebsiteButton.layer.cornerRadius = 5
        self.breweryWebsiteButton.layer.borderWidth = 1
        self.breweryWebsiteButton.layer.borderColor = UIColor.blackColor().CGColor
        
        
        
        let likedBreweryRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbreweries")
        
        likedBreweryRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists())
            {
                likedBreweryRef.childByAppendingPath(self.breweryDetail.firebaseID).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    if snapshot.exists()
                    {
                        self.breweryLikeButton.imageView?.image = UIImage(named: "beerFull")
                    }
                    else
                    {
                        self.breweryLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                    }
                })
            }
        
        })
        
        
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
        
//        self.view.addSubview(progressHUD)
    }



    func accessDBBeerList()
    {
        // MARK: logic to import breweryDB data
        let url = NSURL(string: "http://api.brewerydb.com/v2/brewery/\(self.breweryDetail.breweryID)/beers?key=6f75023f91495f22253de067b9136d1d")
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
            
                let brewList = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                if brewList["data"] == nil {
                    print("Ooops, brewList is empty!")
                    let alertController = UIAlertController(title: "Oops. Where's the beer?", message: "This brewery has not provided us with a list of their brews.", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "Dismiss", style: .Default) { (action) in
                        
                        // dismiss UIAlert
                        
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        
                    }
                } else
                {
                    print("Hey, this place has beer!")
                    self.beerList = (brewList.objectForKey("data") as? [NSDictionary])!
                    for dict: NSDictionary in self.beerList
                    {
                        let beerObject: Beer = Beer(beerDataDictionary: dict, beerBrewery: self.breweryDetail)
                        self.beerObjects.append(beerObject)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.addSubview(self.progressHUD)
                        self.tableView.reloadData()

                    })
                }
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
    
    
    func likeBrewery()
    {
        let likedBreweryRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbreweries").childByAppendingPath(breweryDetail.firebaseID)
        var liked:Bool = true
        
        likedBreweryRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists()
            {
                likedBreweryRef.removeValue()
                self.breweryLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                liked = false
            }
            else
            {
                likedBreweryRef.setValue(["breweryName":self.breweryDetail.name])
                self.breweryLikeButton.imageView?.image = UIImage(named: "beerFull")
            }
            
            let breweryRef = FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.self.breweryDetail.firebaseID)
            
            breweryRef.childByAppendingPath("numberOfLikes").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let numlikes = snapshot.value as! Int
                
                if liked
                {
                    breweryRef.updateChildValues(["numberOfLikes":numlikes+1])
                }
                else
                {
                    breweryRef.updateChildValues(["numberOfLikes":numlikes-1])
                }
                
            })
            
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
        self.likeBrewery()
    }
    
    
   
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return beerObjects.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let beer = beerObjects[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BeerCellID") as? BeerCell{
            cell.configureCell(beer, beerBrewery: self.breweryDetail)
            self.progressHUD.removeFromSuperview()
            return cell
            
        } else {
            return BeerCell()
        }
        
    }
    
}
