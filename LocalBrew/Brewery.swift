//
//  Brewery.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-13.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit



class Brewery {
    
    var name: String
    var breweryID: String
    var streetAddress: String?
    var locality: String              // city or town
    var region: String                // state or province
    var postalCode: String            // zip or postal code
    var countryName: String           // country
    var website: String?
    var latitude: Double
    var longitude: Double
    var breweryDescription: String
    var isOrganic: String           // 'N' or 'Y'
    var breweryImageIcon: UIImage?
    var breweryImageSquareMedium: UIImage?
    var breweryImageLarge: UIImage?
    
    
    init(dataDictionary: NSDictionary ) {
        
        let breweryDictionary = dataDictionary["brewery"]
        let locationDictionary = dataDictionary["country"]
        //let imageDictionary = breweryDictionary!["images"]
        name = breweryDictionary!["name"] as! String
        breweryID = breweryDictionary!["id"] as! String
        locality = dataDictionary["locality"] as! String
        region = dataDictionary["region"] as! String
        countryName = locationDictionary!["displayName"] as! String
        latitude = dataDictionary["latitude"] as! Double
        longitude = dataDictionary["longitude"]as! Double
        isOrganic = breweryDictionary!["isOrganic"] as! String
        
    
        if let streetAddress = dataDictionary["streetAddress"] as? String {
            self.streetAddress = streetAddress
        } else {
            self.streetAddress = "Sorry. The brewery did not provide us a street address."
        }
        
        if let postalCode = dataDictionary["postalCode"] as? String {
            self.postalCode = postalCode
        } else {
            self.postalCode = "Sorry. The brewery did not provide us a zipcode or postal code."
        }
        
        if let website = breweryDictionary!["website"] as? String {
            self.website = website
        } else {
            self.website = "Sorry. The brewery did not provide us with a website address."
        }
        
        if let breweryDescription = breweryDictionary!["description"] as? String {
            self.breweryDescription = breweryDescription
        } else {
            self.breweryDescription = "Sorry. The brewery did not provide us with a description."
        }
        if let imageDictionary = breweryDictionary!["images"] as? NSDictionary
        {
            // Icon Image
            if let iconImageString = imageDictionary["icon"] as? String
            {
                if let url = NSURL(string: iconImageString)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        self.breweryImageIcon = UIImage(data: data)
                    }
                }
            }
            
            // square medium image
            if let squareMediumImageString = imageDictionary["squareMedium"] as? String
            {
                if let url = NSURL(string: squareMediumImageString)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        self.breweryImageSquareMedium = UIImage(data: data)
                    }
                }
                
            }
            
            // large image
            if let largeImageString = imageDictionary["large"] as? String
            {
                if let url = NSURL(string: largeImageString)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        self.breweryImageLarge = UIImage(data: data)
                    }
                }
            }
            
        }
        else
        {
            self.breweryImageIcon = UIImage(named: "Beer")
        }
        
    }
}



