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
    var style: String


    

    
    init(beerDataDictionary: NSDictionary) {
        

        let styleDictionary = beerDataDictionary["style"]
        
        beerName = beerDataDictionary["name"] as! String
        

        
        if let style = styleDictionary?["name"] as? String {
            self.style = style
        } else {
            self.style = "Sorry, The style is not available"
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
        
        } else {
            self.beerImageIcon = UIImage(named: "Beer")
        }
    }
    
    
}