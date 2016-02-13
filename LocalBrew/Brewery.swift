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
    var streetAddress: String?
    var locality: String              // city or town
    var region: String                // state or province
    var postalCode: String            // zip or postal code
    var displayName: String           // country
    var website: String?
    var latitute: Double
    var longitude: Double
    var breweryDescription: String
    var isOrganic: String             // 'N' or 'Y'
    
    
    
    init(dataDictionary: NSDictionary ) {
        let breweryDictionary = dataDictionary["brewery"]
        let locationDictionary = dataDictionary["country"]
        
        name = breweryDictionary!["name"] as! String
        locality = dataDictionary["locality"] as! String
        region = dataDictionary["region"] as! String
        displayName = locationDictionary!["displayName"] as! String
        latitute = dataDictionary["latitude"] as! Double
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
    }
}



