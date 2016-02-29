//
//  ProfileViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/13/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{


    @IBOutlet weak var userMapView: MKMapView!
    @IBOutlet weak var likedBreweriesTableView: UITableView!
    @IBOutlet weak var likedBeersTableView: UITableView!
    var likedBeersArray = NSMutableArray()
    var likedBreweriesArray = NSMutableArray()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let username = userDefaults.objectForKey("username") as? String
        
        self.navigationItem.title = username
        
        self.likedBreweriesArray = []
        self.likedBeersArray = []
        
        getLikedBreweries()
        getLikedBeers()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView == self.likedBeersTableView
        {
            count = self.likedBeersArray.count
        }
        else if tableView == self.likedBreweriesTableView
        {
            count = self.likedBreweriesArray.count
        }
        
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        if tableView == self.likedBreweriesTableView
        {
            let brewery = likedBreweriesArray[indexPath.row] as? LikedBrewery
            
            cell = tableView.dequeueReusableCellWithIdentifier("LikedBreweryCell")
            cell.textLabel?.text = brewery!.name
        }
        else if tableView == self.likedBeersTableView
        {
            let beer = likedBeersArray[indexPath.row] as? LikedBeer
            
            cell = tableView.dequeueReusableCellWithIdentifier("LikedBeerCell")
            cell.textLabel?.text = beer!.name
        }
        
        return cell!
    }
    
    func getLikedBreweries()
    {
        
        let likedBreweryRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbreweries")
        
        likedBreweryRef.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot)
            for snap in snapshot!.children!.allObjects
            {
                let key = snap.key as String!
                //let realKey = "-\(key)" as String!
                //print(key)
                FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    self.getBreweriesFromAPI(snapshot.value.allObjects[3] as! String)
                })
            }
        })
    }
    
    func getLikedBeers()
    {
        
        let likedBeerRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbeers")
        
        likedBeerRef.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot)
            for snap in snapshot!.children!.allObjects
            {
                let key = snap.key as String!
                
                FirebaseConnection.firebaseConnection.BEER_REF.childByAppendingPath(key).observeEventType(.Value, withBlock: {
                    snapshot in
                     print(snapshot)
                    self.getBeersFromAPI(snapshot.value.allObjects[1] as! String)
                })
            }
        })
    }
    
    
    func getBreweriesFromAPI(breweryID:String)
    {
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/brewery/\(breweryID)?key=6f75023f91495f22253de067b9136d1d")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
             do
             {
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                //print(localBrew["data"]!)
                
                let breweryObject: LikedBrewery = LikedBrewery(dictionary: localBrew["data"] as!NSDictionary)
                self.likedBreweriesArray.addObject(breweryObject)
                
            }
             catch let error as NSError{
                print(error)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                //print(self.likedBreweriesArray.count)
                self.likedBreweriesTableView.reloadData()
                
            })
            
            
        }
        task.resume()
        
    }
    
    
    func getBeersFromAPI(beerID:String)
    {
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/beer/\(beerID)?key=6f75023f91495f22253de067b9136d1d")
        
        print(url!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do
            {
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                //print(localBrew["data"]!)
                
                let beerObject: LikedBeer = LikedBeer(dict: localBrew["data"] as!NSDictionary)
                self.likedBeersArray.addObject(beerObject)
                
            }
            catch let error as NSError{
                print(error)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                //print(self.likedBreweriesArray.count)
                self.likedBeersTableView.reloadData()
                
            })
            
            
        }
        task.resume()
        
    }
    

}
