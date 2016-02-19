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


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, ChangeCityViewControllerDelegate {
    
    
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
    
    var changeCityController: ChangeCityViewController?
    
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
       
        //self.setCurrentUser()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // set delegate relationship with ChangeCityViewController
        
        changeCityController?.delegate = self
    
        
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
            self.accessBreweryDB()
        })
      
        
    }
    
    func accessBreweryDB()
    {
        // MARK: logic to import breweryDB data
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/locations?locality=\(self.locality!)&region=\(self.region!)&countryIsoCode=\(self.countryName!)&key=3613cdc782cfe937d78e52b40d98510e")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
               // print(localBrew["data"])
                
                
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
                self.checkFirebaseForBrewery(self.breweryObjects[0])
            })
        }
        task.resume()
        
    }

    
    func checkFirebaseForBrewery(brewery:Brewery)
    {
        
        let ref = FirebaseConnection.firebaseConnection.BREWERY_REF
        ref.queryOrderedByChild("breweryID").queryEqualToValue(brewery.breweryID).observeSingleEventOfType(.Value, withBlock: {snapshots in
            print(snapshots)
            
            if(snapshots.value is NSNull)
            {
                FirebaseConnection.firebaseConnection.createNewBrewery(["breweryID":brewery.breweryID, "name":brewery.name, "numberOfLikes":0])
            }
            else
            {
                for snapshot in snapshots.value.allObjects
                {
                    if snapshot["breweryID"] as! String == brewery.breweryID
                    {
                        print("Value is already in database")
                        return
                    }
                    
                }
                FirebaseConnection.firebaseConnection.createNewBrewery(["breweryID":brewery.breweryID, "name":brewery.name, "numberOfLikes":0])
            }
            
        })
    }

    func setCurrentUser()
    {
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.observeSingleEventOfType( FEventType.Value) { (snapshot : FDataSnapshot!) -> Void in
            
            //print(snapshot.value)
            self.currentUser = snapshot.value as! Dictionary<String, AnyObject>
        }
    }
    
    
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue)
    {
        
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
        
    // MARK: tableview cell display logic

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.breweries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let brewery = breweryObjects[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BreweryCellID") as? BreweryCell {
            cell.configureCell(brewery)
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
        if(segue.identifier == "detailViewController") {
            let dvc = segue.destinationViewController as? DetailViewController
            let index = self.tableView.indexPathForSelectedRow
            dvc?.breweryDetail = self.breweryObjects[(index?.row)!]


            
        }
        
    }
    
    @IBAction func onLogoutButtonPressed(sender: UIBarButtonItem)
    {
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.unauth()
        
         // Return to login screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
   }
