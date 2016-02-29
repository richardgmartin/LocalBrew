//
//  FirebaseConnection.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase

let BASE_URL = "https://localbrew.firebaseio.com/"
let _USER_REF = Firebase(url: "\(BASE_URL)/users")
let _BREWERY_REF = Firebase(url: "\(BASE_URL)/breweries")
let _COMMENT_REF = Firebase(url: "\(BASE_URL)/comments")
let _BEER_REF = Firebase(url: "\(BASE_URL)/beers")

class FirebaseConnection: NSObject
{
    static let firebaseConnection = FirebaseConnection()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    //private var

    var BASE_REF:Firebase {
        return _BASE_REF
    }
    
    var USER_REF:Firebase
    {
        return _USER_REF
    }
    
    var BREWERY_REF:Firebase
    {
        return _BREWERY_REF
    }
    
    var COMMENT_REF:Firebase
    {
        return _COMMENT_REF
    }
    
    var BEER_REF:Firebase
    {
        return _BEER_REF
    }
    
    func createNewAccount(uid: String, user: Dictionary<String, AnyObject>) {
        
        USER_REF.childByAppendingPath(uid).setValue(user)
    }
    
    func createNewBrewery(brewery:Brewery)
    {
       let dict = ["breweryID":brewery.breweryID, "name":brewery.name, "numberOfLikes":0]
        
       let firebaseID = BREWERY_REF.childByAutoId()
        firebaseID.setValue(dict)
        brewery.firebaseID = firebaseID.key
    }
    
    func createNewBeer(brewery:Brewery, beer:Beer)
    {
        // Adding to beers ref
        var dict = ["beerID":beer.beerID, "name":beer.beerName, "numberOfLikes":0, "breweryID": brewery.breweryID]
        
        let firebaseID = BEER_REF.childByAutoId()
        
        firebaseID.setValue(dict)
        
        
        // Adding to brewery Ref
        dict = ["beerID":beer.beerID, "name":beer.beerName, "numberOfLikes":0]
        
        BREWERY_REF.childByAppendingPath(brewery.firebaseID).childByAppendingPath("beers").childByAppendingPath(firebaseID.key).setValue(dict)
        beer.firebaseID = firebaseID.key
    
    }
    
    
    
    var CURRENT_USER_REF: Firebase
    {

        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        let currentUser = Firebase(url: "\(USER_REF)").childByAppendingPath(userID)
        return currentUser!
    }
    
    
    
    

}
