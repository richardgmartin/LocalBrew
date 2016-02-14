//
//  ViewController.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-13.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeCityViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var breweries = [NSDictionary]()
    var breweryObjects = [Brewery]()
    
    // set chicago as the default localbrew location
    // this will change when we activate location tracking and, provided the user approves, set the city based on location
    
    var locality: String = "perth"
    var region: String = "ontario"
    var countryName: String = "ca"
    
    var changeCityController: ChangeCityViewController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegate relationship with ChangeCityViewController
        
        changeCityController?.delegate = self
        
        // call breweryDB api to build list of micro breweries in a specific city
        
        accessBreweryDB()
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tableView.reloadData()
        
    }
    
    func accessBreweryDB() {
        
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
    
    // MARK: change user location delegate method
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String) {
        
        // Update Data Source
        self.locality = didChangeCity
        self.region = didChangeRegion
        self.countryName = didChangeCountry
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dvc = segue.destinationViewController as? ChangeCityViewController
        dvc!.delegate = self
        
    }

}

