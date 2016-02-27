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
   
    @IBOutlet weak var beerLikeLabel: UILabel!
    @IBOutlet weak var beerCellStyle: UILabel!
    @IBOutlet weak var beerCellName: UILabel!

    var beer: Beer!
    var brewery:Brewery!
    
    func configureCell(beer: Beer, beerBrewery: Brewery)
    {
        self.beer = beer
        self.beerCellImageView.image = beer.beerImageIcon
        self.beerCellName.text = beer.beerName
        self.beerCellStyle.text = beer.style
       
        self.brewery = beerBrewery
        
        if beer.firebaseID == nil
        {
            FirebaseConnection.firebaseConnection.createNewBeer(self.brewery, beer: self.beer)
        }
        
        FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.brewery.firebaseID).childByAppendingPath("beers").childByAppendingPath(beer.firebaseID).childByAppendingPath("numberOfLikes").observeEventType(.Value, withBlock: { snapshot in
            
            let likes = snapshot.value as! Int
            
            self.beerLikeLabel.text = "Likes: \(likes)"
        })
        
    }
    
    

}
