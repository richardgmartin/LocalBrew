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
    @IBOutlet weak var beerCellLikeButton: UIButton!

    var beer: Beer!
    var brewery:Brewery!
    
    func configureCell(beer: Beer, beerBrewery: Brewery) {
        self.beer = beer
        self.beerCellImageView.image = beer.beerImageIcon
        self.beerCellName.text = beer.beerName
        self.beerCellStyle.text = beer.style
        self.beerCellLikeButton.imageView?.image = UIImage(named: "beerEmpty")
        self.brewery = beerBrewery
        
        if beer.firebaseID == nil
        {
            FirebaseConnection.firebaseConnection.createNewBeer(self.brewery, beer: self.beer)
        }
        
        FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.brewery.firebaseID).childByAppendingPath("beers").childByAppendingPath(beer.firebaseID).childByAppendingPath("numberOfLikes").observeEventType(.Value, withBlock: { snapshot in
            
            let likes = snapshot.value as! Int
            
            self.beerLikeLabel.text = "Likes: \(likes)"
        })
        
        
        
        let likedBeerRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbeers")
        
        likedBeerRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists())
            {
                likedBeerRef.childByAppendingPath(self.beer.firebaseID).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    if snapshot.exists()
                    {
                        self.beerCellLikeButton.imageView?.image = UIImage(named: "beerFull")
                    }
                    else
                    {
                        self.beerCellLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                    }
                })
            }
            
        })
        
    }
    
    
    func likeBeer()
    {
        
        let likedBeerRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbeers").childByAppendingPath(self.beer.firebaseID)
        let likedBeer = self.beer
        
        var liked:Bool = true
        
        likedBeerRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists()
            {
                likedBeerRef.removeValue()
                self.beerCellLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                liked = false
            }
            else
            {
                likedBeerRef.setValue(["beerName":likedBeer.beerName])
                self.beerCellLikeButton.imageView?.image = UIImage(named: "beerFull")
            }
            
            let beerRef = FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.brewery.firebaseID).childByAppendingPath("beers")
            
            beerRef.childByAppendingPath(self.beer.firebaseID).childByAppendingPath("numberOfLikes").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let numlikes = snapshot.value as! Int
                
                if liked
                {
                    beerRef.childByAppendingPath(self.beer.firebaseID).updateChildValues(["numberOfLikes":numlikes+1])
                }
                else
                {
                    beerRef.childByAppendingPath(self.beer.firebaseID).updateChildValues(["numberOfLikes":numlikes-1])
                }
                
            })
            
        })
        
        
    }
    
    
    @IBAction func onBeerButtonTapped(sender: UIButton)
    {
               
        self.likeBeer()
    }
}
