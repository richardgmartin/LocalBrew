//
//  ViewController.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-13.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var breweries = [NSDictionary]()
    var breweryObjects = [Brewery]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: logic to import breweryDB data
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/locations?locality=chicago&region=illinois&countryIsoCode=US&key=6f75023f91495f22253de067b9136d1d")
        
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

}

