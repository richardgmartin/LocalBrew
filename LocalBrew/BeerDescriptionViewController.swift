//
//  BeerDescriptionViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/25/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class BeerDescriptionViewController: UIViewController {

    @IBOutlet weak var beerImageView: UIImageView!
    @IBOutlet weak var beerDescriptionLabel: UILabel!
    @IBOutlet weak var beerDescriptionTextView: UITextView!
    @IBOutlet weak var beerOrganic: UILabel!
    @IBOutlet weak var beerStyle: UILabel!
    @IBOutlet weak var breweryName: UILabel!
    @IBOutlet weak var breweryNameBold: UILabel!
    @IBOutlet weak var beerOrganicBold: UILabel!
    @IBOutlet weak var beerStyleBold: UILabel!
    @IBOutlet weak var beerLikeButton: UIButton!
    

    
    var beerDetail:Beer!
    var breweryDetail:Brewery!
    //var breweryDetailName: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = beerDetail.beerName
        self.beerOrganic.text = beerDetail.isOrganic
        self.beerImageView.image = beerDetail.beerImageIcon
        self.beerDescriptionTextView.text = beerDetail.beerDescription
        self.beerStyle.text = beerDetail.style
        self.breweryName.text = breweryDetail.name
        self.beerDescriptionLabel.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerOrganicBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerStyleBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.breweryNameBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerDescriptionTextView.backgroundColor = UIColor.clearColor()
        
        let likedBeerRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbeers")
        
        likedBeerRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists())
            {
                likedBeerRef.childByAppendingPath(self.beerDetail.firebaseID).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    if snapshot.exists()
                    {
                        self.beerLikeButton.imageView?.image = UIImage(named: "beerFull")
                    }
                    else
                    {
                        self.beerLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                    }
                })
            }
            
        })
    }
    
    
    func likeBeer()
    {
        
        // Add beer to users liked beers
        let likedBeerRef = FirebaseConnection.firebaseConnection.CURRENT_USER_REF.childByAppendingPath("likedbeers").childByAppendingPath(self.beerDetail.firebaseID)
        
        let likedBeer = self.beerDetail
        
        var liked:Bool = true
        
        likedBeerRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            print("1.")
            
            if snapshot.exists()
            {
                likedBeerRef.removeValue()
                self.beerLikeButton.imageView?.image = UIImage(named: "beerEmpty")
                liked = false
            }
                
            else
            {
                likedBeerRef.setValue(["beerName":likedBeer.beerName])
                self.beerLikeButton.imageView?.image = UIImage(named: "beerFull")
            }
            
            // Add like to beer in brewery
            let breweryBeerRef = FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(self.breweryDetail.firebaseID).childByAppendingPath("beers").childByAppendingPath(self.beerDetail.firebaseID)
            
            breweryBeerRef.childByAppendingPath("numberOfLikes").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let numlikes = snapshot.value as! Int
                
                print("2.")
                
                if liked
                {
                    breweryBeerRef.updateChildValues(["numberOfLikes":numlikes+1])
                }
                else
                {
                    breweryBeerRef.updateChildValues(["numberOfLikes":numlikes-1])
                }
                
            })
            
            // Add like to beer in beers list
            let beerListRef = FirebaseConnection.firebaseConnection.BEER_REF
            beerListRef.childByAppendingPath(self.beerDetail.firebaseID).childByAppendingPath("numberOfLikes").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let numlikes = snapshot.value as! Int
                
                print("3.")
                
                if liked
                {
                    beerListRef.childByAppendingPath(self.beerDetail.firebaseID).updateChildValues(["numberOfLikes":numlikes+1])
                }
                else
                {
                    beerListRef.childByAppendingPath(self.beerDetail.firebaseID).updateChildValues(["numberOfLikes":numlikes-1])
                }
                
            })
            
        })
        
        
        
        
        
    }
    
    
    @IBAction func onBeerButtonTapped(sender: UIButton)
    {
        self.likeBeer()
    }
    
    
    

}
