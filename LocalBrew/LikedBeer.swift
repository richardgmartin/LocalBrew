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
    var iconImage:UIImage?
    
    
    init(dict: NSDictionary)
    {
        name = dict["name"] as! String
        
        if let organic = dict["isOrganic"]
        {
            isOrganic = organic as? String
        }
        
        
        if let labelDictionary = dict["labels"]
        {
            if let string = labelDictionary["icon"] as? String
            {
                if let url = NSURL(string: string)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        self.iconImage = UIImage(data: data)
                    }
                }
            }
        }
        else
        {
            self.iconImage = UIImage(named: "Beer")
        }
        
        
        
        
    }
    
    
    
    

}
