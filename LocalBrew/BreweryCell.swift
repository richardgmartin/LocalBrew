//
//  BreweryCell.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/13/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import MapKit

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
        self.breweryNameLabel.numberOfLines = 0
        self.breweryAddressLabel.text = brewery.streetAddress
        self.breweryAddressLabel.sizeToFit()
        //self.breweryDistanceLabel.text = "0.4 miles"
        //self.breweryLikeLabel.text = "15 Likes"
        self.breweryImageView.image = brewery.breweryImageIcon
        self.breweryNameLabel.font = UIFont.boldSystemFontOfSize(15.0)
        self.breweryNameLabel.sizeToFit()

        
        if brewery.firebaseID == nil
        {
            FirebaseConnection.firebaseConnection.createNewBrewery(brewery)
        }
        
        FirebaseConnection.firebaseConnection.BREWERY_REF.childByAppendingPath(brewery.firebaseID).childByAppendingPath("numberOfLikes").observeEventType(.Value, withBlock: { snapshot in
            let likes = snapshot.value as! Int
            
            self.breweryLikeLabel.text = "Likes: \(likes)"
        })
        
        
        let distance = brewery.distance! * 0.00062137
        
        self.breweryDistanceLabel.text = String(format: "%.2f miles", arguments: [distance])
        self.breweryDistanceLabel.sizeToFit()
        
    }
}
