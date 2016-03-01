//
//  LikedBeer.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/26/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class LikedBeer: NSObject {
    
    var name:String!
    var isOrganic:String?
    
    
    init(dict: NSDictionary)
    {
        name = dict["name"] as! String
        
        if let organic = dict["isOrganic"]
        {
            isOrganic = organic as? String
        }
    }
    
    
    
    

}
