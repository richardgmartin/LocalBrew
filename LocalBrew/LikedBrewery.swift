//
//  LikedBrewery.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/26/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class LikedBrewery: NSObject {
    
    var breweryDescription:String!
    var establishDate:String?
    var name:String!
    var breweryID:String!
    var status:String!
    var statusDisplayed:String!
    var website:String!
    var isOrganic:String!    
    
    init(dictionary:NSDictionary)
    {
        breweryDescription = dictionary["description"] as! String
        name = dictionary["name"] as! String
        breweryID = dictionary["id"] as! String
        if dictionary["established"] != nil
        {
            establishDate = dictionary["established"] as? String
        }
        isOrganic = dictionary["isOrganic"] as! String
        
        
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
    }
}
