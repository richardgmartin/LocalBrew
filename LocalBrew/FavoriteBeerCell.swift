//
//  FavoriteBeerCell.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/16/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import Foundation
import UIKit

class FavoriteBeerCell: UITableViewCell {
  
    @IBOutlet weak var favoriteBeerFavoriteLabel: UILabel!
    @IBOutlet weak var favoriteBeerImageView: UIImageView!
    @IBOutlet weak var favoriteBeerNameLabel: UILabel!
    
    var favoriteBeer: FavoriteBeer!
    
    
    
    func configureCell(favoriteBeer: FavoriteBeer) {
        self.favoriteBeer = favoriteBeer
        self.favoriteBeerFavoriteLabel.text = String(favoriteBeer.favorite!)
        self.favoriteBeerImageView.image = UIImage(named: "Beer")
        self.favoriteBeerNameLabel.text = favoriteBeer.name!
        print(favoriteBeer.name)
        print(favoriteBeer.favorite)
        
        

        
    }
    
}
