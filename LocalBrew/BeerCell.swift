//
//  BeerCell.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/17/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import Foundation
import UIKit

class BeerCell: UITableViewCell {
    
    @IBOutlet weak var beerCellImageView: UIImageView!
    @IBOutlet weak var beerCellFavorites: UILabel!
    @IBOutlet weak var beerCellStyle: UILabel!
    @IBOutlet weak var beerCellName: UILabel!


    var beer: Beer!
    
    
    
    func configureCell(beer: Beer) {
        self.beer = beer
        self.beerCellFavorites.text = "Favorites 0"
        self.beerCellImageView.image = beer.beerImageIcon
        self.beerCellName.text = beer.beerName
        self.beerCellStyle.text = beer.style

        
    }
}
