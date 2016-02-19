//
//  BreweryCell.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/13/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import Foundation
import UIKit

class BreweryCell: UITableViewCell {
    
    var brewery: Brewery!
    

    @IBOutlet weak var breweryLikeLabel: UILabel!
    @IBOutlet weak var breweryImageView: UIImageView!
    @IBOutlet weak var breweryNameLabel: UILabel!
    @IBOutlet weak var breweryAddressLabel: UILabel!
    @IBOutlet weak var breweryDistanceLabel: UILabel!
    

    
    
    func configureCell(brewery: Brewery) {
        self.brewery = brewery
        self.breweryNameLabel!.text = brewery.name
        self.breweryAddressLabel.text = brewery.streetAddress
        self.breweryDistanceLabel.text = "0.4 miles"
        self.breweryLikeLabel.text = "15 Likes"
        self.breweryImageView.image = brewery.breweryImageIcon

        
    }
}
