//
//  LikedBeerViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/29/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class LikedBeerViewController: UIViewController
{
    var beer:LikedBeer!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = beer.name
       
    }

}
