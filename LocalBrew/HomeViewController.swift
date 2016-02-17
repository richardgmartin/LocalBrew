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
    
    // set chicago as the default localbrew location
    // this will change when we activate location tracking and, provided the user approves, set the city based on location
    
    var locality: String?
    var region: String?
    var countryName: String?
    
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
        "NL":"newfoundland+labrador",
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
    
        // set banner name to be city name
        
        self.title = self.locality
        
        // set delegate relationship with ChangeCityViewController
        
        changeCityController?.delegate = self
        
        // call breweryDB api to build list of micro breweries in a specific city
       
 
    
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
            
            self.accessBreweryDB()
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
                //print(localBrew)
                
                self.breweries = localBrew.objectForKey("data") as! [NSDictionary]
                for dict: NSDictionary in self.breweries {
                    let breweryObject: Brewery = Brewery(dataDictionary: dict)
                    self.breweryObjects.append(breweryObject)
                    
                    var iteration = 0
                    for brew in self.breweryObjects
                    {
                        print("At index \(iteration) in brewery objects array. Brewery name: \(brew.name)")
                        // Check if Firebase has specific brewery
                        FirebaseConnection.firebaseConnection.BREWERY_REF.observeEventType(.Value, withBlock: { snapshots in
                            for snapshot in snapshots.children.allObjects as![FDataSnapshot]
                            {
                                print(snapshot.value!["name"] as! String)
                                
                                if snapshot.value!["name"] as? String == brew.name
                                {
                                    print("Brewery is already in firebase.")
                                }
                            }
                             iteration = iteration+1
                        })
                        
                         //Add brewery
//                        let newBrewery = ["name":brew.name, "locality":brew.locality, "region":brew.region, "latitude":brew.latitude, "longitude":brew.longitude, "isOrganic":brew.isOrganic]
//                        FirebaseConnection.firebaseConnection.createNewBrewery(newBrewery as! Dictionary<String, AnyObject>)
                   
                        
                    }
                    
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
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.observeSingleEventOfType( FEventType.Value) { (snapshot : FDataSnapshot!) -> Void in
            
            //print(snapshot.value)
            self.currentUser = snapshot.value as! Dictionary<String, AnyObject>
        }
    }
    
    // MARK: change user location delegate method
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String) {
        
        // flush out old city array data
        
        self.breweries = []
        self.breweryObjects = []

        
        // Update Data Source
        self.locality = didChangeCity
        self.region = didChangeRegion
        self.countryName = didChangeCountry
        
        self.title = self.locality
        
        
        // call breweryDB api to build new city detail
        
        accessBreweryDB()
        
        
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
        
    }
    
    @IBAction func onLogoutButtonPressed(sender: UIBarButtonItem)
    {
        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.unauth()
        
         // Return to login screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(vc!, animated: true, completion: nil)
    }

}
