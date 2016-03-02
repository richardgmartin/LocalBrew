//
//  ViewController.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-13.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import MapKit


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, ChangeCityViewControllerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UITabBarControllerDelegate {
    @IBOutlet weak var mapSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var changeCityButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var breweries = [NSDictionary]()
    var breweryObjects = [Brewery]()
    var locationManager = CLLocationManager()
    var currentUser = Dictionary<String, AnyObject>()
    var locality: String?
    var region: String?
    var countryName: String?
    var averageLatitude: Double = 0
    var averageLongitude: Double = 0
    let centerAnnotation = MKPointAnnotation()
    var annotations = [MKPointAnnotation]()
    var givenCity: String?
    var givenState: String?
    var givenCountry: String?
    var snapshotsArray:NSArray!
    let progressHUD = ProgressHUD(text: "Brewing")
    var changeCityController: ChangeCityViewController?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var longPress = UILongPressGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var location = CLLocation()
    var hasCalledAPI:Bool!
    
    let defaultCity = "chicago"
    let defaultState = "illinois"
    let defaultCountry = "us"
    
    let nameAbbreviations: [String:String] = [
        "AL":"alabama",
        "AK":"alaska",
        "AZ":"arizona",
        "AR":"arkansas",
        "CA":"california",
        "CO":"colorado",
        "CT":"connecticut",
        "DE":"delaware",
        "DC":"district+of+columbia",
        "FL":"florida",
        "GA":"georgia",
        "HI":"hawaii",
        "ID":"idaho",
        "IL":"illinois",
        "IN":"indiana",
        "IA":"iowa",
        "KS":"kansas",
        "KY":"kentucky",
        "LA":"louisiana",
        "ME":"maine",
        "MD":"maryland",
        "MA":"massachusetts",
        "MI":"michigan",
        "MN":"minnesota",
        "MS":"mississippi",
        "MO":"missouri",
        "MT":"montana",
        "NE":"nebraska",
        "NV":"nevada",
        "NH":"new+hampshire",
        "NJ":"new+jersey",
        "NM":"new+mexico",
        "NY":"new+york",
        "NC":"north+carolina",
        "ND":"north+dakota",
        "OH":"ohio",
        "OK":"oklahoma",
        "OR":"oregon",
        "PA":"pennsylvania",
        "RI":"rhode+island",
        "SC":"south+carolina",
        "SD":"south+dakota",
        "TN":"tennessee",
        "TX":"texas",
        "UT":"utah",
        "VT":"vermont",
        "VA":"virginia",
        "WA":"washington",
        "WV":"west+virginia",
        "WI":"wisconsin",
        "WY":"wyoming",
        "NL":"newfoundland",
        "NS":"nova+scotia",
        "NB":"new+brunswick",
        "AB":"alberta",
        "PE":"prince+edward+island",
        "BC":"british+columbia",
        "SK":"saskatchewan",
        "MB":"manitoba",
        "QC":"quebec",
        "ON":"ontario"]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.userInteractionEnabled = false
        
//        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
//        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationController?.navigationBar.barTintColor = UIColor.fromHexString("#960200", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.fromHexString("#FAFAFF", alpha: 1.0)]
        self.setCurrentUser()
        
        self.navigationController?.navigationBar.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        self.mapSegmentControl.tintColor = UIColor.fromHexString("#FAD201", alpha: 1.0)
        self.mapSegmentControl.backgroundColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
        self.mapSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.fromHexString("#000000", alpha: 1.0)], forState: .Normal)
        self.mapSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.fromHexString("#000000", alpha: 1.0)], forState: .Selected)
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            while CLLocationManager.authorizationStatus() == .NotDetermined {
                // wait until user provides response
            }
            if CLLocationManager.authorizationStatus() == .Denied {
                
                let alertController = UIAlertController(title: "Oops. There was a problem.", message: "There was something wrong with the city information you provided. Try again or change the selected city.", preferredStyle: .Alert)
                
                
                let OKAction = UIAlertAction(title: "Try Again", style: .Default) { (action) in
                    
                    // redirect user back to ChangeCityViewController to choose another city
                    self.changeCity()
                    
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    
                }
            }
            
            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
            
        }
        
        
        // set delegate relationship with ChangeCityViewController
        changeCityController?.delegate = self
        
        //add activity spinner and label
        self.view.addSubview(progressHUD)
        
        
        // All done!
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.longPress.addTarget(self, action: "showBreweryComments:")
        self.longPress.minimumPressDuration = 0.5
        self.tap.addTarget(self, action: "handleTap:")
        
        self.view.addGestureRecognizer(self.longPress)
        self.view.addGestureRecognizer(self.tap)
        
        self.mapView.hidden = true
        self.tabBarController?.delegate = self
        
        self.hasCalledAPI = false
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        self.navigationController?.navigationBarHidden = false
        self.mapView.hidden = true
        self.tableView.hidden = false
        self.mapSegmentControl.selectedSegmentIndex = 0
        self.mapView.removeAnnotations(annotations)
        self.view.addGestureRecognizer(tap)

    }
    
    // MARK : - Location manager delogates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.location = locations.first!
        if self.location.verticalAccuracy < 2000 && self.location.horizontalAccuracy < 2000
        {
            locationManager.stopUpdatingLocation()
            //4self.locationManager.delegate = nil
            reverseGeocode(self.location)
            
          
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func reverseGeocode(location: CLLocation)
    {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            
            let placemark = placemarks?.first
            _ = "\(placemark!.locality!) \(placemark!.administrativeArea!) \(placemark!.country!)"
            
            
            self.locality = String(UTF8String: (placemark?.locality)!)!
            let placemarkRegion = String(UTF8String: placemark!.administrativeArea!)!
            let placemarkCountry = String(UTF8String: (placemark?.country)!)
            
            if placemarkCountry == "United States" {
                self.countryName = "us"
            } else {
                self.countryName = "ca"
            }
            
            
            //              var key = placemark?.administrativeArea
            for (key,value) in self.nameAbbreviations
            {
                if key == placemarkRegion
                {
                    self.region = value
                    //print(value)
                }
            }
            self.navigationItem.title = self.locality?.capitalizedString
            
            if(!self.hasCalledAPI)
            {
                self.accessBreweryDB()
            }
            self.hasCalledAPI = true

        })
        
        
        
        
    }
    
    func accessBreweryDB()
    {
        // MARK: logic to import breweryDB data
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/locations?locality=\(self.locality!)&region=\(self.region!)&countryIsoCode=\(self.countryName!)&key=6f75023f91495f22253de067b9136d1d")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                // MARK: check to see if user has selected city with a brewery or has entered bad data
                
                if localBrew["data"] == nil {
                   // print("Ooops, localBrew is empty")
                    
                    let alertController = UIAlertController(title: "Oops. There was a problem.", message: "There was something wrong with the city information you provided. Try again or change the selected city.", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "Try Again", style: .Default) { (action) in
                        
                        // redirect user back to ChangeCityViewController to choose another city
                        self.changeCity()
                        
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        
                    }
                }
                else {
                    //print("Good to go: localBrew is not empty")
                    
                    self.breweries = localBrew.objectForKey("data") as! [NSDictionary]
                    
                    for dict: NSDictionary in self.breweries
                    {
                        let breweryObject: Brewery = Brewery(dataDictionary: dict, userLocation: self.location)
                        self.breweryObjects.append(breweryObject)
                    }
                    
                }
                //print(localBrew["data"])
                
            }
                
            catch let error as NSError{
                print(error)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.breweryObjects.sortInPlace{$0.distance < $1.distance}
                self.tableView.reloadData()
                //self.breweryObjects = []
                self.navigationItem.rightBarButtonItem?.enabled = true
            })
            
            
        }
        task.resume()
        
        
    }
    
    func setCurrentUser()
    {
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            //print(snapshot.value)
            self.currentUser = snapshot.value as! Dictionary<String, AnyObject>
        })
    }
    
    
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue)
    {
        self.navigationController?.navigationBarHidden = false
    
        if segue.identifier == "cancel" {
            
            if self.countryName == "texas" {
                
                self.navigationController?.navigationBarHidden = true
                
                let alertController = UIAlertController(title: "Oops. There was a problem.", message: "There was something wrong with the city information you provided. Try again or change the selected city.", preferredStyle: .Alert)
                
                
                let OKAction = UIAlertAction(title: "Try Again", style: .Default) { (action) in
                    
                    // redirect user back to ChangeCityViewController to choose another city

                    
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    
                }
            }
            
        }
        
    }
    
    
    
    // MARK: change user location delegate method
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String) {
        print("Change Location")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            
            // clean incoming city string
            
            self.givenCity = didChangeCity
            let removeBlanksCity = self.givenCity!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let cleanCity = removeBlanksCity.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            self.locality = cleanCity
            
            // clean incoming region/state/province string
            
            self.givenState = didChangeRegion
            let removeBlanksState = self.givenState!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let cleanState = removeBlanksState.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            self.region = cleanState
            
            // clean incoming country string
            
            self.givenCountry = didChangeCountry
            let countryLowercase = self.givenCountry!.lowercaseString
            let removeBlanksCountry = countryLowercase.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            
            if (removeBlanksCountry == "united states" || removeBlanksCountry == "usa" || removeBlanksCountry == "us" || removeBlanksCountry == "america" || removeBlanksCountry == "united states of america") {
                self.countryName = "us"
            }
            else if (removeBlanksCountry == "canada" || removeBlanksCountry == "can" || removeBlanksCountry == "ca")
            {
                self.countryName = "ca"
            } else {
                self.countryName = "texas"
            }
            
            // update self.title with nice looking city name
            
            let cityWithPlus = cleanCity.stringByReplacingOccurrencesOfString("+", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let cityWithCapitals = cityWithPlus.capitalizedString
            
            self.navigationItem.title = cityWithCapitals
            
            // call breweryDB api to build new city detail
            
            self.accessBreweryDB()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // flush out old city array data
                self.breweries = []
                self.breweryObjects = []
                self.navigationController?.navigationBarHidden = false
                self.view.userInteractionEnabled = false
                self.view.addSubview(self.progressHUD)
                self.mapView.hidden = true
                self.tableView.hidden = false
                self.mapSegmentControl.selectedSegmentIndex = 0
                self.mapView.removeAnnotations(self.annotations)
                self.view.addGestureRecognizer(self.tap)
                self.tableView.reloadData()
                
            })
            
        }
        
    }
    
    func changeCity()
    {
        self.performSegueWithIdentifier("changeCity", sender: self.view)
        
    }
    
    @IBAction func handleTap(recognizer:UIGestureRecognizer)
    {
        performSegueWithIdentifier("toDetailViewController", sender: recognizer)
    }
    
    @IBAction func showBreweryComments(recognizer: UIGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            performSegueWithIdentifier("toCommentViewController", sender: recognizer)
        }
    }
    
    
    // MARK: tableview cell display logic
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.breweryObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let brewery = breweryObjects[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BreweryCellID") as? BreweryCell {
            cell.configureCell(brewery)
            self.progressHUD.removeFromSuperview()  //remove activity spinner and label
            self.view.userInteractionEnabled = true
            
            return cell
            
        } else {
            return BreweryCell()
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "changeCity")
        {
            let dvc = segue.destinationViewController as? ChangeCityViewController
            dvc!.delegate = self
            dvc?.breweryLatitude = 41.89374
            dvc?.breweryLongitude = -87.63533
            
        }
        else if(segue.identifier == "toDetailViewController")
        {
            let point = self.tableView.convertPoint((sender?.locationInView(self.tableView))!, fromView:self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(point)
            let dvc = segue.destinationViewController as? DetailViewController
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! BreweryCell
            dvc?.breweryDetail = cell.brewery
            
        }
        else if (segue.identifier == "toCommentViewController")
        {
            let point = self.tableView.convertPoint((sender?.locationInView(self.tableView))!, fromView:self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(point)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! BreweryCell
            let commentsVC = segue.destinationViewController as! CommentViewController
            commentsVC.brewery = cell.brewery
        }
        else if (segue.identifier == "map") {
            let dvc = segue.destinationViewController as? mapViewController
            dvc?.title = self.navigationItem.title
            dvc?.breweryObjects = self.breweryObjects
            
        }
        
    }
    
    @IBAction func mapSegmentControlTapped(sender: AnyObject) {
        
        
        if (self.mapSegmentControl.selectedSegmentIndex == 0) {
            
            self.mapView.hidden = true
            self.tableView.hidden = false
            self.averageLatitude = 0
            self.averageLongitude = 0
            self.mapView.removeAnnotations(annotations)
            self.view.addGestureRecognizer(tap)
            
            //  self.mapView.removeAnnotations(mapView.annotations)
            self.backgroundImageView.hidden = false
            
        } else if (self.mapSegmentControl.selectedSegmentIndex == 1) {
            // add annotations to mapView by looping through the array
            for brewery in self.breweryObjects
            {
                
                self.dropPinForLocation(brewery)
                
                self.averageLatitude = self.averageLatitude + brewery.latitude!
                self.averageLongitude = self.averageLongitude + brewery.longitude!
            }
            self.averageLatitude = self.averageLatitude / Double(self.breweryObjects.count)
            self.averageLongitude = self.averageLongitude / Double(self.breweryObjects.count)
            self.centerAnnotation.coordinate = CLLocationCoordinate2DMake(self.averageLatitude, self.averageLongitude)
            self.mapView.setRegion(MKCoordinateRegionMake(self.centerAnnotation.coordinate, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
            
            self.mapView.hidden = false
            self.tableView.hidden = true
            self.backgroundImageView.hidden = true
            
            self.view.removeGestureRecognizer(tap)
        }
        
        
    }
    
    @IBAction func onLogoutButtonPressed(sender: UIBarButtonItem)
    {
        let logoutAlert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout", preferredStyle: .Alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default) { (action) -> Void in
            
            FirebaseConnection.firebaseConnection.CURRENT_USER_REF.unauth()
            self.userDefaults.setValue(nil, forKey: "uid")
            // Return to login screen
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login")
            self.presentViewController(vc!, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        logoutAlert.addAction(logoutAction)
        logoutAlert.addAction(cancelAction)
        
        self.presentViewController(logoutAlert, animated: true, completion: nil)
    }
    
    func dropPinForLocation(brewery: Brewery)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(brewery.latitude!, brewery.longitude!)
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
                let breweryCoordinates = CLLocationCoordinate2DMake(brewery.latitude!, brewery.longitude!)
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
