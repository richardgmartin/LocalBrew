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
    @IBOutlet weak var yourLikedBreweries: UILabel!

    @IBOutlet weak var yourLikedBeers: UILabel!

    @IBOutlet weak var likedBreweriesTableView: UITableView!
    @IBOutlet weak var likedBeersTableView: UITableView!
    var likedBeersArray = NSMutableArray()
    var likedBreweriesArray = NSMutableArray()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad()
    {
        //print("View Did Load")
        super.viewDidLoad()
        
        let username = userDefaults.objectForKey("username") as? String
        
        self.navigationItem.title = username
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.fromHexString("#960200", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.fromHexString("#FAFAFF", alpha: 1.0)]
        
        self.navigationController?.navigationBar.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
//        self.automaticallyAdjustsScrollViewInsets = false
        self.likedBeersTableView.backgroundColor = UIColor.clearColor()
        self.likedBreweriesTableView.backgroundColor = UIColor.clearColor()
        self.yourLikedBeers.font = UIFont.boldSystemFontOfSize(20.0)
        self.yourLikedBreweries.font = UIFont.boldSystemFontOfSize(20.0)

        
        

        getLikedBreweries()
        getLikedBeers()

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //print("View Did Appear")
    }
    
    override func viewWillAppear(animated: Bool)
    {
        
        super.viewWillAppear(animated)
        //print("View Will Appear")
        
        
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
            cell.imageView?.image = brewery?.iconImage
        }
        else if tableView == self.likedBeersTableView
        {
            let beer = likedBeersArray[indexPath.row] as? LikedBeer
            
            cell = tableView.dequeueReusableCellWithIdentifier("LikedBeerCell")
            cell.textLabel?.text = beer!.name
            cell.imageView?.image = beer?.iconImage
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
                    
                    //print(snapshot.value)
                    //print(snapshot.value.allObjects[3] as! String)
                    //print(snapshot.value.count)
                    
                    if snapshot.value.count > 3
                    {
                        self.getBreweriesFromAPI(snapshot.value.allObjects[3] as! String)
                    }
                    else
                    {
                        self.getBreweriesFromAPI(snapshot.value.allObjects[2] as! String)
                    }
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
                
                FirebaseConnection.firebaseConnection.BEER_REF.childByAppendingPath(key).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                     //print(snapshot)
                    self.getBeersFromAPI(snapshot.value.allObjects[1] as! String)
                })
            }
        })
    }
    
    
    func getBreweriesFromAPI(breweryID:String)
    {
        print("Calling API")
        self.likedBreweriesArray = []
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/brewery/\(breweryID)?key=bf670c4b0636d4565fbb0feb6eb6bf8c")
        
        //print(url!)
        
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
        //print("Calling API")
        self.likedBeersArray = []
        
        let url = NSURL(string: "http://api.brewerydb.com/v2/beer/\(beerID)?key=bf670c4b0636d4565fbb0feb6eb6bf8c")
        
        //print(url!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do
            {
                let localBrew = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                //print(localBrew["data"]!)
                
                let beerObject:LikedBeer = LikedBeer(dict: localBrew["data"] as! NSDictionary)
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
    
    @IBAction func handleTap(recognizer:UIGestureRecognizer)
    {
        let point = recognizer.locationInView(self.view)
        
        if CGRectContainsPoint(self.likedBreweriesTableView.frame, point)
        {
            performSegueWithIdentifier("toLikedBreweryDetail", sender: recognizer)
        }
        else if CGRectContainsPoint(self.likedBeersTableView.frame, point)
        {
            performSegueWithIdentifier("toLikedBeerDescription", sender: recognizer)
        }
    }
    
    @IBAction func showComments(recognizer: UIGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            performSegueWithIdentifier("fromProfile", sender: recognizer)
        }
    }
    
    
    
    

}
