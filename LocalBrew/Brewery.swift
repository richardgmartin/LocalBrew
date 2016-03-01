//
//  Brewery.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-13.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class Brewery {
    
    var name: String
    var breweryID: String
    var firebaseID: String?
    var streetAddress: String?
    var locality: String?             // city or town
    var region: String?                // state or province
    var postalCode: String            // zip or postal code
    var countryName: String?           // country
    var website: String?
    var latitude: Double?
    var longitude: Double?
    var breweryDescription: String
    var isOrganic: String           // 'N' or 'Y'
    var breweryImageIcon: UIImage?
    var breweryImageSquareMedium: UIImage?
    var breweryImageLarge: UIImage?
    var phoneNumber: String
    var beers:[Beer]?
    var distance: Double?

    
    
    
    
    
   
    
    init(dataDictionary: NSDictionary, userLocation:CLLocation?)
    {
        
        let breweryDictionary = dataDictionary["brewery"]
        let locationDictionary = dataDictionary["country"]
        //let imageDictionary = breweryDictionary!["images"]
        name = breweryDictionary!["name"] as! String
        breweryID = breweryDictionary!["id"] as! String
        locality = dataDictionary["locality"] as? String
        region = dataDictionary["region"] as? String
        countryName = locationDictionary!["displayName"] as? String
        latitude = dataDictionary["latitude"] as? Double
        longitude = dataDictionary["longitude"]as? Double
        isOrganic = breweryDictionary!["isOrganic"] as! String
        
        
        if(userLocation != nil)
        {
            distance = userLocation!.distanceFromLocation(CLLocation(latitude: self.latitude!, longitude: self.longitude!))
        }
        //print(self.distance)
        
        
    
        if let streetAddress = dataDictionary["streetAddress"] as? String {
            self.streetAddress = streetAddress
        } else {
            self.streetAddress = "No Address"
        }
        if let phoneNumber = dataDictionary["phone"] as? String {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = "Unavailable number"
        }
        
        if let postalCode = dataDictionary["postalCode"] as? String {
            self.postalCode = postalCode
        } else {
            self.postalCode = "Sorry. The brewery did not provide us a zipcode or postal code."
        }
        
        if let website = breweryDictionary!["website"] as? String {
            self.website = website
        } else {
            self.website = "No Website"
        }
        
        if let breweryDescription = breweryDictionary!["description"] as? String {
            self.breweryDescription = breweryDescription
        } else {
            self.breweryDescription = "Sorry. The brewery did not provide us with a description."
        }
        if let imageDictionary = breweryDictionary!["images"] as? NSDictionary
        {
//             Icon Image
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
//            if let squareMediumImageString = imageDictionary["squareMedium"] as? String
//            {
//                if let url = NSURL(string: squareMediumImageString)
//                {
//                    if let data = NSData(contentsOfURL: url)
//                    {
//                        self.breweryImageSquareMedium = UIImage(data: data)
//                    }
//                }
//                
//            }
            
            // large image
//            if let largeImageString = imageDictionary["large"] as? String
//            {
//                if let url = NSURL(string: largeImageString)
//                {
//                    if let data = NSData(contentsOfURL: url)
//                    {
//                        self.breweryImageLarge = UIImage(data: data)
//                    }
//                }
//            }
            
        }
        else
        {
            self.breweryImageIcon = UIImage(named: "Beer")
        }
        
        
        FirebaseConnection.firebaseConnection.BREWERY_REF.queryOrderedByChild("breweryID").queryEqualToValue(self.breweryID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.children.allObjects.isEmpty
            {
                let firebaseKey = snapshot.children.allObjects[0].key as String!
                self.firebaseID = firebaseKey
            }
            
        })
   
        
    }
    
    init(dictionary:NSDictionary)
    {
        name = dictionary["name"] as! String
        breweryID = dictionary["id"] as! String
       
        latitude = dictionary["latitude"] as? Double
        isOrganic = dictionary["isOrganic"] as! String
        
        
        if let realLocality = dictionary["locality"]
        {
            locality = realLocality as? String
        }
        
        if let realRegion = dictionary["region"]
        {
            region = realRegion as? String
        }
        
        if let realCountryName = dictionary["displayName"]
        {
            countryName = realCountryName as? String
        }
        
        if let realLongitude = dictionary["longitude"]
        {
            longitude = realLongitude as? Double
        }
        
        if let realLatitude = dictionary["latitude"]
        {
            latitude = realLatitude as? Double
        }
        
        
        
        if let streetAddress = dictionary["streetAddress"] as? String
        {
            self.streetAddress = streetAddress
        }
        else
        {
            self.streetAddress = "No Address"
        }
        
        if let streetAddress = dictionary["streetAddress"] as? String
        {
            self.streetAddress = streetAddress
        }
        else
        {
            self.streetAddress = "No Address"
        }
        if let phoneNumber = dictionary["phone"] as? String
        {
            self.phoneNumber = phoneNumber
        }
        else
        {
            self.phoneNumber = "Unavailable number"
        }
        
        if let postalCode = dictionary["postalCode"] as? String
        {
            self.postalCode = postalCode
        }
        else
        {
            self.postalCode = "Sorry. The brewery did not provide us a zipcode or postal code."
        }
        
        if let website = dictionary["website"] as? String
        {
            self.website = website
        }
        else
        {
            self.website = "No Website"
        }
        
        if let breweryDescription = dictionary["description"] as? String
        {
            self.breweryDescription = breweryDescription
        }
        else
        {
            self.breweryDescription = "Sorry. The brewery did not provide us with a description."
        }
        if let imageDictionary = dictionary["images"] as? NSDictionary
        {
            //             Icon Image
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
        }
    }
}




