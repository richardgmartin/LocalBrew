//
//  Beer.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-17.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit


class Beer {

    var beerName: String
    var beerImageIcon: UIImage?
    var style: String?
    var beerID: String!
    var firebaseID: String?
    var brewery:Brewery!
    var isOrganic: String?
    var beerDescription: String?

    
    init(beerDataDictionary: NSDictionary, beerBrewery:Brewery) {
        

        let styleDictionary = beerDataDictionary["style"]
        
        
        beerID = beerDataDictionary["id"] as! String
        beerName = (beerDataDictionary["name"] as! String)
        self.brewery = beerBrewery
        

        
        if let style = styleDictionary?["name"] as? String
        {
            self.style = style
        }
        else
        {
            self.style = "Sorry, The style is not available"
        }
        
        if let isOrganic = beerDataDictionary["isOrganic"] as? String {
            self.isOrganic = isOrganic
        } else {
            self.isOrganic = "N"
        }
        if let beerDescription = beerDataDictionary["description"] as? String {
            self.beerDescription = beerDescription
        } else {
            self.beerDescription = "Sorry, The brewery gave no description about this beer."
        }
        
        if let imageDictionary = beerDataDictionary["labels"] as? NSDictionary
        {
            // Icon Image
            if let iconImageString = imageDictionary["icon"] as? String
            {
                if let url = NSURL(string: iconImageString)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        self.beerImageIcon = UIImage(data: data)
                    }
                }
            }
        
        }
        else
        {
            self.beerImageIcon = UIImage(named: "Beer")
        }
        
       
        let beerRef = FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.brewery.firebaseID).childByAppendingPath("beers")
        
        beerRef.queryOrderedByChild("beerID").queryEqualToValue(self.beerID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.children.allObjects.isEmpty
            {
                let firebaseKey = snapshot.children.allObjects[0].key as String!
                self.firebaseID = firebaseKey
            }
            
        })
        
        
    }
    
    
    
    
}