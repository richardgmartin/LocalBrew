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
    
    init(beerDataDictionary: NSDictionary) {
        beerName = beerDataDictionary["name"] as! String
    }
}