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


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, ChangeCityViewControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBOutlet weak var changeCityButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var breweries = [NSDictionary]()
    var breweryObjects = [Brewery]()
    var locationManager = CLLocationManager()
    var currentUser = Dictionary<String, AnyObject>()
    var locality: String?
    var region: String?
    var countryName: String?
    
    var givenCity: String?
    var givenState: String?
    var givenCountry: String?
    var snapshotsArray:NSArray!
    let progressHUD = ProgressHUD(text: "Brewing")
    var changeCityController: ChangeCityViewController?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var longPress = UILongPressGestureRecognizer()
    var tap = UITapGestureRecognizer()
    
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
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.fromHexString("#040f0f", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.fromHexString("#FAFAFA", alpha: 1.0)]
        self.setCurrentUser()
        
        self.navigationController?.navigationBar.tintColor = UIColor.fromHexString("#41EAD4", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
    
        
    }
   
    // MARK : - Location manager delogates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            reversGeocode(location!)
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func reversGeocode(location: CLLocation)
    {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
        
            let placemark = placemarks?.first
            let address = "\(placemark!.locality!) \(placemark!.administrativeArea!) \(placemark!.country!)"

            
            self.locality = String(UTF8String: (placemark?.locality)!)!
            let placemarkRegion = String(UTF8String: placemark!.administrativeArea!)!
            let placemarkCountry = String(UTF8String: (placemark?.country)!)
            
            if placemarkCountry == "United States" {
                self.countryName = "us"
            } else {
                self.countryName = "ca"
            }
            
           // print(placemarkRegion)
            
//              var key = placemark?.administrativeArea
                for (key,value) in self.nameAbbreviations
                {
                    if key == placemarkRegion
                    {
                        self.region = value
                        //print(value)
                    }
                }
            self.title = self.locality?.capitalizedString
            //print(self.locality)
            //print(self.region)
            //print(self.countryName)
            self.accessBreweryDB()
        })
      
        
    }
    
    func accessBreweryDB()
    {
        // MARK: logic to import breweryDB data
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/locations?locality=\(self.locality!)&region=\(self.region!)&countryIsoCode=\(self.countryName!)&key=324f8ff71fe7f84fab3655aeab07f01c")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
               print(localBrew["data"])
                
                
                self.breweries = localBrew.objectForKey("data") as! [NSDictionary]
                for dict: NSDictionary in self.breweries
                {
                    let breweryObject: Brewery = Brewery(dataDictionary: dict)
                    self.breweryObjects.append(breweryObject)
                }
            }
            catch let error as NSError{
                print("JSON Error: \(error.localizedDescription)")
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                
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
        self.view.addSubview(progressHUD)
    }
    
    

    // MARK: change user location delegate method
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String) {
        
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
            }
            
            // update self.title with nice looking city name
            
            let cityWithPlus = cleanCity.stringByReplacingOccurrencesOfString("+", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let cityWithCapitals = cityWithPlus.capitalizedString
            
            self.title = cityWithCapitals
            
            // call breweryDB api to build new city detail
            
            self.accessBreweryDB()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // flush out old city array data
                self.breweries = []
                self.breweryObjects = []
                
                self.tableView.reloadData()

            })
            
        }
        
        
        
    }
    
    @IBAction func handleTap(recognizer:UIGestureRecognizer)
    {
        performSegueWithIdentifier("toDetailViewController", sender: self.view)
    }
    
    @IBAction func showBreweryComments(recognizer: UIGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            performSegueWithIdentifier("toCommentViewController", sender: self.view)
        }
    }
    
        
    // MARK: tableview cell display logic

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.breweries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let brewery = breweryObjects[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BreweryCellID") as? BreweryCell {
            cell.configureCell(brewery)
            self.progressHUD.removeFromSuperview()  //remove activity spinner and label
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
        }
       else if(segue.identifier == "toDetailViewController")
        {
            let dvc = segue.destinationViewController as? DetailViewController
             let point = self.tableView.convertPoint(sender!.frame.origin, fromView:sender?.superview)
            let indexPath = self.tableView.indexPathForRowAtPoint(point)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! BreweryCell
            dvc?.breweryDetail = cell.brewery
            
        }
        else if (segue.identifier == "toCommentViewController")
        {
            let point = self.tableView.convertPoint(sender!.frame.origin, fromView:sender?.superview)
            let indexPath = self.tableView.indexPathForRowAtPoint(point)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! BreweryCell
            let commentsVC = segue.destinationViewController as! CommentViewController
            commentsVC.brewery = cell.brewery
        }
        
    }
    
    
    
    @IBAction func onLogoutButtonPressed(sender: UIBarButtonItem)
    {
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.unauth()
        self.userDefaults.setValue(nil, forKey: "uid")
         // Return to login screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
   }
