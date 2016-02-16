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
    
    var locality: String = "ottawa"
    var region: String = "ontario"
    var countryName: String = "ca"
    
    var changeCityController: ChangeCityViewController?
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setCurrentUser()
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        // set banner name to be city name
        
        self.title = self.locality
        
        // set delegate relationship with ChangeCityViewController
        
        changeCityController?.delegate = self
        
        // call breweryDB api to build list of micro breweries in a specific city
        
        accessBreweryDB()
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tableView.reloadData()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func accessBreweryDB()
    {
        
        // MARK: logic to import breweryDB data
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/locations?locality=\(self.locality)&region=\(self.region)&countryIsoCode=\(self.countryName)&key=6f75023f91495f22253de067b9136d1d")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do{
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                self.breweries = localBrew.objectForKey("data") as! [NSDictionary]
                
                for dict: NSDictionary in self.breweries {
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
        
        self.tableView.reloadData() 
        
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
        FirebaseConnection.firebaseConnection.BASE_REF.unauth()
        
         // Return to login screen
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(vc!, animated: true, completion: nil)
    }

}
